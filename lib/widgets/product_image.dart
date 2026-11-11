import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// A product photo from the network, with the two states every remote image
/// needs: a placeholder while the bytes arrive and a fallback when they never do.
class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.url,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.padding = EdgeInsets.zero,
  });

  final String url;
  final BoxFit fit;
  final Alignment alignment;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const _ImageFallback();

    return Padding(
      padding: padding,
      child: Image.network(
        url,
        fit: fit,
        alignment: alignment,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder:
            (BuildContext context, Widget child, ImageChunkEvent? progress) {
              if (progress == null) return child;
              return const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
            const _ImageFallback(),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.canvas,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.inkMuted,
        ),
      ),
    );
  }
}
