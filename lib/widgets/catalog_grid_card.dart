import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/catalog_item.dart';
import 'catalog_list_tile.dart';

/// One cell of the catalog in grid mode.
///
/// The icon block takes the leftover height with [Expanded] and every text is
/// ellipsised, so the card fits whatever `childAspectRatio` leaves it — that
/// is what keeps the 2-column grid free of RenderFlex overflow on a 320 px
/// phone.
class CatalogGridCard extends StatelessWidget {
  const CatalogGridCard({super.key, required this.item});

  final CatalogItem item;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Container(
              width: double.infinity,
              color: AppColors.brandSoft,
              alignment: Alignment.center,
              child: Icon(
                catalogIcon(item.category),
                size: 34,
                color: AppColors.brand,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
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
                const SizedBox(height: 4),
                Text(
                  item.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall,
                ),
                const SizedBox(height: 6),
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: AppColors.star,
                    ),
                    const SizedBox(width: 2),
                    Text(item.ratingLabel, style: text.bodySmall),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        item.priceLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleSmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
