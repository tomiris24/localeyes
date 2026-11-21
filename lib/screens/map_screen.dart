import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/app_theme.dart';
import '../data/route_api.dart';
import '../models/local_person.dart';
import '../models/spot.dart';
import '../state/data_store.dart';
import '../widgets/spot_card.dart';
import 'local_profile_screen.dart';

/// The city seen geographically: the places locals vouch for, and a route
/// through the ones you pick.
///
/// Two modes share the same canvas. Browsing pairs a card carousel with the
/// pins — swiping a card flies the map, tapping a pin scrolls the carousel.
/// Route mode turns the pins into checkboxes and draws the line the road
/// network actually takes ([RouteApi]).
///
/// The basemap is Esri's Light Gray Canvas: a near-white style that lets the
/// brand colour and the route read on top of it, with the labels as a second
/// layer the way Esri ships them. No API key. (CARTO's Positron, the obvious
/// alternative, now serves a watermark without one.)
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  /// Roughly the centre of Almaty, and a zoom that holds Medeu and Baraholka.
  static const LatLng _almaty = LatLng(43.242, 76.945);
  static const double _initialZoom = 10.5;
  static const double _minZoom = 3;
  static const double _maxZoom = 18;

  /// Close enough to read street names when a card is picked.
  static const double _focusZoom = 14;

  final MapController _map = MapController();
  final PageController _cards = PageController(viewportFraction: 0.86);
  final RouteApi _routeApi = RouteApi();

  /// Most saved first, so the carousel opens on the place people keep sending
  /// each other to.
  late final List<Spot> _spots = List<Spot>.of(DataStore.instance.spots)
    ..sort((Spot a, Spot b) => b.saveCount.compareTo(a.saveCount));

  int _selected = 0;

  bool _routeMode = false;
  final List<Spot> _stops = <Spot>[];
  CityRoute? _route;
  bool _routeLoading = false;
  String? _routeError;

  // flutter_map moves the camera in one jump; these drive it frame by frame.
  late final AnimationController _fly = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  Animation<double>? _flyLat;
  Animation<double>? _flyLng;
  Animation<double>? _flyZoom;

  @override
  void initState() {
    super.initState();
    _fly.addListener(() {
      final Animation<double>? lat = _flyLat;
      if (lat == null) return;
      _map.move(LatLng(lat.value, _flyLng!.value), _flyZoom!.value);
    });
  }

  @override
  void dispose() {
    _fly.dispose();
    _cards.dispose();
    _map.dispose();
    _routeApi.dispose();
    super.dispose();
  }

  /// Glides the camera to [target] instead of teleporting to it.
  void _flyTo(LatLng target, {double? zoom}) {
    final MapCamera camera = _map.camera;
    final CurvedAnimation curve = CurvedAnimation(
      parent: _fly,
      curve: Curves.easeInOut,
    );
    _flyLat = Tween<double>(
      begin: camera.center.latitude,
      end: target.latitude,
    ).animate(curve);
    _flyLng = Tween<double>(
      begin: camera.center.longitude,
      end: target.longitude,
    ).animate(curve);
    _flyZoom = Tween<double>(
      begin: camera.zoom,
      end: zoom ?? camera.zoom,
    ).animate(curve);
    _fly
      ..reset()
      ..forward();
  }

  void _zoomBy(double delta) {
    final double zoom = (_map.camera.zoom + delta).clamp(_minZoom, _maxZoom);
    _map.move(_map.camera.center, zoom);
  }

  /// A pin was tapped: in route mode it becomes a stop, otherwise the carousel
  /// scrolls to it.
  void _tapPin(Spot spot) {
    if (_routeMode) {
      _toggleStop(spot);
      return;
    }
    final int index = _spots.indexOf(spot);
    if (index < 0 || index == _selected) return;
    setState(() => _selected = index);
    _cards.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
    );
    _flyTo(LatLng(spot.lat, spot.lng), zoom: _focusZoom);
  }

  /// The carousel settled on a new card.
  void _onCardChanged(int index) {
    if (index == _selected) return;
    setState(() => _selected = index);
    final Spot spot = _spots[index];
    _flyTo(
      LatLng(spot.lat, spot.lng),
      zoom: _map.camera.zoom < _focusZoom ? _focusZoom : null,
    );
  }

  void _toggleStop(Spot spot) {
    setState(() {
      if (!_stops.remove(spot)) _stops.add(spot);
      // The old line no longer matches the new list of stops.
      _route = null;
      _routeError = null;
    });
  }

  void _enterRouteMode() {
    setState(() {
      _routeMode = true;
      _stops
        ..clear()
        ..add(_spots[_selected]);
      _route = null;
      _routeError = null;
    });
  }

  void _exitRouteMode() {
    setState(() {
      _routeMode = false;
      _stops.clear();
      _route = null;
      _routeError = null;
    });
  }

  Future<void> _buildRoute() async {
    setState(() {
      _routeLoading = true;
      _routeError = null;
    });

    try {
      final CityRoute route = await _routeApi.fetchRoute(<LatLng>[
        for (final Spot s in _stops) LatLng(s.lat, s.lng),
      ]);
      if (!mounted) return;
      setState(() {
        _route = route;
        _routeLoading = false;
      });
      // Frame the whole line, with room for the panel at the bottom.
      _map.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(route.points),
          padding: const EdgeInsets.fromLTRB(48, 80, 48, 220),
        ),
      );
    } on RouteException catch (error) {
      if (!mounted) return;
      setState(() {
        _routeError = error.message;
        _routeLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No app bar: the map runs to the edges of the tab, and the controls
      // float on top of it inside the safe area.
      body: Stack(
        children: <Widget>[
          Positioned.fill(child: _buildMap(context)),
          const _Attribution(),
          _SideControls(
            onZoomIn: () => _zoomBy(1),
            onZoomOut: () => _zoomBy(-1),
            onOpenList: () => _openPlaces(context),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _routeMode ? _buildRoutePanel() : _buildBrowsePanel(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(BuildContext context) {
    return FlutterMap(
      mapController: _map,
      options: const MapOptions(
        initialCenter: _almaty,
        initialZoom: _initialZoom,
        minZoom: _minZoom,
        maxZoom: _maxZoom,
        // Everything but rotation: a two-finger twist here is almost always
        // an imprecise pinch, and a tilted north is hard to undo by hand.
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: <Widget>[
        TileLayer(
          urlTemplate:
              'https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/'
              'World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}',
          userAgentPackageName: 'kz.narxoz.localeyes',
          maxNativeZoom: 16,
        ),
        // Street and district names ride above the route, not under it.
        TileLayer(
          urlTemplate:
              'https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/'
              'World_Light_Gray_Reference/MapServer/tile/{z}/{y}/{x}',
          userAgentPackageName: 'kz.narxoz.localeyes',
          maxNativeZoom: 16,
        ),
        if (_route != null)
          PolylineLayer<Object>(
            polylines: <Polyline<Object>>[
              // A pale casing under the line keeps it readable over any street.
              Polyline<Object>(
                points: _route!.points,
                strokeWidth: 9,
                color: Colors.white,
              ),
              Polyline<Object>(
                points: _route!.points,
                strokeWidth: 5,
                color: context.palette.brand,
              ),
            ],
          ),
        MarkerLayer(
          markers: <Marker>[
            for (final Spot spot in _spots)
              Marker(
                point: LatLng(spot.lat, spot.lng),
                width: 48,
                height: 48,
                child: _SpotPin(
                  spot: spot,
                  selected: !_routeMode && _spots[_selected] == spot,
                  order: _routeMode ? _stops.indexOf(spot) + 1 : 0,
                  routeMode: _routeMode,
                  onTap: () => _tapPin(spot),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildBrowsePanel() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _PillButton(
            icon: Icons.route_rounded,
            label: 'Make a route',
            filled: true,
            onTap: _enterRouteMode,
          ),
        ),
        SizedBox(
          height: 156,
          child: PageView.builder(
            controller: _cards,
            onPageChanged: _onCardChanged,
            itemCount: _spots.length,
            itemBuilder: (BuildContext context, int index) {
              final Spot spot = _spots[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: _SpotMiniCard(
                  spot: spot,
                  onTap: () => _openSpot(context, spot),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Widget _buildRoutePanel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: _RoutePanel(
        stops: _stops,
        route: _route,
        loading: _routeLoading,
        error: _routeError,
        onRemove: _toggleStop,
        onBuild: _buildRoute,
        onClose: _exitRouteMode,
      ),
    );
  }

  /// The recommendations, ranked the way the map ranks its pins.
  void _openPlaces(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      // The sheet is a scrolling list that the reader drags to full height,
      // so it has to be free of the default half-screen cap.
      isScrollControlled: true,
      builder: (BuildContext sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.92,
        expand: false,
        builder: (BuildContext context, ScrollController controller) {
          return _PlacesSheet(
            controller: controller,
            spots: _spots,
            onTapAuthor: (Spot spot) {
              Navigator.of(sheetContext).pop();
              _openAuthor(context, spot);
            },
          );
        },
      ),
    );
  }

  /// A tapped card opens the place in full, so the map stays put behind it.
  void _openSpot(BuildContext context, Spot spot) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SpotCard(
          spot: spot,
          onTapAuthor: () {
            Navigator.of(sheetContext).pop();
            _openAuthor(context, spot);
          },
        ),
      ),
    );
  }

  void _openAuthor(BuildContext context, Spot spot) {
    final LocalPerson person = DataStore.instance.localById(spot.addedById);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => LocalProfileScreen(person: person),
      ),
    );
  }
}

/// One pin. Three looks: idle, the card the carousel is on, and a numbered
/// stop while a route is being put together.
class _SpotPin extends StatelessWidget {
  const _SpotPin({
    required this.spot,
    required this.selected,
    required this.order,
    required this.routeMode,
    required this.onTap,
  });

  final Spot spot;
  final bool selected;

  /// 1-based position in the route, or 0 when this pin is not a stop.
  final int order;
  final bool routeMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isStop = order > 0;
    final bool highlighted = selected || isStop;
    final double size = highlighted ? 40 : 30;

    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: spot.name,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: highlighted ? context.palette.brand : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: highlighted
                    ? context.palette.brand
                    : context.palette.line,
                width: 2,
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: isStop
                ? Text(
                    '$order',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : Icon(
                    routeMode ? Icons.add_rounded : Icons.place_rounded,
                    size: highlighted ? 22 : 17,
                    color: highlighted ? Colors.white : context.palette.brand,
                  ),
          ),
        ),
      ),
    );
  }
}

/// The card under the map: enough of the place to decide, not the whole story.
class _SpotMiniCard extends StatelessWidget {
  const _SpotMiniCard({required this.spot, required this.onTap});

  final Spot spot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Material(
      color: context.palette.surface,
      borderRadius: AppRadius.cardAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: AppRadius.cardAll,
            border: Border.all(color: context.palette.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Flexible(child: _KindBadge(kind: spot.kind)),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    Icons.favorite_rounded,
                    size: 13,
                    color: context.palette.inkMuted,
                  ),
                  const SizedBox(width: 4),
                  Text('${spot.saveCount}', style: text.bodySmall),
                  const Spacer(),
                  Text(spot.area, style: text.bodySmall),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                spot.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.titleMedium,
              ),
              const SizedBox(height: 2),
              Text(
                spot.why,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: text.bodySmall,
              ),
              const Spacer(),
              Text(
                '${spot.addedByName} · ${spot.bestTime}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KindBadge extends StatelessWidget {
  const _KindBadge({required this.kind});

  final String kind;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: context.palette.brandTint,
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(
        kind.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: context.palette.brandDeep,
        ),
      ),
    );
  }
}

/// Route mode: the stops in order, the summary once the line is drawn, and
/// the one button that asks the routing service for it.
class _RoutePanel extends StatelessWidget {
  const _RoutePanel({
    required this.stops,
    required this.route,
    required this.loading,
    required this.error,
    required this.onRemove,
    required this.onBuild,
    required this.onClose,
  });

  final List<Spot> stops;
  final CityRoute? route;
  final bool loading;
  final String? error;
  final ValueChanged<Spot> onRemove;
  final VoidCallback onBuild;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final bool enough = stops.length >= 2;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: context.palette.line),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  route == null
                      ? 'Tap pins to add stops'
                      : 'Route · ${stops.length} stops',
                  style: text.titleMedium,
                ),
              ),
              IconButton(
                onPressed: onClose,
                tooltip: 'Close',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),
          if (route != null) ...<Widget>[
            const SizedBox(height: 2),
            Text(
              '${route!.distanceLabel} · ${route!.durationLabel} by car',
              style: text.bodyMedium,
            ),
          ],
          if (error != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(
              error!,
              style: text.bodySmall?.copyWith(color: context.palette.ink),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          if (stops.isEmpty)
            Text('Nothing picked yet.', style: text.bodySmall)
          else
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: stops.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (BuildContext context, int index) => _StopChip(
                  order: index + 1,
                  spot: stops[index],
                  onRemove: () => onRemove(stops[index]),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: enough && !loading ? onBuild : null,
              icon: loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.route_rounded, size: 20),
              label: Text(
                loading
                    ? 'Building…'
                    : enough
                    ? (route == null ? 'Build route' : 'Rebuild route')
                    : 'Pick one more place',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StopChip extends StatelessWidget {
  const _StopChip({
    required this.order,
    required this.spot,
    required this.onRemove,
  });

  final int order;
  final Spot spot;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 6, right: 2),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.palette.brand,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$order',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              spot.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: context.palette.ink,
              ),
            ),
          ),
          IconButton(
            onPressed: onRemove,
            tooltip: 'Remove',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            icon: Icon(
              Icons.close_rounded,
              size: 14,
              color: context.palette.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// White pill that floats over the map.
class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? context.palette.action : context.palette.surface,
      borderRadius: AppRadius.pillAll,
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.pillAll,
            border: Border.all(
              color: filled ? context.palette.action : context.palette.line,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 18,
                color: filled ? Colors.white : context.palette.ink,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: filled ? Colors.white : context.palette.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Zoom and the full list, stacked on the right edge.
class _SideControls extends StatelessWidget {
  const _SideControls({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onOpenList,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onOpenList;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _RoundButton(
                icon: Icons.list_rounded,
                tooltip: 'All places',
                onTap: onOpenList,
              ),
              const SizedBox(height: AppSpacing.md),
              _RoundButton(
                icon: Icons.add,
                tooltip: 'Zoom in',
                onTap: onZoomIn,
              ),
              const SizedBox(height: AppSpacing.sm),
              _RoundButton(
                icon: Icons.remove,
                tooltip: 'Zoom out',
                onTap: onZoomOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.surface,
      shape: CircleBorder(side: BorderSide(color: context.palette.line)),
      clipBehavior: Clip.antiAlias,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 20, color: context.palette.ink),
          ),
        ),
      ),
    );
  }
}

class _Attribution extends StatelessWidget {
  const _Attribution();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: AppRadius.pillAll,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              child: Text(
                '© Esri · © OpenStreetMap',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Every recommended place, as a sheet that scrolls over the map.
class _PlacesSheet extends StatelessWidget {
  const _PlacesSheet({
    required this.controller,
    required this.spots,
    required this.onTapAuthor,
  });

  final ScrollController controller;
  final List<Spot> spots;
  final ValueChanged<Spot> onTapAuthor;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.palette.canvas,
        borderRadius: BorderRadius.vertical(top: AppRadius.card),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSpacing.maxContentWidth,
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            children: <Widget>[
              const _GrabHandle(),
              const SizedBox(height: AppSpacing.md),
              Text('Most saved by travellers', style: text.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'The places locals keep sending people to',
                style: text.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              for (final Spot spot in spots) ...<Widget>[
                SpotCard(spot: spot, onTapAuthor: () => onTapAuthor(spot)),
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GrabHandle extends StatelessWidget {
  const _GrabHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: context.palette.line,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
