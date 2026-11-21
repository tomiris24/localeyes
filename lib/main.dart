import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'data/local_store.dart';
import 'screens/auth_gate.dart';
import 'state/app_state.dart';
import 'state/auth_controller.dart';
import 'state/cart_provider.dart';
import 'state/data_store.dart';
import 'state/notes_controller.dart';
import 'state/settings_controller.dart';

Future<void> main() async {
  // The storage has to be open before the first frame: reading the saved
  // appearance after `runApp` would paint one light frame and then repaint
  // dark, which is the flicker everybody notices on a cold start.
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStore.init();

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
  final NotesController _notes = NotesController();

  @override
  void dispose() {
    _appState.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The cart provider sits above MaterialApp, so every route pushed by the
    // navigator — including the ones that open on top of a tab — finds the
    // same CartProvider instance. `create` builds it once for the life of the
    // app and disposes it for us.
    //
    // DataStore joins it: one object holding what the server answered, shared
    // the same way. It is the singleton, so the models that have no context
    // (a cart line looking up its tour) read the very same data.
    return ChangeNotifierProvider<CartProvider>(
      create: (BuildContext context) => CartProvider(),
      child: ChangeNotifierProvider<DataStore>.value(
        value: DataStore.instance,
        child: ChangeNotifierProvider<AuthController>.value(
          value: AuthController.instance,
          child: ChangeNotifierProvider<NotesController>.value(
            value: _notes,
            child: ChangeNotifierProvider<SettingsController>.value(
              value: SettingsController.instance,
              child: AppScope(
                notifier: _appState,
                child: Consumer<SettingsController>(
                  builder:
                      (
                        BuildContext context,
                        SettingsController settings,
                        Widget? child,
                      ) => MaterialApp(
                        title: 'LocalEyes',
                        debugShowCheckedModeBanner: false,
                        // Both themes ship. The switch on the profile wins;
                        // until it is touched the app follows the phone.
                        theme: AppTheme.light(),
                        darkTheme: AppTheme.dark(),
                        themeMode: settings.themeMode,
                        home: const AuthGate(),
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
