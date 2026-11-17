import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../data/guide_picks.dart';
import '../models/product.dart';
import 'avatar_circle.dart';
import 'gear_category.dart';
import 'product_image.dart';

/// One row of the feed: thumbnail, title, kind of kit, rating, price — and the
/// guide who suggested it, which is the only reason it is in a tours app.
class ProductTile extends StatelessWidget {
  const ProductTile({super.key, required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final GuidePick pick = GuidePick.forProduct(product);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // The flight starts here and lands on the first carousel slide.
            Hero(
              tag: 'product_image_${product.id}',
              child: Container(
                width: 68,
                height: 68,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  border: Border.fromBorderSide(
                    BorderSide(color: AppColors.line),
                  ),
                ),
                child: ProductImage(
                  url: product.imageUrl,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleSmall,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      // Flexible + ellipsis: a long category shrinks instead
                      // of overflowing on a narrow phone.
                      Flexible(
                        child: CategoryBadge(
                          category: GearCategory.of(product.category),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: AppColors.star,
                      ),
                      const SizedBox(width: 2),
                      Text(product.ratingLabel, style: text.bodySmall),
                      const SizedBox(width: 4),
                      Text('(${product.reviewCount})', style: text.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      AvatarCircle(initials: pick.guide.initials, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${pick.guide.name} · ${pick.tour.title}',
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
            const SizedBox(width: AppSpacing.sm),
            Text(product.priceLabel, style: text.titleMedium),
          ],
        ),
      ),
    );
  }
}

/// The pill that says what kind of kit this is.
class CategoryBadge extends StatelessWidget {
  const CategoryBadge({super.key, required this.category});

  final GearCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: const BoxDecoration(
        color: AppColors.canvas,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(category.icon, size: 12, color: AppColors.brandDeep),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              category.label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: AppColors.brandDeep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
