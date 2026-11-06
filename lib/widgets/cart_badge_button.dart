import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../state/cart_provider.dart';

/// The round cart button in the feed's app bar, with the live counter on it.
///
/// It watches [CartProvider] itself instead of taking the count as a
/// parameter, so no screen has to pass the number down — and `context.watch`
/// subscribes only this button: when the cart notifies, the feed around it is
/// left alone.
class CartBadgeButton extends StatelessWidget {
  const CartBadgeButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final int count = context.watch<CartProvider>().count;

    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              const Icon(
                Icons.shopping_bag_outlined,
                size: 22,
                color: AppColors.ink,
              ),
              // No badge at all on an empty cart — an empty circle would read
              // as "zero somethings" instead of "nothing yet".
              if (count > 0)
                Positioned(
                  top: 9,
                  right: 8,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 16),
                    height: 16,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: const BoxDecoration(
                      color: AppColors.brand,
                      borderRadius: AppRadius.pillAll,
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
