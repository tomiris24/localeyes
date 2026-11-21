import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// The top of a main tab: a photograph of the city with the screen's name on
/// it.
///
/// It replaces the plain [AppBar] on the three tabs that open a session, so
/// the first thing on screen is Almaty rather than a line of grey chrome. The
/// scrim over the photo is one flat colour, not a gradient — white type stays
/// readable on any frame, and the screen keeps one visual rule.
class PhotoHeader extends StatelessWidget implements PreferredSizeWidget {
  const PhotoHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.image = 'assets/images/koktobe.jpg',
    this.actions = const <Widget>[],
  });

  final String title;
  final String? subtitle;
  final String image;

  /// Round, translucent buttons on the photo — see [HeaderIconButton].
  final List<Widget> actions;

  static const double _height = 164;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height + MediaQuery.paddingOf(context).top,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(image, fit: BoxFit.cover, alignment: Alignment.center),
          ColoredBox(color: context.palette.photoScrim),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 30,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ...actions,
                    ],
                  ),
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.3,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A round button that sits on the photograph of a [PhotoHeader].
class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm),
      // A solid circle of the page's own surface colour, like the icon
      // buttons in the design system — the same button in both themes, and
      // readable on any photograph underneath.
      child: Material(
        color: context.palette.surface,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          onPressed: onPressed,
          tooltip: tooltip,
          iconSize: 20,
          color: context.palette.ink,
          icon: Icon(icon),
        ),
      ),
    );
  }
}
