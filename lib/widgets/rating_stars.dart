import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Five stars that show a rating like 4.8 without ever overflowing.
class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.rating, this.size = 14});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(5, (int index) {
        final bool full = rating >= index + 1;
        final bool half = !full && rating > index;
        return Icon(
          full
              ? Icons.star_rounded
              : half
              ? Icons.star_half_rounded
              : Icons.star_outline_rounded,
          size: size,
          color: AppColors.star,
        );
      }),
    );
  }
}
