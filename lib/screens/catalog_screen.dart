import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../data/api_client.dart';
import '../models/catalog_item.dart';
import '../state/data_store.dart';
import '../widgets/catalog_grid_card.dart';
import '../widgets/catalog_list_tile.dart';
import '../widgets/empty_state.dart';

/// Which of the two views the catalog is showing.
enum CatalogView { list, grid }

/// The catalog screen: the same items as a lazy list or as a 2-column grid,
/// with pull-to-refresh, swipe-to-delete and undo.
///
/// Both builders are lazy on purpose. A [Column] inside a [SingleChildScrollView]
/// would build every row up front and hold them all in memory; `ListView.separated`
/// and `GridView.builder` only build the cells that are on screen plus a small
/// cache, which is what keeps a long catalog cheap on a phone.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  CatalogView _view = CatalogView.list;

  /// The rows live in the [DataStore], which is what the server answered.
  /// Every change here is sent to the API first and then shown.
  List<CatalogItem> get _items => context.watch<DataStore>().catalog;

  void _toggleView() {
    setState(() {
      _view = _view == CatalogView.list ? CatalogView.grid : CatalogView.list;
    });
  }

  /// Pull-to-refresh: the server makes the new item and it lands at the very
  /// top of the catalog.
  Future<void> _refresh() async {
    try {
      await context.read<DataStore>().addCatalogItem();
    } on ApiException catch (error) {
      _showMessage(error.message);
    }
  }

  /// Swipe-to-delete. The row is already gone from the screen by the time this
  /// runs, so we remember [index] first and hand it to UNDO.
  void _removeItem(CatalogItem item) {
    final DataStore store = context.read<DataStore>();
    final int index = store.catalog.indexOf(item);
    if (index < 0) return;

    _run(() => store.removeCatalogItem(item));

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('${item.title} removed'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'UNDO',
            textColor: Colors.white,
            onPressed: () {
              if (!mounted) return;
              // Back where it was, not on top of the list.
              _run(() => store.restoreCatalogItem(item, index));
            },
          ),
        ),
      );
  }

  void _resetCatalog() => _run(context.read<DataStore>().resetCatalog);

  /// Fire-and-forget calls to the API: the store has already moved the row, so
  /// the only thing left to do is say when the server disagreed.
  void _run(Future<void> Function() action) {
    action().onError<ApiException>((ApiException error, StackTrace _) {
      _showMessage(error.message);
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    final bool isList = _view == CatalogView.list;
    final List<CatalogItem> items = _items;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.lg,
        title: const Text('Catalog'),
        actions: <Widget>[
          // The toggle between the two views.
          IconButton(
            onPressed: _toggleView,
            tooltip: isList ? 'Grid view' : 'List view',
            icon: Icon(
              isList ? Icons.grid_view_rounded : Icons.view_list_rounded,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: items.isEmpty
                ? _buildEmpty()
                : (isList ? _buildList(items) : _buildGrid(items)),
          ),
        ),
      ),
    );
  }

  /// Lazy list with a thin divider between the rows.
  Widget _buildList(List<CatalogItem> items) {
    return ListView.separated(
      // Lets the user pull down even when the rows do not fill the screen.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      itemCount: items.length,
      separatorBuilder: (BuildContext context, int index) =>
          Divider(height: 1, thickness: 1, color: context.palette.line),
      itemBuilder: (BuildContext context, int index) {
        final CatalogItem item = items[index];
        return Dismissible(
          // The key has to identify the item, not its position — without it
          // Flutter would animate away the wrong row after a removal.
          key: ValueKey<String>(item.id),
          direction: DismissDirection.endToStart,
          background: _buildDeleteBackground(),
          onDismissed: (DismissDirection direction) => _removeItem(item),
          child: CatalogListTile(item: item),
        );
      },
    );
  }

  /// What shows up under the item while it is being swiped away. The grid
  /// cells are rounded, so the red block has to be rounded too or it would
  /// stick out at the corners.
  Widget _buildDeleteBackground({BorderRadius? borderRadius}) {
    return Container(
      decoration: BoxDecoration(color: Colors.red, borderRadius: borderRadius),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppSpacing.xl),
      child: const Icon(Icons.delete, color: Colors.white, size: 26),
    );
  }

  /// Two columns, built lazily.
  Widget _buildGrid(List<CatalogItem> items) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        // Taller than it is wide, which is what the card content needs.
        childAspectRatio: 0.72,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        final CatalogItem item = items[index];
        // The cells are swipeable too, so a long-tour card can be thrown away
        // without switching back to the list first.
        return Dismissible(
          key: ValueKey<String>(item.id),
          direction: DismissDirection.endToStart,
          background: _buildDeleteBackground(borderRadius: AppRadius.cardAll),
          onDismissed: (DismissDirection direction) => _removeItem(item),
          child: CatalogGridCard(item: item),
        );
      },
    );
  }

  /// Shown when every item has been swiped away. It still scrolls, so
  /// pull-to-refresh keeps working on an empty catalog.
  Widget _buildEmpty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.7,
          child: EmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'Catalog is Empty',
            message:
                'You swiped everything away. Pull down to load something new, '
                'or put the demo items back.',
            actionLabel: 'Reset Catalog',
            onAction: _resetCatalog,
          ),
        ),
      ],
    );
  }
}
