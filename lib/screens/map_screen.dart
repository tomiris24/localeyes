import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/app_theme.dart';
import '../data/mock_locals.dart';
import '../models/local_person.dart';
import '../models/spot.dart';
import '../widgets/spot_card.dart';
import 'local_profile_screen.dart';

/// The city seen geographically: the places locals vouch for.
///
/// The tab is the map and nothing else. Recommendations are what the pins
/// already are, so the list of them stays folded away behind one button and
/// opens as a scrollable sheet when somebody asks for it.
///
/// The canvas is OpenStreetMap raster tiles through `flutter_map`: no API key
/// and no account, in exchange for the attribution the tile usage policy asks
/// for. Swapping to vector tiles later is a change of [TileLayer] only.
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No app bar: the map runs to the edges of the tab, and the controls
      // float on top of it inside the safe area.
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: _SpotMap(
              spots: MockLocals.spots,
              onTapSpot: (Spot spot) => _openSpot(context, spot),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: FilledButton.icon(
                  onPressed: () => _openPlaces(context),
                  icon: const Icon(Icons.bookmark_rounded, size: 18),
                  label: Text(
                    'Most saved · ${MockLocals.spots.length} places',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The recommendations, ranked the way the map would rank its pins.
  void _openPlaces(BuildContext context) {
    final List<Spot> popular = List<Spot>.of(MockLocals.spots)
      ..sort((Spot a, Spot b) => b.saveCount.compareTo(a.saveCount));

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
            spots: popular,
            onTapAuthor: (Spot spot) {
              Navigator.of(sheetContext).pop();
              _openAuthor(context, spot);
            },
          );
        },
      ),
    );
  }

  /// A tapped pin opens the place as a sheet, so the map stays put behind it.
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
    final LocalPerson person = MockLocals.byId(spot.addedById);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => LocalProfileScreen(person: person),
      ),
    );
  }
}

/// The map canvas: OpenStreetMap tiles with one pin per [Spot].
class _SpotMap extends StatefulWidget {
  const _SpotMap({required this.spots, required this.onTapSpot});

  final List<Spot> spots;
  final ValueChanged<Spot> onTapSpot;

  @override
  State<_SpotMap> createState() => _SpotMapState();
}

class _SpotMapState extends State<_SpotMap> {
  /// Roughly the centre of Almaty, and a zoom that holds Medeu and Baraholka.
  static const LatLng _almaty = LatLng(43.242, 76.945);
  static const double _initialZoom = 10.5;
  static const double _minZoom = 3;
  static const double _maxZoom = 18;

  final MapController _controller = MapController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Pinching is the real gesture, but it is awkward one-handed and needs a
  /// modifier key on a simulator, so the buttons are not a nicety.
  void _zoomBy(double delta) {
    final double zoom = (_controller.camera.zoom + delta).clamp(
      _minZoom,
      _maxZoom,
    );
    _controller.move(_controller.camera.center, zoom);
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _controller,
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
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'fit.hj.localeyes',
          maxNativeZoom: 19,
        ),
        MarkerLayer(
          markers: <Marker>[
            for (final Spot spot in widget.spots)
              Marker(
                point: LatLng(spot.lat, spot.lng),
                width: 36,
                height: 36,
                alignment: Alignment.topCenter,
                child: _SpotPin(
                  spot: spot,
                  onTap: () => widget.onTapSpot(spot),
                ),
              ),
          ],
        ),
        _ZoomButtons(
          onZoomIn: () => _zoomBy(1),
          onZoomOut: () => _zoomBy(-1),
        ),
        // Required by the OpenStreetMap tile usage policy. It sits at the top
        // because the button and the sheet own the bottom of the canvas.
        const _Attribution(),
      ],
    );
  }
}

/// Plus and minus over the canvas, stacked above the attribution chip.
class _ZoomButtons extends StatelessWidget {
  const _ZoomButtons({required this.onZoomIn, required this.onZoomOut});

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

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
              _ZoomButton(
                icon: Icons.add,
                tooltip: 'Zoom in',
                onTap: onZoomIn,
              ),
              const SizedBox(height: AppSpacing.sm),
              _ZoomButton(
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

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({
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
      color: Colors.white,
      shape: const CircleBorder(side: BorderSide(color: AppColors.line)),
      clipBehavior: Clip.antiAlias,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 20, color: AppColors.ink),
          ),
        ),
      ),
    );
  }
}

class _SpotPin extends StatelessWidget {
  const _SpotPin({required this.spot, required this.onTap});

  final Spot spot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: spot.name,
        child: const Icon(Icons.location_on, size: 32, color: AppColors.brand),
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
              borderRadius: AppRadius.cardAll,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              child: Text(
                '© OpenStreetMap',
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
      decoration: const BoxDecoration(
        color: AppColors.canvas,
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
          color: AppColors.line,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
