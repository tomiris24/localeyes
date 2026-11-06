import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../models/tour.dart';
import '../state/cart_provider.dart';

/// The "Add to cart" toggle that sits on every tour card.
///
/// It has no `bool` of its own: whether it reads "Add to cart" or "In cart"
/// comes straight from [CartProvider]. That is why deleting a tour on the cart
/// screen flips this button back by itself — there is no second copy of the
/// truth to keep in sync.
///
/// It is styled quietly on purpose. The button shares its row with the price,
/// and the price is what should carry the weight there, so this is a tint and
/// a word rather than a solid block with an icon in it.
class CartToggleButton extends StatelessWidget {
  const CartToggleButton({super.key, required this.tour});

  final Tour tour;

  static const Size _size = Size(0, 38);
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
  );
  static const TextStyle _label = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w700,
  );

  @override
  Widget build(BuildContext context) {
    // `select` narrows the subscription to one boolean: this button rebuilds
    // when *its* tour goes in or out of the cart, and sits still when another
    // card changes.
    final bool inCart = context.select<CartProvider, bool>(
      (CartProvider cart) => cart.contains(tour.id),
    );

    void onPressed() {
      // `read`, not `watch`: a callback only needs the object to call a method
      // on, and subscribing here would rebuild the button for nothing.
      final bool added = context.read<CartProvider>().toggle(tour);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 1400),
            content: Text(
              added
                  ? '${tour.title} added to cart'
                  : '${tour.title} removed from cart',
            ),
          ),
        );
    }

    // Only size and colour are overridden; the pill shape and the rest keep
    // coming from the button themes, so these cannot drift from the brand.
    if (inCart) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.inkMuted,
          minimumSize: _size,
          padding: _padding,
          textStyle: _label,
        ),
        child: const Text('In cart'),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brand.withValues(alpha: 0.08),
        foregroundColor: AppColors.brand,
        minimumSize: _size,
        padding: _padding,
        textStyle: _label,
      ),
      child: const Text('Add to cart'),
    );
  }
}
