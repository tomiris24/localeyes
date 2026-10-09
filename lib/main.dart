import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'screens/home_shell.dart';
import 'state/app_state.dart';

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
    return AppScope(
      notifier: _appState,
      child: MaterialApp(
        title: 'LocalEyes',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const HomeShell(),
      ),
    );
  }
}
