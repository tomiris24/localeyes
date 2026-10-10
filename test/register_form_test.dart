import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:localeyes/screens/register_screen.dart';

/// Pumps the registration screen on a phone-sized surface.
Future<void> _pumpForm(WidgetTester tester, {Size size = const Size(390, 844)}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));
  await tester.pumpAndSettle();
}

/// Brings [target] on screen. On a small phone the form scrolls, and a widget
/// below the fold is not built yet, so it has to be dragged into view first.
Future<void> _scrollTo(WidgetTester tester, Finder target) async {
  if (target.evaluate().isEmpty) {
    await tester.dragUntilVisible(
      target,
      find.byType(ListView),
      const Offset(0, -120),
    );
  }
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
}

/// Types [value] into the field whose label is [label].
Future<void> _fill(WidgetTester tester, String label, String value) async {
  final Finder field = find.widgetWithText(TextFormField, label);
  await _scrollTo(tester, field);
  await tester.enterText(field, value);
  await tester.pumpAndSettle();
}

Future<void> _submit(WidgetTester tester) async {
  final Finder button = find.widgetWithText(ElevatedButton, 'Create account');
  await _scrollTo(tester, button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> _acceptTerms(WidgetTester tester) async {
  final Finder checkbox = find.byType(Checkbox);
  await _scrollTo(tester, checkbox);
  await tester.tap(checkbox);
  await tester.pumpAndSettle();
}

/// Finds [text] inside the success dialog only. The same string also sits in
/// the text field it came from, so a plain find.text would match twice.
Finder _inDialog(String text) {
  return find.descendant(
    of: find.byType(AlertDialog),
    matching: find.text(text),
  );
}

/// Fills every text field with data that passes validation.
Future<void> _fillValid(WidgetTester tester) async {
  await _fill(tester, 'Full name', 'Tomiris Suleimenova');
  await _fill(tester, 'Email', 'tomiris@narxoz.kz');
  await _fill(tester, 'Password', 'secret123');
  await _fill(tester, 'Confirm password', 'secret123');
}

void main() {
  group('Submit-time validation', () {
    testWidgets('an empty form shows an error under every field', (
      WidgetTester tester,
    ) async {
      await _pumpForm(tester);
      await _submit(tester);

      expect(find.text('Please enter your full name'), findsOneWidget);
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter a password'), findsOneWidget);
      expect(find.text('Please repeat the password'), findsOneWidget);
      expect(find.text('You have to accept the terms to register'), findsOneWidget);
    });

    testWidgets('email without @ is rejected', (WidgetTester tester) async {
      await _pumpForm(tester);
      await _fill(tester, 'Email', 'tomiris.narxoz.kz');
      await _submit(tester);

      expect(find.text('Email must contain @'), findsOneWidget);
    });

    testWidgets('email without a dot is rejected', (WidgetTester tester) async {
      await _pumpForm(tester);
      await _fill(tester, 'Email', 'tomiris@narxoz');
      await _submit(tester);

      expect(
        find.text('Email must contain a dot, for example name@narxoz.kz'),
        findsOneWidget,
      );
    });

    testWidgets('a dot before the @ is rejected', (WidgetTester tester) async {
      await _pumpForm(tester);
      await _fill(tester, 'Email', 'tomiris.s@narxoz');
      await _submit(tester);

      expect(
        find.text('Enter a valid email, for example name@narxoz.kz'),
        findsOneWidget,
      );
    });

    testWidgets('a password shorter than 6 characters is rejected', (
      WidgetTester tester,
    ) async {
      await _pumpForm(tester);
      await _fill(tester, 'Password', '12345');
      await _submit(tester);

      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('passwords that do not match are rejected', (
      WidgetTester tester,
    ) async {
      await _pumpForm(tester);
      await _fill(tester, 'Password', 'secret123');
      await _fill(tester, 'Confirm password', 'secret124');
      await _submit(tester);

      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });

  group('Terms checkbox', () {
    testWidgets('a valid form without the checkbox does not register', (
      WidgetTester tester,
    ) async {
      await _pumpForm(tester);
      await _fillValid(tester);
      await _submit(tester);

      expect(find.text('You have to accept the terms to register'), findsOneWidget);
      expect(find.text('Account created'), findsNothing);
    });

    testWidgets('ticking the checkbox clears its error', (
      WidgetTester tester,
    ) async {
      await _pumpForm(tester);
      await _submit(tester);
      expect(find.text('You have to accept the terms to register'), findsOneWidget);

      await _acceptTerms(tester);
      expect(find.text('You have to accept the terms to register'), findsNothing);
    });
  });

  group('Real-time validation', () {
    testWidgets('errors follow the typing after the first submit', (
      WidgetTester tester,
    ) async {
      await _pumpForm(tester);
      await _submit(tester);
      expect(find.text('Please enter your email'), findsOneWidget);

      // Typing a valid email clears the error without pressing the button.
      await _fill(tester, 'Email', 'tomiris@narxoz.kz');
      expect(find.text('Please enter your email'), findsNothing);

      // Breaking it again brings the error back, still without a submit.
      await _fill(tester, 'Email', 'tomiris');
      expect(find.text('Email must contain @'), findsOneWidget);
    });

    testWidgets('changing the password rechecks the confirm field', (
      WidgetTester tester,
    ) async {
      await _pumpForm(tester);
      await _fillValid(tester);
      await _submit(tester);

      // Both passwords matched, so there was no error on the confirm field.
      expect(find.text('Passwords do not match'), findsNothing);

      // Editing the first password alone must invalidate the confirm field.
      await _fill(tester, 'Password', 'something-else');
      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });

  group('Successful registration', () {
    testWidgets('a complete form shows the success dialog with the data', (
      WidgetTester tester,
    ) async {
      await _pumpForm(tester);
      await _fillValid(tester);
      await _acceptTerms(tester);
      await _submit(tester);

      expect(_inDialog('Account created'), findsOneWidget);
      expect(_inDialog('Tomiris Suleimenova'), findsOneWidget);
      expect(_inDialog('tomiris@narxoz.kz'), findsOneWidget);
      expect(_inDialog('Traveller'), findsOneWidget);
    });

    testWidgets('closing the dialog shows the welcome snack bar', (
      WidgetTester tester,
    ) async {
      await _pumpForm(tester);
      await _fillValid(tester);
      await _acceptTerms(tester);
      await _submit(tester);

      await tester.tap(find.widgetWithText(TextButton, 'Done'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Welcome to LocalEyes, Tomiris Suleimenova!'),
        findsOneWidget,
      );
    });

    testWidgets('the picked role ends up in the dialog', (
      WidgetTester tester,
    ) async {
      await _pumpForm(tester);
      await _fillValid(tester);
      await _acceptTerms(tester);

      // Open the dropdown and switch to the guide role.
      final Finder dropdown = find.byType(DropdownButtonFormField<UserRole>);
      await tester.ensureVisible(dropdown);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guide — lead tours').last);
      await tester.pumpAndSettle();

      await _submit(tester);

      expect(_inDialog('Guide'), findsOneWidget);
    });
  });

  group('No RenderFlex overflow', () {
    for (final Size size in <Size>[
      Size(320, 568), // iPhone SE (1st gen) — the hardest case
      Size(390, 844), // iPhone 14
      Size(768, 1024), // iPad portrait
      Size(1280, 800), // desktop window
    ]) {
      testWidgets('registration screen at ${size.width}x${size.height}', (
        WidgetTester tester,
      ) async {
        await _pumpForm(tester, size: size);
        expect(tester.takeException(), isNull);

        // Errors add a line under each field, which is the tallest state.
        await _submit(tester);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
