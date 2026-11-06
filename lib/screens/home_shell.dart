import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import 'discovery_screen.dart';
import 'locals_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';

/// Root screen of the app: four tabs inside a [BottomNavigationBar].
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
        bottomNavigationBar: DecoratedBox(
          // A thin line separates the white bar from the canvas background.
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.line)),
          ),
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: _selectTab,
            type: BottomNavigationBarType.fixed,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore_rounded),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                activeIcon: Icon(Icons.map_rounded),
                label: 'Map',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline_rounded),
                activeIcon: Icon(Icons.people_rounded),
                label: 'Locals',
              ),
            ],
          ),
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
