import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/catalog_item.dart';

/// The icon that stands for a category. Lives next to the widgets that draw
/// it, so the model itself stays plain Dart.
IconData catalogIcon(String category) => switch (category) {
  'Mountains' => Icons.terrain_rounded,
  'Food' => Icons.ramen_dining_rounded,
  'City walk' => Icons.directions_walk_rounded,
  'Culture' => Icons.museum_rounded,
  'Ski' => Icons.downhill_skiing_rounded,
  'Photography' => Icons.photo_camera_rounded,
  _ => Icons.explore_rounded,
};

/// One row of the catalog in list mode: avatar icon, title, category tag,
/// star rating and price.
class CatalogListTile extends StatelessWidget {
  const CatalogListTile({super.key, required this.item});

  final CatalogItem item;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.brandSoft,
            child: Icon(catalogIcon(item.category), color: AppColors.brand),
          ),
          const SizedBox(width: AppSpacing.md),
          // Expanded keeps a long title from pushing the price off the row.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleSmall,
                ),
                const SizedBox(height: 5),
                Row(
                  children: <Widget>[
                    // Flexible + ellipsis: on a 320 px phone a long category
                    // like "Photography" shrinks instead of overflowing.
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.canvas,
                          borderRadius: AppRadius.pillAll,
                        ),
                        child: Text(
                          item.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brandDeep,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: AppColors.star,
                    ),
                    const SizedBox(width: 2),
                    Text(item.ratingLabel, style: text.bodySmall),
                    if (item.isNew) ...<Widget>[
                      const SizedBox(width: AppSpacing.sm),
                      const Text(
                        'NEW',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(item.priceLabel, style: text.titleMedium),
        ],
      ),
    );
  }
}
