import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../data/store_api.dart';
import '../models/product.dart';
import '../widgets/product_tile.dart';
import 'product_detail_screen.dart';

/// The store feed, fed by a live REST API.
///
/// It has exactly three states and never shows two of them at once: a spinner
/// while the first request is in flight, the list once it lands, and an error
/// screen with a retry button when it does not.
class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final StoreApi _api = StoreApi();

  List<Product> _products = <Product>[];
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  /// Fetches the catalogue. Pull-to-refresh passes `showSpinner: false`,
  /// because the [RefreshIndicator] is already drawing one of its own.
  Future<void> _load({bool showSpinner = true}) async {
    if (showSpinner) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final List<Product> products = await _api.fetchProducts();
      if (!mounted) return;
      setState(() {
        _products = products;
        _error = null;
        _loading = false;
      });
    } on StoreException catch (error) {
      if (!mounted) return;
      // A failed refresh must not wipe a feed that is already on screen — the
      // error moves into a snack bar and the old products stay readable.
      if (_products.isNotEmpty) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(error.message)));
        return;
      }
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  void _openProduct(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            ProductDetailScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store'),
        actions: <Widget>[
          IconButton(
            onPressed: _loading ? null : () => _load(),
            tooltip: 'Reload',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(top: false, child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Both remaining states sit inside the same RefreshIndicator, so a pull
    // retries the request whether the feed loaded or not.
    return RefreshIndicator(
      color: AppColors.brand,
      onRefresh: () => _load(showSpinner: false),
      child: _error != null
          ? _ErrorState(message: _error!, onRetry: () => _load())
          : _ProductList(products: _products, onOpen: _openProduct),
    );
  }
}

class _ProductList extends StatelessWidget {
  const _ProductList({required this.products, required this.onOpen});

  final List<Product> products;
  final void Function(Product) onOpen;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      // +1: the header strip rides along as the first row, so it scrolls away
      // with the feed instead of eating a fixed strip of the screen.
      itemCount: products.length + 1,
      separatorBuilder: (BuildContext context, int index) =>
          const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Text(
              '${products.length} products · live from fakestoreapi.com',
              style: text.bodySmall,
            ),
          );
        }

        final Product product = products[index - 1];
        return ProductTile(product: product, onTap: () => onOpen(product));
      },
    );
  }
}

/// The offline / server-error state: what went wrong, and one button to try
/// the request again without restarting the app.
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          // Always scrollable, otherwise there is nothing to pull on and the
          // RefreshIndicator above never fires.
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 76,
                      height: 76,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.brandSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cloud_off_rounded,
                        size: 34,
                        color: AppColors.brand,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'No connection to the store',
                      textAlign: TextAlign.center,
                      style: text.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: text.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      label: const Text('Retry Connection'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
