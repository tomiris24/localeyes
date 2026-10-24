import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import 'discovery_screen.dart';
import 'locals_screen.dart';
import 'profile_screen.dart';
import 'saved_screen.dart';

/// Root screen of the app: four tabs inside a [BottomNavigationBar].
///
///  * Tab 1 — [LocalsScreen]: people who live here and are up for meeting.
///  * Tab 2 — [DiscoveryScreen]: the feed of organised tours.
///  * Tab 3 — [SavedScreen]: the tours the traveller bookmarked.
///  * Tab 4 — [ProfileScreen]: profile and settings.
///
/// People come first on purpose: the point of the app is meeting someone who
/// lives here, and a booked tour is only one of the ways that can go.
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
  int _index = 0;

  void _selectTab(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack builds all four tabs once and only shows the selected
      // one, which is what keeps their state alive between tab switches.
      body: IndexedStack(
        index: _index,
        children: <Widget>[
          const LocalsScreen(),
          const DiscoveryScreen(),
          SavedScreen(onBrowse: () => _selectTab(1)),
          const ProfileScreen(),
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
              icon: Icon(Icons.people_outline_rounded),
              activeIcon: Icon(Icons.people_rounded),
              label: 'Locals',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore_rounded),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_outline_rounded),
              activeIcon: Icon(Icons.bookmark_rounded),
              label: 'Saved',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
