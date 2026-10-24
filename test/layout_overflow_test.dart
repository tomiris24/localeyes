import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:localeyes/data/mock_tours.dart';
import 'package:localeyes/main.dart';
import 'package:localeyes/models/tour.dart';
import 'package:localeyes/screens/tour_detail_screen.dart';
import 'package:localeyes/state/app_state.dart';
import 'package:localeyes/widgets/tour_card.dart';

/// Screen sizes we promise to support: from a small iPhone SE to a desktop window.
const List<Size> _sizes = <Size>[
  Size(320, 568), // iPhone SE (1st gen) — the hardest case
  Size(360, 640), // small Android
  Size(390, 844), // iPhone 14
  Size(430, 932), // iPhone 15 Pro Max
  Size(768, 1024), // iPad portrait
  Size(1280, 800), // tablet landscape / desktop window
];

/// The app opens on the Locals tab, so anything about tours starts by
/// switching to Explore.
Future<void> _openExplore(WidgetTester tester) async {
  await tester.tap(find.text('Explore'));
  await tester.pumpAndSettle();
}

Future<void> _setSize(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
}

void main() {
  group('No RenderFlex overflow', () {
    for (final Size size in _sizes) {
      testWidgets('home, saved and profile at ${size.width}x${size.height}', (
        WidgetTester tester,
      ) async {
        await _setSize(tester, size);
        await tester.pumpWidget(const LocalEyesApp());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Explore tab.
        await tester.tap(find.text('Explore'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Saved tab.
        await tester.tap(find.text('Saved'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Profile tab.
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('every tour detail at ${size.width}x${size.height}', (
        WidgetTester tester,
      ) async {
        await _setSize(tester, size);

        for (final Tour tour in MockData.tours) {
          await tester.pumpWidget(
            AppScope(
              notifier: AppState(),
              child: MaterialApp(home: TourDetailScreen(tour: tour)),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: tour.title);

          // Open every tab of the detail screen.
          for (final String tab in <String>['Route', 'Reviews', 'About']) {
            final Finder tabFinder = find.text(tab);
            await tester.ensureVisible(tabFinder);
            await tester.pumpAndSettle();
            await tester.tap(tabFinder);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: '$tab · ${tour.title}');
          }

          // Scroll the whole page: an overflow below the fold still counts.
          await tester.dragUntilVisible(
            find.text('Travellers'),
            find.byType(SingleChildScrollView).first,
            const Offset(0, -220),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'bottom · ${tour.title}');
        }
      });
    }
  });

  group('Interactivity', () {
    testWidgets('bookmark badge saves a tour and the saved tab shows it', (
      WidgetTester tester,
    ) async {
      await _setSize(tester, const Size(390, 844));
      await tester.pumpWidget(const LocalEyesApp());
      await tester.pumpAndSettle();

      // One tour is bookmarked in the demo data.
      await tester.tap(find.text('Saved'));
      await tester.pumpAndSettle();
      expect(find.byType(TourCard), findsOneWidget);

      // Un-save it from the saved screen.
      await tester.tap(find.byIcon(Icons.bookmark_rounded).first);
      await tester.pumpAndSettle();
      expect(find.byType(TourCard), findsNothing);
      expect(find.text('Nothing saved yet'), findsOneWidget);
    });

    testWidgets('group size changes the total price in the sticky bar', (
      WidgetTester tester,
    ) async {
      await _setSize(tester, const Size(390, 844));
      final Tour tour = MockData.tours.first;

      await tester.pumpWidget(
        AppScope(
          notifier: AppState(),
          child: MaterialApp(home: TourDetailScreen(tour: tour)),
        ),
      );
      await tester.pumpAndSettle();

      // Default is 2 travellers.
      expect(
        find.text('\$${(tour.pricePerPerson * 2).toStringAsFixed(0)}'),
        findsOneWidget,
      );

      await tester.scrollUntilVisible(find.text('Travellers'), 300);
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      expect(
        find.text('\$${(tour.pricePerPerson * 3).toStringAsFixed(0)}'),
        findsOneWidget,
      );
    });

    testWidgets('adding to cart fills the cart badge', (
      WidgetTester tester,
    ) async {
      await _setSize(tester, const Size(390, 844));
      await tester.pumpWidget(const LocalEyesApp());
      await tester.pumpAndSettle();
      await _openExplore(tester);

      await tester.tap(find.byType(TourCard).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add to cart'));
      await tester.pumpAndSettle();

      // Back via the AppBar arrow.
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
    });
  });

  group('Navigation', () {
    testWidgets('tapping a tour pushes the detail screen with its data', (
      WidgetTester tester,
    ) async {
      await _setSize(tester, const Size(390, 844));
      await tester.pumpWidget(const LocalEyesApp());
      await tester.pumpAndSettle();
      await _openExplore(tester);

      expect(find.byType(TourDetailScreen), findsNothing);

      // The feed passes the whole Tour object to the pushed screen.
      final Tour tour = MockData.tours.first;
      await tester.tap(find.byType(TourCard).first);
      await tester.pumpAndSettle();

      final TourDetailScreen detail = tester.widget<TourDetailScreen>(
        find.byType(TourDetailScreen),
      );
      expect(detail.tour.id, tour.id);
      expect(find.text(tour.summary), findsOneWidget);
      expect(find.text(tour.category), findsOneWidget);
      expect(
        find.text('\$${tour.pricePerPerson.toStringAsFixed(0)}'),
        findsOneWidget,
      );
    });

    testWidgets('both back buttons pop back to the feed', (
      WidgetTester tester,
    ) async {
      await _setSize(tester, const Size(390, 844));

      for (final String how in <String>['appbar', 'body']) {
        await tester.pumpWidget(const LocalEyesApp());
        await tester.pumpAndSettle();
        await _openExplore(tester);

        await tester.tap(find.byType(TourCard).first);
        await tester.pumpAndSettle();
        expect(find.byType(TourDetailScreen), findsOneWidget, reason: how);

        if (how == 'appbar') {
          await tester.tap(find.byType(BackButton));
        } else {
          final Finder button = find.widgetWithText(
            OutlinedButton,
            'Back to tours',
          );
          await tester.scrollUntilVisible(button, 400);
          await tester.tap(button);
        }
        await tester.pumpAndSettle();

        expect(find.byType(TourDetailScreen), findsNothing, reason: how);
        expect(find.byType(TourCard), findsWidgets, reason: how);
      }
    });

    testWidgets('coming back keeps the tab and the search text', (
      WidgetTester tester,
    ) async {
      await _setSize(tester, const Size(390, 844));
      await tester.pumpWidget(const LocalEyesApp());
      await tester.pumpAndSettle();
      await _openExplore(tester);

      // Type a search, open a tour, come back: the text is still there.
      await tester.enterText(find.byType(TextField).first, 'canyon');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TourCard).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('canyon'), findsOneWidget);
    });
  });
}
