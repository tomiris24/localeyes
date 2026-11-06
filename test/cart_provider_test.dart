import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:localeyes/data/mock_tours.dart';
import 'package:localeyes/main.dart';
import 'package:localeyes/models/cart_item.dart';
import 'package:localeyes/models/tour.dart';
import 'package:localeyes/screens/cart_screen.dart';
import 'package:localeyes/state/cart_provider.dart';
import 'package:localeyes/widgets/cart_badge_button.dart';
import 'package:localeyes/widgets/cart_toggle_button.dart';

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

/// The real app, wired exactly as `main.dart` wires it — provider included.
Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const LocalEyesApp());
  await tester.pumpAndSettle();
}

/// Takes the confirmation SnackBar off the screen.
///
/// `pumpAndSettle` is not enough on its own: once the SnackBar has slid in,
/// nothing is animating any more and the timer that hides it schedules no
/// frames, so the bar just sits there — floating over the feed and swallowing
/// the next tap.
Future<void> _dismissSnackBars(WidgetTester tester) async {
  final Finder messenger = find.byType(ScaffoldMessenger);
  if (messenger.evaluate().isEmpty) return;
  tester.state<ScaffoldMessengerState>(messenger.first).clearSnackBars();
  await tester.pumpAndSettle();
}

/// Scrolls [finder] into the viewport before tapping it.
///
/// The feed scrolls under the bottom navigation bar, so the button of the card
/// at the bottom of the screen is there but not hittable — exactly as it is
/// for a real thumb.
Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Taps the first card whose button still says "Add to cart", so calling it
/// twice adds two different tours.
///
/// The feed is lazy: once the cards on screen are all in the cart, the next
/// "Add to cart" button is not built yet, so it has to be scrolled to first.
Future<void> _addFirstAvailable(WidgetTester tester) async {
  final Finder add = find.widgetWithText(ElevatedButton, 'Add to cart');
  await _scrollUntilFound(tester, add, -400);
  await _tapVisible(tester, add.first);
  await _dismissSnackBars(tester);
}

/// Drags the feed by [dy] until [finder] has something to match, at most ten
/// times. The feed is lazy, so a widget further down — or the header further
/// up — simply is not in the tree until it is scrolled to.
Future<void> _scrollUntilFound(
  WidgetTester tester,
  Finder finder,
  double dy,
) async {
  for (int i = 0; i < 10 && finder.evaluate().isEmpty; i++) {
    await tester.drag(find.byType(Scrollable).first, Offset(0, dy));
    await tester.pumpAndSettle();
  }
}

/// Brings the cart button back on screen.
///
/// The feed's header scrolls away with the content, so after adding a tour
/// further down the list the badge has to be scrolled back to.
Future<void> _showBadge(WidgetTester tester) async {
  // `hitTestable`: on a tall screen the header is still built just above the
  // viewport, so "exists in the tree" is not the same as "can be tapped".
  await _scrollUntilFound(
    tester,
    find.byType(CartBadgeButton).hitTestable(),
    600,
  );
}

/// What the badge on the feed's app bar is showing, or null when it shows
/// nothing.
Future<String?> _badgeText(WidgetTester tester) async {
  await _showBadge(tester);
  final Finder badge = find.descendant(
    of: find.byType(CartBadgeButton),
    matching: find.byType(Text),
  );
  if (badge.evaluate().isEmpty) return null;
  return tester.widget<Text>(badge.first).data;
}

Future<void> _openCart(WidgetTester tester) async {
  await _showBadge(tester);
  await tester.tap(find.byType(CartBadgeButton));
  await tester.pumpAndSettle();
}

void main() {
  final List<Tour> tours = MockData.tours;

  group('CartProvider', () {
    test('toggle puts a tour in and takes it back out', () {
      final CartProvider cart = CartProvider();

      expect(cart.toggle(tours[0]), isTrue);
      expect(cart.count, 1);
      expect(cart.contains(tours[0].id), isTrue);

      expect(cart.toggle(tours[0]), isFalse);
      expect(cart.count, 0);
      expect(cart.contains(tours[0].id), isFalse);
    });

    test('a quick add takes one traveller and the first free date', () {
      final CartProvider cart = CartProvider();
      cart.toggle(tours[0]);

      final CartItem item = cart.items.single;
      expect(item.guests, 1);
      expect(item.date, tours[0].availableDates.first);
      expect(item.total, tours[0].pricePerPerson);
    });

    test('adding the same tour again replaces the options, not the row', () {
      final CartProvider cart = CartProvider();
      cart.toggle(tours[0]);
      cart.add(
        CartItem(
          tourId: tours[0].id,
          guests: 3,
          date: tours[0].availableDates.last,
        ),
      );

      expect(cart.count, 1, reason: 'still one row for that tour');
      expect(cart.items.single.guests, 3);
      expect(cart.total, tours[0].pricePerPerson * 3);
    });

    test('total adds the lines up, travellers included', () {
      final CartProvider cart = CartProvider();
      cart.add(CartItem(tourId: tours[0].id, guests: 2, date: 'Fri, 12 Jul'));
      cart.add(CartItem(tourId: tours[1].id, guests: 1, date: 'Sat, 13 Jul'));

      expect(cart.total, tours[0].pricePerPerson * 2 + tours[1].pricePerPerson);
      expect(cart.totalLabel, '\$${cart.total.toStringAsFixed(0)}');
    });

    test('remove takes out one tour, clear takes out all of them', () {
      final CartProvider cart = CartProvider();
      cart.toggle(tours[0]);
      cart.toggle(tours[1]);

      cart.remove(tours[0].id);
      expect(cart.count, 1);
      expect(cart.contains(tours[1].id), isTrue);

      cart.clear();
      expect(cart.isEmpty, isTrue);
      expect(cart.total, 0);
    });

    test('every change notifies the listeners once', () {
      final CartProvider cart = CartProvider();
      int notifications = 0;
      cart.addListener(() => notifications++);

      cart.toggle(tours[0]); // 1
      cart.toggle(tours[1]); // 2
      cart.remove(tours[1].id); // 3
      cart.remove('nothing-with-this-id'); // not in the cart — no notification
      cart.clear(); // 4
      cart.clear(); // already empty — no notification

      expect(notifications, 4);
    });

    test('the items list cannot be modified from the outside', () {
      final CartProvider cart = CartProvider();
      cart.toggle(tours[0]);
      expect(
        () => cart.items.add(CartItem.quick(tours[1])),
        throwsUnsupportedError,
      );
    });
  });

  group('Screen 1 — the feed with the live badge', () {
    testWidgets('the provider sits above MaterialApp', (
      WidgetTester tester,
    ) async {
      await _setSize(tester, const Size(390, 844));
      await _pumpApp(tester);

      expect(
        find.ancestor(
          of: find.byType(MaterialApp),
          matching: find.byType(ChangeNotifierProvider<CartProvider>),
        ),
        findsOneWidget,
      );
    });

    testWidgets('every card carries a toggle, and the cart starts empty', (
      WidgetTester tester,
    ) async {
      await _setSize(tester, const Size(390, 844));
      await _pumpApp(tester);

      expect(find.byType(CartToggleButton), findsWidgets);
      expect(await _badgeText(tester), isNull, reason: 'empty cart shows no badge');
    });

    testWidgets('the badge counts up as tours are added', (
      WidgetTester tester,
    ) async {
      await _setSize(tester, const Size(390, 844));
      await _pumpApp(tester);

      await _addFirstAvailable(tester);
      expect(await _badgeText(tester), '1');

      await _addFirstAvailable(tester);
      expect(await _badgeText(tester), '2');

      // The card that was added now offers to take the tour back out.
      expect(find.widgetWithText(OutlinedButton, 'In cart'), findsWidgets);
    });

    testWidgets('the toggle also removes, and the badge follows', (
      WidgetTester tester,
    ) async {
      await _setSize(tester, const Size(390, 844));
      await _pumpApp(tester);

      await _addFirstAvailable(tester);
      expect(await _badgeText(tester), '1');

      await _tapVisible(
        tester,
        find.widgetWithText(OutlinedButton, 'In cart').first,
      );
      await _dismissSnackBars(tester);

      expect(await _badgeText(tester), isNull);
    });
  });

  group('Screen 2 — cart view', () {
    testWidgets('lists what was added, with the total', (
      WidgetTester tester,
    ) async {
      await _setSize(tester, const Size(390, 844));
      await _pumpApp(tester);

      await _addFirstAvailable(tester);
      await _addFirstAvailable(tester);
      await _openCart(tester);

      expect(find.byType(CartScreen), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsNWidgets(2));
      expect(find.text('2 tours · deposit 20%'), findsOneWidget);
    });

    testWidgets('an empty cart shows the empty state and no Clear All', (
      WidgetTester tester,
    ) async {
      await _setSize(tester, const Size(390, 844));
      await _pumpApp(tester);
      await _openCart(tester);

      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.text('Clear All'), findsNothing);
    });
  });

  group('The screens share one cart', () {
    testWidgets('removing on the cart screen is already true on the feed', (
      WidgetTester tester,
    ) async {
      await _setSize(tester, const Size(390, 844));
      await _pumpApp(tester);

      await _addFirstAvailable(tester);
      await _addFirstAvailable(tester);
      expect(await _badgeText(tester), '2');

      await _openCart(tester);

      await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);

      // Back to the feed — the badge and the buttons already know.
      await tester.pageBack();
      await tester.pumpAndSettle();

      // _badgeText scrolls back to the header, so the first card is on screen:
      // the tour that was deleted offers "Add to cart" again.
      expect(await _badgeText(tester), '1');
      expect(find.widgetWithText(ElevatedButton, 'Add to cart'), findsWidgets);

      // And the one that stayed in the cart is still marked, further down.
      await _scrollUntilFound(
        tester,
        find.widgetWithText(OutlinedButton, 'In cart'),
        -400,
      );
      expect(find.widgetWithText(OutlinedButton, 'In cart'), findsOneWidget);
    });

    testWidgets('the detail screen writes to the same cart', (
      WidgetTester tester,
    ) async {
      await _setSize(tester, const Size(390, 844));
      await _pumpApp(tester);

      // Open the first tour and add it from the booking bar.
      await _tapVisible(tester, find.text(tours.first.title));
      expect(find.text('Add to cart'), findsOneWidget);

      await tester.tap(find.text('Add to cart'));
      await tester.pumpAndSettle();

      // The bar switched to "Update cart" without the screen tracking it.
      expect(find.text('Update cart'), findsOneWidget);

      await _dismissSnackBars(tester);
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(await _badgeText(tester), '1');
      expect(find.widgetWithText(OutlinedButton, 'In cart'), findsOneWidget);
    });

    testWidgets('Clear All empties the cart on both screens, with an UNDO', (
      WidgetTester tester,
    ) async {
      await _setSize(tester, const Size(390, 844));
      await _pumpApp(tester);

      await _addFirstAvailable(tester);
      await _addFirstAvailable(tester);
      await _addFirstAvailable(tester);
      expect(await _badgeText(tester), '3');

      await _openCart(tester);
      await tester.tap(find.text('Clear All'));
      await tester.pumpAndSettle();

      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.text('3 tours removed'), findsOneWidget);

      // UNDO puts the whole cart back.
      await tester.tap(find.text('UNDO'));
      await tester.pumpAndSettle();
      expect(find.text('Your cart is empty'), findsNothing);
      expect(find.byIcon(Icons.delete_outline_rounded), findsNWidgets(3));

      // Clear it again and walk back to the feed.
      await tester.tap(find.text('Clear All'));
      await tester.pumpAndSettle();
      await _dismissSnackBars(tester);
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(await _badgeText(tester), isNull);
      expect(find.widgetWithText(OutlinedButton, 'In cart'), findsNothing);
    });
  });

  group('No RenderFlex overflow', () {
    for (final Size size in _sizes) {
      testWidgets('feed and cart at ${size.width}x${size.height}', (
        WidgetTester tester,
      ) async {
        await _setSize(tester, size);
        await _pumpApp(tester);
        expect(tester.takeException(), isNull, reason: 'feed with the toggles');

        await _addFirstAvailable(tester);
        await _addFirstAvailable(tester);
        expect(tester.takeException(), isNull, reason: 'feed with a full cart');

        await _openCart(tester);
        expect(tester.takeException(), isNull, reason: 'cart');

        await tester.drag(find.byType(ListView), const Offset(0, -300));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'cart scrolled');
      });
    }
  });
}
