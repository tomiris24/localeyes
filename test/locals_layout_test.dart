import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:localeyes/data/mock_locals.dart';
import 'package:localeyes/main.dart';
import 'package:localeyes/models/local_person.dart';
import 'package:localeyes/screens/become_local_screen.dart';
import 'package:localeyes/screens/local_profile_screen.dart';
import 'package:localeyes/screens/meetup_request_screen.dart';
import 'package:localeyes/screens/spots_screen.dart';
import 'package:localeyes/state/app_state.dart';
import 'package:localeyes/widgets/local_card.dart';

/// The same screen sizes the tour screens promise to support.
const List<Size> _sizes = <Size>[
  Size(320, 568), // iPhone SE (1st gen) — the hardest case
  Size(360, 640), // small Android
  Size(390, 844), // iPhone 14
  Size(430, 932), // iPhone 15 Pro Max
  Size(768, 1024), // iPad portrait
  Size(1280, 800), // tablet landscape / desktop window
];

Future<void> _setSize(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
}

/// Wraps a screen in everything it needs to be pumped on its own.
Widget _wrap(Widget child) =>
    AppScope(notifier: AppState(), child: MaterialApp(home: child));

/// Drags the page to the end, because the bottom of a long form is where a
/// row usually runs out of width.
Future<void> _scrollToBottom(WidgetTester tester) async {
  final Finder list = find.byType(Scrollable).first;
  for (int i = 0; i < 6; i++) {
    await tester.drag(list, const Offset(0, -400));
    await tester.pumpAndSettle();
  }
}

void main() {
  group('No RenderFlex overflow on the locals screens', () {
    for (final Size size in _sizes) {
      testWidgets('locals feed at ${size.width}x${size.height}', (
        WidgetTester tester,
      ) async {
        await _setSize(tester, size);
        await tester.pumpWidget(const LocalEyesApp());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await _scrollToBottom(tester);
        expect(tester.takeException(), isNull);
      });

      testWidgets('every local profile at ${size.width}x${size.height}', (
        WidgetTester tester,
      ) async {
        await _setSize(tester, size);

        for (final LocalPerson person in MockLocals.people) {
          await tester.pumpWidget(
            _wrap(LocalProfileScreen(person: person)),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: person.name);

          await _scrollToBottom(tester);
          expect(tester.takeException(), isNull, reason: person.name);
        }
      });

      testWidgets('spots and the meetup request at ${size.width}x${size.height}', (
        WidgetTester tester,
      ) async {
        await _setSize(tester, size);

        await tester.pumpWidget(_wrap(const SpotsScreen()));
        await tester.pumpAndSettle();
        await _scrollToBottom(tester);
        expect(tester.takeException(), isNull, reason: 'spots');

        await tester.pumpWidget(
          _wrap(MeetupRequestScreen(person: MockLocals.people.first)),
        );
        await tester.pumpAndSettle();
        await _scrollToBottom(tester);
        expect(tester.takeException(), isNull, reason: 'meetup request');
      });

      testWidgets('become a local, every field in error, at '
          '${size.width}x${size.height}', (WidgetTester tester) async {
        await _setSize(tester, size);
        await tester.pumpWidget(_wrap(const BecomeLocalScreen()));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Submitting an empty form puts every validator message on screen,
        // which is the tallest the page can get.
        final Finder publish = find.widgetWithText(
          ElevatedButton,
          'Put me on the map',
        );
        await tester.scrollUntilVisible(
          publish,
          400,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(publish);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await _scrollToBottom(tester);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Meeting a local', () {
    testWidgets('the availability filter only lets matching people through', (
      WidgetTester tester,
    ) async {
      await _setSize(tester, const Size(390, 844));
      await tester.pumpWidget(const LocalEyesApp());
      await tester.pumpAndSettle();

      for (final Availability when in <Availability>[
        Availability.today,
        Availability.tomorrow,
        Availability.weekend,
      ]) {
        // The filter row scrolls sideways, so "Weekend" starts off screen
        // on a narrow phone.
        await tester.dragUntilVisible(
          find.text(when.shortLabel),
          find.byType(ListView).at(1),
          const Offset(-120, 0),
        );
        await tester.tap(find.text(when.shortLabel));
        await tester.pumpAndSettle();

        final List<LocalCard> shown = tester
            .widgetList<LocalCard>(find.byType(LocalCard))
            .toList();
        expect(shown, isNotEmpty, reason: when.shortLabel);
        expect(
          shown.every((LocalCard c) => c.person.availability == when),
          isTrue,
          reason: when.shortLabel,
        );
      }
    });

    testWidgets('tapping a person pushes their profile with the whole object', (
      WidgetTester tester,
    ) async {
      await _setSize(tester, const Size(390, 844));
      await tester.pumpWidget(const LocalEyesApp());
      await tester.pumpAndSettle();

      expect(find.byType(LocalProfileScreen), findsNothing);

      final LocalCard card = tester.widget<LocalCard>(
        find.byType(LocalCard).first,
      );
      await tester.tap(find.byType(LocalCard).first);
      await tester.pumpAndSettle();

      final LocalProfileScreen profile = tester.widget<LocalProfileScreen>(
        find.byType(LocalProfileScreen),
      );
      expect(profile.person.id, card.person.id);
      expect(find.text(card.person.bio), findsOneWidget);
    });

    testWidgets('a request needs a message and then reaches the app state', (
      WidgetTester tester,
    ) async {
      await _setSize(tester, const Size(390, 844));
      final AppState state = AppState();
      final LocalPerson person = MockLocals.people.first;

      await tester.pumpWidget(
        AppScope(
          notifier: state,
          child: MaterialApp(home: MeetupRequestScreen(person: person)),
        ),
      );
      await tester.pumpAndSettle();

      final Finder send = find.widgetWithText(
        ElevatedButton,
        'Send the request',
      );

      // Sending an empty request is refused.
      await tester.scrollUntilVisible(
        send,
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(send);
      await tester.pumpAndSettle();
      expect(state.meetups, isEmpty);

      await tester.enterText(
        find.byType(TextFormField).first,
        'Hi! I am in Almaty for four days and I would love a coffee and a chat.',
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        send,
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(send);
      await tester.pumpAndSettle();

      expect(state.meetups, hasLength(1));
      expect(state.meetups.first.localId, person.id);
      expect(state.hasPendingMeetupWith(person.id), isTrue);
    });

    testWidgets('the heart on a profile writes through to the shared state', (
      WidgetTester tester,
    ) async {
      await _setSize(tester, const Size(390, 844));
      final AppState state = AppState();
      final LocalPerson person = MockLocals.people.first;

      await tester.pumpWidget(
        AppScope(
          notifier: state,
          child: MaterialApp(home: LocalProfileScreen(person: person)),
        ),
      );
      await tester.pumpAndSettle();
      expect(state.isLocalSaved(person.id), isFalse);

      await tester.tap(find.byIcon(Icons.favorite_border_rounded));
      await tester.pumpAndSettle();

      expect(state.isLocalSaved(person.id), isTrue);
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    });
  });
}
