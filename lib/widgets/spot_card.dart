import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/spot.dart';

/// A place as one resident describes it.
///
/// The quote is the content — the name and the area are only there so you can
/// find it. That is the difference between this and a listing site.
class SpotCard extends StatelessWidget {
  const SpotCard({super.key, required this.spot, this.onTapAuthor});

  final Spot spot;
  final VoidCallback? onTapAuthor;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: context.palette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  spot.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleMedium,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.favorite_rounded,
                    size: 13,
                    color: context.palette.inkMuted,
                  ),
                  const SizedBox(width: 4),
                  Text('${spot.saveCount}', style: text.bodySmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: <Widget>[
              _Meta(icon: Icons.place_outlined, label: spot.area),
              _Meta(icon: Icons.category_outlined, label: spot.kind),
              _Meta(icon: Icons.schedule_rounded, label: spot.bestTime),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // The quote marker is a left rule, not a decorative glyph: it marks
          // where one person's opinion starts and the app's voice stops.
          Container(
            padding: const EdgeInsets.only(left: AppSpacing.md),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: context.palette.brand, width: 3),
              ),
            ),
            child: Text(
              spot.why,
              style: text.bodyLarge?.copyWith(fontSize: 14, height: 1.45),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: onTapAuthor,
            borderRadius: AppRadius.pillAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.person_outline_rounded,
                    size: 14,
                    color: context.palette.inkMuted,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Added by ${spot.addedByName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: context.palette.brand,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width - 80,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 12, color: context.palette.inkMuted),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: context.palette.inkMuted),
            ),
          ),
        ],
      ),
    );
  }
}
