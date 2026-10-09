import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Sticky action bar at the bottom of the detail screen.
///
/// The price keeps only the space it needs ([Flexible]) and the main button
/// takes the whole rest of the row ([Expanded]), so the bar fits every width.
/// On a very narrow phone the price block is hidden instead of overflowing.
class BookingBar extends StatelessWidget {
  const BookingBar({
    super.key,
    required this.total,
    required this.caption,
    required this.label,
    required this.onPressed,
    this.icon = Icons.add_shopping_cart_rounded,
  });

  final double total;
  final String caption;
  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool showPrice = constraints.maxWidth >= 300;

              return Row(
                children: <Widget>[
                  if (showPrice) ...<Widget>[
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '\$${total.toStringAsFixed(0)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleLarge,
                          ),
                          Text(
                            caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                  ],
                  // Expanded makes the main action fill the rest of the bar.
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: onPressed,
                      icon: Icon(icon, size: 20),
                      label: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
