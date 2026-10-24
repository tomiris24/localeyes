import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/tour.dart';
import 'bookmark_badge.dart';
import 'tag_chip.dart';

/// The cover of the detail screen: a [Stack] with the photo, two gradients,
/// the share button and the bookmark badge on top of the image.
///
/// Going back is handled by the detail screen's [AppBar], so this cover does
/// not draw a back arrow of its own.
class CoverHeader extends StatelessWidget {
  const CoverHeader({
    super.key,
    required this.tour,
    required this.isSaved,
    required this.onToggleSaved,
    required this.height,
    this.borderRadius = BorderRadius.zero,
    this.onShare,
  });

  final Tour tour;
  final bool isSaved;
  final VoidCallback onToggleSaved;
  final double height;
  final BorderRadius borderRadius;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // 1. The cover photo itself.
            Image.asset(tour.image, fit: BoxFit.cover),

            // 2. Dark gradient at the top so the white buttons stay readable.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: <Color>[Color(0x66000000), Color(0x00000000)],
                ),
              ),
            ),

            // 3. Dark gradient at the bottom for the location and badges.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: <Color>[Color(0xB3000000), Color(0x00000000)],
                ),
              ),
            ),

            // 4. Share and bookmark — the interactive part of the cover.
            Positioned(
              top: AppSpacing.md,
              right: AppSpacing.lg,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (onShare != null) ...<Widget>[
                    CoverIconButton(
                      icon: Icons.ios_share_rounded,
                      onPressed: onShare!,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  BookmarkBadge(isSaved: isSaved, onPressed: onToggleSaved),
                ],
              ),
            ),

            // 5. Location and badges. A Wrap keeps them on screen on any width.
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: <Widget>[
                  TagChip(
                    label: tour.area,
                    icon: Icons.place_outlined,
                    tone: ChipTone.dark,
                  ),
                  if (tour.isTopRated)
                    const TagChip(
                      label: 'Top rated',
                      icon: Icons.workspace_premium_outlined,
                      tone: ChipTone.dark,
                    ),
                  if (tour.guide.isVerified)
                    const TagChip(
                      label: 'Verified guide',
                      icon: Icons.verified_user_outlined,
                      tone: ChipTone.dark,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
