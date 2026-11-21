import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:localeyes/data/api_client.dart';
import 'package:localeyes/data/auth_api.dart';
import 'package:localeyes/models/account.dart';
import 'package:localeyes/screens/auth_screen.dart';
import 'package:localeyes/state/auth_controller.dart';

import 'fixtures/fake_server.dart';

late FakeServer _server;
late AuthController _auth;

/// Pumps the auth screen on a phone-sized surface, over a fake server.
Future<void> _pumpForm(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  AuthMode mode = AuthMode.register,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ChangeNotifierProvider<AuthController>.value(
      value: _auth,
      child: MaterialApp(home: AuthScreen(initialMode: mode)),
    ),
  );
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

Future<void> _submit(
  WidgetTester tester, {
  String label = 'Create account',
}) async {
  final Finder button = find.descendant(
    of: find.byType(ElevatedButton),
    matching: find.text(label),
  );
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

/// Fills every text field with data that passes validation.
Future<void> _fillValid(WidgetTester tester) async {
  await _fill(tester, 'Full name', 'Tomiris Suleimenova');
  await _fill(tester, 'Email', 'tomiris@narxoz.kz');
  await _fill(tester, 'Password', 'secret123');
  await _fill(tester, 'Confirm password', 'secret123');
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    _server = FakeServer();
    _auth = AuthController(
      api: AuthApi(client: ApiClient(client: _server.client())),
    );
  });

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
      expect(
        find.text('You have to accept the terms to register'),
        findsOneWidget,
      );
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

      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
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

      expect(
        find.text('You have to accept the terms to register'),
        findsOneWidget,
      );
      expect(find.text('Account created'), findsNothing);
    });

    testWidgets('ticking the checkbox clears its error', (
      WidgetTester tester,
    ) async {
      await _pumpForm(tester);
      await _submit(tester);
      expect(
        find.text('You have to accept the terms to register'),
        findsOneWidget,
      );

      await _acceptTerms(tester);
      expect(
        find.text('You have to accept the terms to register'),
        findsNothing,
      );
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
    testWidgets('a complete form creates the account and signs it in', (
      WidgetTester tester,
    ) async {
      await _pumpForm(tester);
      await _fillValid(tester);
      await _acceptTerms(tester);
      await _submit(tester);

      expect(_auth.status, AuthStatus.signedIn);
      expect(_auth.account?.name, 'Tomiris Suleimenova');
      expect(_auth.account?.email, 'tomiris@narxoz.kz');
      expect(_auth.account?.role, UserRole.traveller);
    });

    testWidgets('the picked role reaches the server', (
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

      expect(_auth.account?.role, UserRole.guide);
    });

    testWidgets('the session survives a restart', (WidgetTester tester) async {
      await _pumpForm(tester);
      await _fillValid(tester);
      await _acceptTerms(tester);
      await _submit(tester);

      // A second controller over the same storage and the same server: this
      // is what the app does at launch.
      final AuthController restarted = AuthController(
        api: AuthApi(client: ApiClient(client: _server.client())),
      );
      await restarted.restore();

      expect(restarted.status, AuthStatus.signedIn);
      expect(restarted.account?.email, 'tomiris@narxoz.kz');
    });
  });

  group('One account per email', () {
    testWidgets('registering a taken email offers the sign-in form instead', (
      WidgetTester tester,
    ) async {
      _server.addAccount(
        name: 'Tomiris Suleimenova',
        email: 'tomiris@narxoz.kz',
        password: 'secret123',
      );

      await _pumpForm(tester);
      await _fillValid(tester);
      await _acceptTerms(tester);
      await _submit(tester);

      expect(_auth.status, isNot(AuthStatus.signedIn));
      expect(
        find.text(
          'An account with this email already exists. Sign in instead.',
        ),
        findsOneWidget,
      );
      // Switched over, with the email still in the field and nothing left to
      // create: no name, no confirm, no terms.
      expect(find.widgetWithText(ElevatedButton, 'Sign in'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Full name'), findsNothing);
      expect(find.byType(Checkbox), findsNothing);
      expect(find.text('tomiris@narxoz.kz'), findsOneWidget);
    });
  });

  group('Signing in', () {
    testWidgets('the right password signs the account in', (
      WidgetTester tester,
    ) async {
      _server.addAccount(
        name: 'Tomiris Suleimenova',
        email: 'tomiris@narxoz.kz',
        password: 'secret123',
      );

      await _pumpForm(tester, mode: AuthMode.signIn);
      await _fill(tester, 'Email', 'tomiris@narxoz.kz');
      await _fill(tester, 'Password', 'secret123');
      await _submit(tester, label: 'Sign in');

      expect(_auth.status, AuthStatus.signedIn);
      expect(_auth.account?.name, 'Tomiris Suleimenova');
    });

    testWidgets('a wrong password says so and keeps the form', (
      WidgetTester tester,
    ) async {
      _server.addAccount(
        name: 'Tomiris Suleimenova',
        email: 'tomiris@narxoz.kz',
        password: 'secret123',
      );

      await _pumpForm(tester, mode: AuthMode.signIn);
      await _fill(tester, 'Email', 'tomiris@narxoz.kz');
      await _fill(tester, 'Password', 'nope123');
      await _submit(tester, label: 'Sign in');

      expect(_auth.status, AuthStatus.signedOut);
      expect(find.text('Wrong email or password'), findsOneWidget);
    });

    testWidgets('signing out brings the sign-in form back', (
      WidgetTester tester,
    ) async {
      _server.addAccount(
        name: 'Tomiris Suleimenova',
        email: 'tomiris@narxoz.kz',
        password: 'secret123',
      );

      await _pumpForm(tester, mode: AuthMode.signIn);
      await _fill(tester, 'Email', 'tomiris@narxoz.kz');
      await _fill(tester, 'Password', 'secret123');
      await _submit(tester, label: 'Sign in');
      expect(_auth.status, AuthStatus.signedIn);

      await _auth.signOut();
      expect(_auth.status, AuthStatus.signedOut);

      // And the device remembers there is an account, so the next launch
      // opens on "Sign in" rather than on the sign-up form.
      expect(_auth.hasAccountOnDevice, isTrue);
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
