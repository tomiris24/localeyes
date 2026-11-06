import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:localeyes/data/catalog_seed.dart';
import 'package:localeyes/models/catalog_item.dart';
import 'package:localeyes/screens/catalog_screen.dart';
import 'package:localeyes/widgets/catalog_grid_card.dart';
import 'package:localeyes/widgets/catalog_list_tile.dart';

const List<Size> _sizes = <Size>[
  Size(320, 568), // iPhone SE (1st gen) — the hardest case
  Size(390, 844), // iPhone 14
  Size(768, 1024), // iPad portrait
];

Future<void> _setSize(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
}

Future<void> _pumpCatalog(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: CatalogScreen()));
  await tester.pumpAndSettle();
}

/// The titles currently on screen, top to bottom — that is how we check an
/// item came back at its old position and not on top of the list.
List<String> _visibleTitles(WidgetTester tester) => tester
    .widgetList<CatalogListTile>(find.byType(CatalogListTile))
    .map((CatalogListTile tile) => tile.item.title)
    .toList();

Future<void> _pullToRefresh(WidgetTester tester) async {
  await tester.fling(find.byType(ListView), const Offset(0, 320), 1000);
  await tester.pump(); // start the indicator
  await tester.pump(const Duration(seconds: 1)); // let it settle in
  await tester.pump(const Duration(seconds: 2)); // past the 1500 ms delay
  await tester.pumpAndSettle();
}

void main() {
  group('Lazy builders', () {
    testWidgets('the list is a ListView.separated with dividers', (
      WidgetTester tester,
    ) async {
      await _setSize(tester, const Size(390, 844));
      await _pumpCatalog(tester);

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(CatalogListTile), findsWidgets);
      // separatorBuilder puts a Divider between the rows.
      expect(find.byType(Divider), findsWidgets);
    });

    testWidgets('the toggle swaps the list for a 2-column grid', (
      WidgetTester tester,
    ) async {
      await _setSize(tester, const Size(390, 844));
      await _pumpCatalog(tester);

      await tester.tap(find.byIcon(Icons.grid_view_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(CatalogGridCard), findsWidgets);

      final GridView grid = tester.widget<GridView>(find.byType(GridView));
      final SliverGridDelegateWithFixedCrossAxisCount delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 2);
      expect(delegate.childAspectRatio, 0.72);

      // And back to the list.
      await tester.tap(find.byIcon(Icons.view_list_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(ListView), findsOneWidget);
    });

    for (final Size size in _sizes) {
      testWidgets('no overflow in either view at ${size.width}x${size.height}', (
        WidgetTester tester,
      ) async {
        await _setSize(tester, size);
        await _pumpCatalog(tester);
        expect(tester.takeException(), isNull, reason: 'list');

        await tester.tap(find.byIcon(Icons.grid_view_rounded));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'grid');

        await tester.drag(find.byType(GridView), const Offset(0, -400));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'grid scrolled');
      });
    }
  });

  group('Pull to refresh', () {
    testWidgets('adds the new item at index 0', (WidgetTester tester) async {
      await _setSize(tester, const Size(390, 844));
      await _pumpCatalog(tester);

      final String firstBefore = _visibleTitles(tester).first;
      final CatalogItem generated = CatalogSeed.generate(1);

      await _pullToRefresh(tester);

      final List<String> after = _visibleTitles(tester);
      expect(after.first, generated.title);
      expect(after[1], firstBefore);
    });
  });

  group('Swipe to delete and undo', () {
    testWidgets('swiping removes the row and UNDO puts it back in place', (
      WidgetTester tester,
    ) async {
      await _setSize(tester, const Size(390, 844));
      await _pumpCatalog(tester);

      final List<String> before = _visibleTitles(tester);
      // Second row, so "back at its original index" means something.
      final String target = before[1];

      await tester.drag(find.text(target), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(find.text(target), findsNothing);
      expect(find.text('UNDO'), findsOneWidget);

      await tester.tap(find.text('UNDO'));
      await tester.pumpAndSettle();

      final List<String> after = _visibleTitles(tester);
      expect(after[1], target, reason: 'came back at its old position');
      expect(after.take(before.length), before);
    });

    testWidgets('a grid cell can be swiped away too, and UNDO restores it', (
      WidgetTester tester,
    ) async {
      await _setSize(tester, const Size(390, 844));
      await _pumpCatalog(tester);

      await tester.tap(find.byIcon(Icons.grid_view_rounded));
      await tester.pumpAndSettle();

      final int before = find.byType(CatalogGridCard).evaluate().length;
      final CatalogGridCard target = tester.widget<CatalogGridCard>(
        find.byType(CatalogGridCard).first,
      );

      await tester.drag(find.byType(CatalogGridCard).first, const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(find.byType(CatalogGridCard), findsNWidgets(before - 1));

      await tester.tap(find.text('UNDO'));
      await tester.pumpAndSettle();

      expect(find.byType(CatalogGridCard), findsNWidgets(before));
      final CatalogGridCard first = tester.widget<CatalogGridCard>(
        find.byType(CatalogGridCard).first,
      );
      expect(first.item.id, target.item.id, reason: 'back at its old position');
    });

    testWidgets('every row carries a ValueKey built from the item id', (
      WidgetTester tester,
    ) async {
      await _setSize(tester, const Size(390, 844));
      await _pumpCatalog(tester);

      final Dismissible first = tester.widget<Dismissible>(
        find.byType(Dismissible).first,
      );
      expect(first.key, isA<ValueKey<String>>());
      expect(first.direction, DismissDirection.endToStart);
    });
  });

  group('Empty state', () {
    testWidgets('swiping everything away shows it, and Reset brings it back', (
      WidgetTester tester,
    ) async {
      await _setSize(tester, const Size(390, 844));
      await _pumpCatalog(tester);

      final int total = CatalogSeed.initial().length;
      for (int i = 0; i < total; i++) {
        await tester.drag(find.byType(CatalogListTile).first, const Offset(-500, 0));
        await tester.pumpAndSettle();
      }

      expect(find.text('Catalog is Empty'), findsOneWidget);
      expect(find.byType(CatalogListTile), findsNothing);

      await tester.tap(find.text('Reset Catalog'));
      await tester.pumpAndSettle();

      expect(find.text('Catalog is Empty'), findsNothing);
      expect(find.byType(CatalogListTile), findsWidgets);
    });
  });
}
