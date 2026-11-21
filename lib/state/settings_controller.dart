import 'package:flutter/material.dart';

import '../data/local_store.dart';

/// The two preferences that belong to the phone rather than to the account:
/// the appearance and the name shown on the profile.
///
/// Both are read straight out of [LocalStore], which `main()` has already
/// opened — so the first frame is painted with the right theme and the right
/// name, with nothing to wait for.
class SettingsController extends ChangeNotifier {
  SettingsController() {
    _darkMode = LocalStore.darkMode;
    _displayName = LocalStore.displayName;
  }

  static SettingsController instance = SettingsController();

  bool? _darkMode;
  late String _displayName;

  /// Null until somebody touches the switch: the app follows the phone.
  bool? get darkMode => _darkMode;

  ThemeMode get themeMode => switch (_darkMode) {
    true => ThemeMode.dark,
    false => ThemeMode.light,
    null => ThemeMode.system,
  };

  /// What the switch shows before it has been touched — whatever the phone is
  /// doing right now.
  bool isDark(BuildContext context) =>
      _darkMode ?? MediaQuery.platformBrightnessOf(context) == Brightness.dark;

  String get displayName => _displayName;

  bool get hasDisplayName => LocalStore.hasDisplayName;

  Future<void> setDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
    return LocalStore.setDarkMode(value);
  }

  /// Back to following the phone's own appearance setting.
  Future<void> followSystem() {
    _darkMode = null;
    notifyListeners();
    return LocalStore.clearDarkMode();
  }

  Future<void> setDisplayName(String value) {
    _displayName = value.trim().isEmpty ? LocalStore.guestName : value.trim();
    notifyListeners();
    return LocalStore.setDisplayName(value);
  }

  /// Re-reads the disk, the way a cold start does.
  void reload() {
    _darkMode = LocalStore.darkMode;
    _displayName = LocalStore.displayName;
    notifyListeners();
  }
}
