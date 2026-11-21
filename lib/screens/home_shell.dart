import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import 'become_local_screen.dart';
import 'catalog_screen.dart';
import 'discovery_screen.dart';
import 'locals_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'spots_screen.dart';
import 'store_screen.dart';
import 'trip_notes_screen.dart';

/// Root screen of the app: four tabs around the centre action, in
/// [AppBottomNav].
///
///  * Tab 1 — [DiscoveryScreen]: the feed of tours, the cart badge and the
///    "add to cart" toggles.
///  * Tab 2 — [MapScreen]: the city geographically, and later the routes
///    built through it.
///  * Tab 3 — [ProfileScreen]: profile, settings and the saved tours.
///  * Tab 4 — [LocalsScreen]: people who live here and are up for meeting.
///
/// Saved tours used to own a tab. They are a private list you check now and
/// then, not somewhere you start a session, so they moved under the profile
/// and the slot went to the map.
///
/// The selected tab lives in this [StatefulWidget] and changes with [setState].
/// The four tabs are kept inside an [IndexedStack], so switching tabs — or
/// coming back from the detail screen with `Navigator.pop` — never rebuilds
/// them from scratch: scroll position, search text and filters stay as they
/// were.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const int _exploreTab = 0;

  int _index = _exploreTab;

  void _selectTab(int index) => setState(() => _index = index);

  /// The violet circle in the middle of the bar. Everything it offers is
  /// something you add to the app rather than something you browse, which is
  /// why these four live here and not in a tab.
  void _openCreateSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _CreateAction(
              icon: Icons.waving_hand_rounded,
              title: 'Become a local',
              subtitle: 'Show travellers your own city',
              onTap: () => _push(sheetContext, const BecomeLocalScreen()),
            ),
            _CreateAction(
              icon: Icons.place_outlined,
              title: 'Places locals love',
              subtitle: 'The spots people added themselves',
              onTap: () => _push(sheetContext, const SpotsScreen()),
            ),
            _CreateAction(
              icon: Icons.storefront_rounded,
              title: 'Guide picks',
              subtitle: 'Kit the guides suggest for their tours',
              onTap: () => _push(sheetContext, const StoreScreen()),
            ),
            _CreateAction(
              icon: Icons.checklist_rounded,
              title: 'Trip notes',
              subtitle: 'Your own list, kept on this phone',
              onTap: () => _push(sheetContext, const TripNotesScreen()),
            ),
            _CreateAction(
              icon: Icons.grid_view_rounded,
              title: 'Catalog',
              subtitle: 'Every tour as a list or a grid',
              onTap: () => _push(sheetContext, const CatalogScreen()),
            ),
          ],
        ),
      ),
    );
  }

  void _push(BuildContext sheetContext, Widget screen) {
    Navigator.of(sheetContext).pop();
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (BuildContext context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return HomeTabs(
      openExplore: () => _selectTab(_exploreTab),
      child: Scaffold(
        // IndexedStack builds all four tabs once and only shows the selected
        // one, which is what keeps their state alive between tab switches.
        body: IndexedStack(
          index: _index,
          children: const <Widget>[
            DiscoveryScreen(),
            MapScreen(),
            ProfileScreen(),
            LocalsScreen(),
          ],
        ),
        bottomNavigationBar: AppBottomNav(
          index: _index,
          onSelect: _selectTab,
          onCreate: _openCreateSheet,
          destinations: const <NavDestination>[
            NavDestination(
              label: 'Explore',
              icon: Icons.explore_outlined,
              activeIcon: Icons.explore_rounded,
            ),
            NavDestination(
              label: 'Map',
              icon: Icons.map_outlined,
              activeIcon: Icons.map_rounded,
            ),
            NavDestination(
              label: 'Profile',
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
            ),
            NavDestination(
              label: 'Locals',
              icon: Icons.people_outline_rounded,
              activeIcon: Icons.people_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

/// Lets a screen pushed on top of the shell send the traveller back to a tab.
///
/// Saved tours is the case this exists for: it opens from the profile as a
/// route, and its empty state offers to go browsing — which means the feed,
/// not the profile underneath it.
class HomeTabs extends InheritedWidget {
  const HomeTabs({super.key, required this.openExplore, required super.child});

  final VoidCallback openExplore;

  /// Null outside a [HomeShell] — a screen opened on its own, as the tests
  /// and the detail routes sometimes do, simply has no tab to go back to.
  static HomeTabs? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HomeTabs>();

  @override
  bool updateShouldNotify(HomeTabs oldWidget) =>
      openExplore != oldWidget.openExplore;
}

/// One row of the sheet behind the centre button.
class _CreateAction extends StatelessWidget {
  const _CreateAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: context.palette.brandTint,
        child: Icon(icon, color: context.palette.brand, size: 20),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: context.palette.inkMuted,
      ),
    );
  }
}
