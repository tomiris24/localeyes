import 'package:flutter/material.dart';

import '../core/app_theme.dart';

enum ChipTone { soft, outline, dark, success }

/// A small rounded badge used for categories, languages and tour facts.
///
/// The chip is width-limited and its text is ellipsised, so a long tag can
/// never push a [Wrap] or a [Row] out of the screen.
class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.label,
    this.icon,
    this.tone = ChipTone.soft,
    this.dense = false,
  });

  final String label;
  final IconData? icon;
  final ChipTone tone;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final (Color background, Color foreground, Border? border) = switch (tone) {
      ChipTone.soft => (context.palette.brandTint, context.palette.brand, null),
      ChipTone.outline => (
        context.palette.surfaceHigh,
        context.palette.inkMuted,
        Border.all(color: context.palette.line),
      ),
      ChipTone.dark => (
        Colors.black.withValues(alpha: 0.55),
        Colors.white,
        null,
      ),
      ChipTone.success => (
        context.palette.success.withValues(alpha: 0.12),
        context.palette.success,
        null,
      ),
    };

    final double maxWidth = MediaQuery.sizeOf(context).width - 56;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth < 80 ? 80 : maxWidth),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: dense ? 8 : 11,
          vertical: dense ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: background,
          border: border,
          borderRadius: AppRadius.pillAll,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: dense ? 12 : 14, color: foreground),
              const SizedBox(width: 5),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: dense ? 11.5 : 12.5,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
