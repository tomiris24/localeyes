import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../data/store_api.dart';
import '../models/product.dart';
import '../widgets/empty_state.dart';
import '../widgets/gear_category.dart';
import '../widgets/product_tile.dart';
import 'product_detail_screen.dart';

/// Guide picks: the kit our guides tell travellers to bring on their tours.
///
/// The items come from a live REST API; what makes them part of LocalEyes is
/// the guide and the tour each one is tied to ([GuidePick]).
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

  /// Null means "All". Filtering happens on what is already downloaded, so
  /// switching tabs costs nothing and works offline once the feed has landed.
  GearCategory? _filter;

  List<Product> get _visible => _filter == null
      ? _products
      : _products
            .where(
              (Product p) =>
                  GearCategory.of(p.category).label == _filter!.label,
            )
            .toList();

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
        title: const Text('Guide picks'),
        actions: <Widget>[
          IconButton(
            onPressed: _loading ? null : () => _load(),
            tooltip: 'Reload',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            // The filter row only makes sense once there is something to filter.
            if (!_loading && _error == null && _products.isNotEmpty)
              _FilterRow(
                selected: _filter,
                onSelect: (GearCategory? category) =>
                    setState(() => _filter = category),
              ),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Both remaining states sit inside the same RefreshIndicator, so a pull
    // retries the request whether the feed loaded or not.
    return RefreshIndicator(
      color: context.palette.brand,
      onRefresh: () => _load(showSpinner: false),
      child: _error != null
          ? _ErrorState(message: _error!, onRetry: () => _load())
          : _ProductList(
              products: _visible,
              total: _products.length,
              onOpen: _openProduct,
              onClearFilter: () => setState(() => _filter = null),
            ),
    );
  }
}

class _ProductList extends StatelessWidget {
  const _ProductList({
    required this.products,
    required this.total,
    required this.onOpen,
    required this.onClearFilter,
  });

  final List<Product> products;

  /// How many items came back before the filter, for the header line.
  final int total;
  final void Function(Product) onOpen;
  final VoidCallback onClearFilter;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    if (products.isEmpty) {
      return ListView(
        // Keeps the pull-to-refresh alive on a short, unscrollable screen.
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          SizedBox(
            height: 420,
            child: EmptyState(
              icon: Icons.backpack_rounded,
              title: 'Nothing in this kind of kit',
              message:
                  'Nobody has listed anything here yet. '
                  'Try another kind, or pull down to reload the shop.',
              actionLabel: 'Show everything',
              onAction: onClearFilter,
            ),
          ),
        ],
      );
    }

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
            color: context.palette.surface,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Text(
              products.length == total
                  ? '$total things our guides tell you to bring · live from fakestoreapi.com'
                  : '${products.length} of $total picks · live from fakestoreapi.com',
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

/// The kit filter: same pill row as the tour feed, so the screen does not look
/// bolted on.
class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.selected, required this.onSelect});

  final GearCategory? selected;
  final ValueChanged<GearCategory?> onSelect;

  @override
  Widget build(BuildContext context) {
    // Index 0 is "All", which is why the count is one above the filter list.
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.sm,
        ),
        itemCount: GearCategory.filters.length + 1,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (BuildContext context, int index) {
          final GearCategory? category = index == 0
              ? null
              : GearCategory.filters[index - 1];
          final bool active = category?.label == selected?.label;

          return GestureDetector(
            onTap: () => onSelect(category),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: active
                    ? context.palette.brandDeep
                    : context.palette.surfaceHigh,
                borderRadius: AppRadius.pillAll,
              ),
              child: Text(
                category?.label ?? 'All',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? Colors.white : context.palette.ink,
                ),
              ),
            ),
          );
        },
      ),
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
                      decoration: BoxDecoration(
                        color: context.palette.brandTint,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cloud_off_rounded,
                        size: 34,
                        color: context.palette.brand,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'No connection to the picks',
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
