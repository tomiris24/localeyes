import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'screens/home_shell.dart';
import 'state/app_state.dart';
import 'state/cart_provider.dart';

void main() {
  runApp(const LocalEyesApp());
}

/// LocalEyes — a marketplace that helps travellers choose the right local
/// guide, and helps independent guides get steady bookings.
class LocalEyesApp extends StatefulWidget {
  const LocalEyesApp({super.key});

  @override
  State<LocalEyesApp> createState() => _LocalEyesAppState();
}

class _LocalEyesAppState extends State<LocalEyesApp> {
  final AppState _appState = AppState();

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The cart provider sits above MaterialApp, so every route pushed by the
    // navigator — including the ones that open on top of a tab — finds the
    // same CartProvider instance. `create` builds it once for the life of the
    // app and disposes it for us.
    return ChangeNotifierProvider<CartProvider>(
      create: (BuildContext context) => CartProvider(),
      child: AppScope(
        notifier: _appState,
        child: MaterialApp(
          title: 'LocalEyes',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          home: const HomeShell(),
        ),
      ),
    );
  }
}
