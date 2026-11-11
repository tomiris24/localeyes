import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/product.dart';
import '../widgets/product_image.dart';
import '../widgets/product_tile.dart';
import '../widgets/share_sheet.dart';

/// One framing of the product photo.
///
/// The API ships a single image per product, so the gallery varies the crop
/// and the backdrop instead of inventing photos that do not exist.
class _GalleryShot {
  const _GalleryShot({
    required this.label,
    required this.fit,
    required this.alignment,
    required this.padding,
    required this.background,
  });

  final String label;
  final BoxFit fit;
  final Alignment alignment;
  final EdgeInsets padding;
  final Color background;
}

/// The product page: hero image carousel, the full description, and a bottom
/// bar that stays put while the text scrolls.
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  static const List<_GalleryShot> _shots = <_GalleryShot>[
    _GalleryShot(
      label: 'Front',
      fit: BoxFit.contain,
      alignment: Alignment.center,
      padding: EdgeInsets.all(28),
      background: Colors.white,
    ),
    _GalleryShot(
      label: 'Close-up',
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      padding: EdgeInsets.zero,
      background: Colors.white,
    ),
    _GalleryShot(
      label: 'In frame',
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.fromLTRB(60, 48, 60, 24),
      background: AppColors.canvas,
    ),
  ];

  final PageController _controller = PageController();

  int _page = 0;

  /// The cart is still tour-only (`CartItem` resolves a tour id against the
  /// mock data), so a store product is kept on the screen for now.
  bool _inCart = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCart() {
    setState(() => _inCart = !_inCart);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            _inCart
                ? '${widget.product.title} added to cart'
                : 'Removed from cart',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final Product product = widget.product;
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Product'),
        actions: <Widget>[
          IconButton(
            onPressed: () => showProductShareSheet(context, product),
            tooltip: 'Share',
            icon: const Icon(Icons.ios_share_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _Carousel(
            product: product,
            shots: _shots,
            controller: _controller,
            page: _page,
            onPageChanged: (int page) => setState(() => _page = page),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(child: CategoryBadge(label: product.category)),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: AppColors.star,
                    ),
                    const SizedBox(width: 2),
                    Text(product.ratingLabel, style: text.titleSmall),
                    const SizedBox(width: 4),
                    Text('· ${product.reviewLabel}', style: text.bodySmall),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(product.title, style: text.headlineSmall),
                const SizedBox(height: AppSpacing.sm),
                Text(product.priceLabel, style: text.titleLarge),
                const SizedBox(height: AppSpacing.lg),
                const Divider(),
                const SizedBox(height: AppSpacing.lg),
                Text('About this item', style: text.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(product.description, style: text.bodyLarge),
                const SizedBox(height: AppSpacing.lg),
                _DeepLinkRow(
                  product: product,
                  onTap: () => showProductShareSheet(context, product),
                ),
              ],
            ),
          ),
        ],
      ),
      // Sticky: the bar is part of the Scaffold, so it never scrolls away.
      bottomNavigationBar: _BuyBar(
        product: product,
        inCart: _inCart,
        onPressed: _toggleCart,
      ),
    );
  }
}

class _Carousel extends StatelessWidget {
  const _Carousel({
    required this.product,
    required this.shots,
    required this.controller,
    required this.page,
    required this.onPageChanged,
  });

  final Product product;
  final List<_GalleryShot> shots;
  final PageController controller;
  final int page;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Stack(
        children: <Widget>[
          PageView.builder(
            controller: controller,
            onPageChanged: onPageChanged,
            itemCount: shots.length,
            itemBuilder: (BuildContext context, int index) {
              final _GalleryShot shot = shots[index];
              final Widget image = ColoredBox(
                color: shot.background,
                child: ProductImage(
                  url: product.imageUrl,
                  fit: shot.fit,
                  alignment: shot.alignment,
                  padding: shot.padding,
                ),
              );

              // Only the first slide carries the hero tag: two widgets with
              // the same tag on one route would make the flight ambiguous.
              return index == 0
                  ? Hero(tag: 'product_image_${product.id}', child: image)
                  : image;
            },
          ),
          Positioned(
            left: AppSpacing.lg,
            top: AppSpacing.md,
            child: _Pill(text: shots[page].label),
          ),
          Positioned(
            right: AppSpacing.lg,
            top: AppSpacing.md,
            child: _Pill(text: '${page + 1} / ${shots.length}'),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: AppSpacing.md,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(shots.length, (int index) {
                final bool active = index == page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 20 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: active ? AppColors.brand : AppColors.line,
                    borderRadius: AppRadius.pillAll,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: const BoxDecoration(
        color: AppColors.ink,
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// A quiet reminder of the deep link, so the share sheet is discoverable from
/// the body of the page and not only from the app bar.
class _DeepLinkRow extends StatelessWidget {
  const _DeepLinkRow({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.cardAll,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.canvas,
          borderRadius: AppRadius.cardAll,
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.link_rounded, size: 18, color: AppColors.brand),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                product.deepLink,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted),
          ],
        ),
      ),
    );
  }
}

class _BuyBar extends StatelessWidget {
  const _BuyBar({
    required this.product,
    required this.inCart,
    required this.onPressed,
  });

  final Product product;
  final bool inCart;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Total', style: text.bodySmall),
                  Text(product.priceLabel, style: text.titleLarge),
                ],
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onPressed,
                  icon: Icon(
                    inCart
                        ? Icons.check_circle_rounded
                        : Icons.shopping_bag_outlined,
                    size: 20,
                  ),
                  label: Text(inCart ? 'In cart' : 'Add to Cart'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
