import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// The bookmark badge that sits on top of the cover image.
///
/// This is a [StatefulWidget]: it keeps the small "pop" animation in its own
/// state with [setState], while the saved/not saved value comes from the parent.
class BookmarkBadge extends StatefulWidget {
  const BookmarkBadge({
    super.key,
    required this.isSaved,
    required this.onPressed,
    this.size = 40,
    this.onDarkCover = true,
  });

  final bool isSaved;
  final VoidCallback onPressed;
  final double size;
  final bool onDarkCover;

  @override
  State<BookmarkBadge> createState() => _BookmarkBadgeState();
}

class _BookmarkBadgeState extends State<BookmarkBadge> {
  double _scale = 1;

  void _handleTap() {
    setState(() => _scale = 0.78);
    widget.onPressed();
    Future<void>.delayed(const Duration(milliseconds: 130), () {
      if (mounted) setState(() => _scale = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 130),
      curve: Curves.easeOut,
      child: Material(
        color: widget.onDarkCover
            ? Colors.black.withValues(alpha: 0.38)
            : Colors.white,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _handleTap,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Icon(
              widget.isSaved
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_outline_rounded,
              size: widget.size * 0.52,
              color: widget.isSaved
                  ? AppColors.brand
                  : (widget.onDarkCover ? Colors.white : AppColors.inkMuted),
            ),
          ),
        ),
      ),
    );
  }
}

/// Round translucent button used for "back" and "share" on the cover image.
class CoverIconButton extends StatelessWidget {
  const CoverIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 40,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.38),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: size * 0.5, color: Colors.white),
        ),
      ),
    );
  }
}
