import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../state/auth_controller.dart';
import 'auth_screen.dart';
import 'startup_gate.dart';

/// The first fork in the app: signed in, or not.
///
/// Nobody sees a tour before they have an account. At launch the stored token
/// is checked with the server ([AuthController.restore]); while that is in
/// flight this is a spinner, after it the traveller gets either the app
/// ([StartupGate], which then loads the data) or [AuthScreen]. Signing out
/// flips the same switch, so the sign-in form comes back without any
/// navigation of its own.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    // After the first frame: `restore` notifies listeners, and notifying while
    // the tree is still building is an error.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final AuthController auth = context.read<AuthController>();
      if (auth.status == AuthStatus.unknown) auth.restore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AuthController auth = context.watch<AuthController>();

    return switch (auth.status) {
      AuthStatus.signedIn => const StartupGate(),
      AuthStatus.signedOut => const AuthScreen(),
      AuthStatus.unknown => Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: context.palette.brand),
        ),
      ),
    };
  }
}
