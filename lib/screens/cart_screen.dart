import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/booking_bar.dart';
import '../widgets/empty_state.dart';

/// Everything the traveller added from the detail screen.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState app = AppScope.of(context);
    final List<CartItem> items = app.cart;
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Your cart')),
      body: items.isEmpty
          ? EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'Your cart is empty',
              message:
                  'Open a tour, choose a date and the number of travellers, '
                  'then add it here.',
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
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.inkMuted,
                            ),
                            onPressed: () => app.removeFromCart(item.tourId),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
      bottomNavigationBar: items.isEmpty
          ? null
          : BookingBar(
              total: app.cartTotal,
              caption: '${items.length} '
                  '${items.length == 1 ? "tour" : "tours"} · deposit 20%',
              label: 'Request to book',
              icon: Icons.lock_outline_rounded,
              onPressed: () {
                app.clearCart();
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
}
