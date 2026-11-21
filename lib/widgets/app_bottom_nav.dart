import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// One destination of [AppBottomNav].
class NavDestination {
  const NavDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// The bottom bar of the app: four tabs around one round action.
///
/// Material's own [BottomNavigationBar] cannot hold the centre button, so the
/// bar is built here — four labelled tabs, and between the second and the
/// third the violet circle that opens the "add something" sheet. The accent
/// appears twice on this bar and nowhere else on the screen: the selected tab
/// and that circle.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.index,
    required this.destinations,
    required this.onSelect,
    required this.onCreate,
  });

  final int index;
  final List<NavDestination> destinations;
  final ValueChanged<int> onSelect;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final int half = destinations.length ~/ 2;

    return Container(
      decoration: BoxDecoration(
        color: context.palette.surface,
        border: Border(top: BorderSide(color: context.palette.line)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: <Widget>[
              for (int i = 0; i < half; i++) _tab(i),
              _CentreAction(onPressed: onCreate),
              for (int i = half; i < destinations.length; i++) _tab(i),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(int i) => Expanded(
    child: _NavTab(
      destination: destinations[i],
      selected: i == index,
      onTap: () => onSelect(i),
    ),
  );
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final NavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = selected
        ? context.palette.brand
        : context.palette.inkMuted;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            selected ? destination.activeIcon : destination.icon,
            size: 23,
            color: color,
          ),
          const SizedBox(height: 3),
          Text(
            destination.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// The violet circle in the middle of the bar.
class _CentreAction extends StatelessWidget {
  const _CentreAction({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Material(
        color: context.palette.brandDeep,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: const SizedBox(
            width: 52,
            height: 52,
            child: Icon(Icons.add_rounded, color: Colors.white, size: 26),
          ),
        ),
      ),
    );
  }
}
