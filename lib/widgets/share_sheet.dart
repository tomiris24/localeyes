import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_theme.dart';
import '../models/product.dart';

/// Opens the share sheet for [product] and shows its deep link.
Future<void> showProductShareSheet(BuildContext context, Product product) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: AppRadius.card),
    ),
    builder: (BuildContext context) => _ShareSheet(product: product),
  );
}

class _ShareSheet extends StatelessWidget {
  const _ShareSheet({required this.product});

  final Product product;

  Future<void> _copy(BuildContext context) async {
    // Grab the messenger before the await: popping the sheet takes this
    // context down with it.
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final NavigatorState navigator = Navigator.of(context);

    await Clipboard.setData(ClipboardData(text: product.deepLink));
    navigator.pop();
    messenger
      ..clearSnackBars()
      ..showSnackBar(const SnackBar(content: Text('Link copied')));
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Share this product', style: text.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'The link opens this page straight inside the app.',
              style: text.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, 4, 4, 4),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                borderRadius: AppRadius.pillAll,
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      product.deepLink,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _copy(context),
                    tooltip: 'Copy link',
                    icon: const Icon(
                      Icons.copy_rounded,
                      size: 20,
                      color: AppColors.brand,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _copy(context),
                icon: const Icon(Icons.link_rounded, size: 20),
                label: const Text('Copy deep link'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
