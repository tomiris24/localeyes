import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../models/cart_item.dart';
import '../state/cart_provider.dart';
import '../widgets/booking_bar.dart';
import '../widgets/empty_state.dart';

/// Screen 2 of the cart: everything that was added, a delete button on every
/// row, the total, and "Clear All".
///
/// Nothing here is copied into local state. The screen reads [CartProvider]
/// and writes back to it, so a change made here is already true on the feed
/// behind it — the badge and the "Add to cart" buttons follow without being
/// told.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // `watch`: the whole screen depends on the cart, so there is nothing to
    // gain from a narrower subscription.
    final CartProvider cart = context.watch<CartProvider>();
    final List<CartItem> items = cart.items;
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your cart'),
        actions: <Widget>[
          // Only offered when there is something to clear.
          if (!cart.isEmpty)
            TextButton(
              onPressed: () => _clearAll(context, cart),
              child: const Text('Clear All'),
            ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: cart.isEmpty
          ? EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'Your cart is empty',
              message:
                  'Add a tour straight from the feed, or open one to choose '
                  'the date and the number of travellers first.',
              actionLabel: 'Back to tours',
              onAction: () => Navigator.of(context).maybePop(),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.maxContentWidth,
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (BuildContext context, int index) {
                    final CartItem item = items[index];
                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.cardAll,
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Row(
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(
                              item.tour.image,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  item.tour.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: text.titleSmall,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.date} · ${item.guests} '
                                  '${item.guests == 1 ? "traveller" : "travellers"}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: text.bodySmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${item.total.toStringAsFixed(0)}',
                                  style: text.titleSmall?.copyWith(
                                    color: AppColors.brand,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Remove ${item.tour.title}',
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.inkMuted,
                            ),
                            // `read`: a callback needs the object, not a
                            // subscription — this screen already watches.
                            onPressed: () => context
                                .read<CartProvider>()
                                .remove(item.tourId),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : BookingBar(
              // The total comes from the provider: the screen shows a number
              // it never calculates itself.
              total: cart.total,
              caption:
                  '${items.length} '
                  '${items.length == 1 ? "tour" : "tours"} · deposit 20%',
              label: 'Request to book',
              icon: Icons.lock_outline_rounded,
              onPressed: () {
                cart.clear();
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Request sent. The guide confirms within 2 hours.',
                      ),
                    ),
                  );
                Navigator.of(context).maybePop();
              },
            ),
    );
  }

  /// Empties the cart and offers one undo, so a mis-tap on "Clear All" does
  /// not cost the whole cart.
  void _clearAll(BuildContext context, CartProvider cart) {
    final List<CartItem> removed = cart.items;
    cart.clear();

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '${removed.length} '
            '${removed.length == 1 ? "tour" : "tours"} removed',
          ),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: Colors.white,
            onPressed: () {
              for (final CartItem item in removed) {
                cart.add(item);
              }
            },
          ),
        ),
      );
  }
}
