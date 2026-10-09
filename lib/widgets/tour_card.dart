import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/tour.dart';
import 'bookmark_badge.dart';
import 'rating_stars.dart';

/// Card used on the discovery feed and on the saved screen.
///
/// The cover takes the free space with [Expanded] and the text block keeps its
/// own height, so the same card works in a list and in a grid cell.
class TourCard extends StatelessWidget {
  const TourCard({
    super.key,
    required this.tour,
    required this.isSaved,
    required this.onToggleSaved,
    required this.onTap,
  });

  final Tour tour;
  final bool isSaved;
  final VoidCallback onToggleSaved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Material(
      color: Colors.white,
      borderRadius: AppRadius.cardAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.asset(tour.image, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                        colors: <Color>[Color(0x4D000000), Color(0x00000000)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: BookmarkBadge(
                      isSaved: isSaved,
                      onPressed: onToggleSaved,
                      size: 36,
                    ),
                  ),
                  Positioned(
                    left: AppSpacing.md,
                    bottom: AppSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.pillAll,
                      ),
                      child: Text(
                        '\$${tour.pricePerPerson.toStringAsFixed(0)} / person',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    tour.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.place_outlined,
                        size: 13,
                        color: AppColors.inkMuted,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          tour.area,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: <Widget>[
                      RatingStars(rating: tour.rating, size: 13),
                      const SizedBox(width: 5),
                      Text(
                        tour.rating.toStringAsFixed(1),
                        style: text.titleSmall,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '· ${tour.duration}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall,
                        ),
                      ),
                    ],
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
