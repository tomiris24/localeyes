import 'package:shared_preferences/shared_preferences.dart';

/// Everything the app keeps on the phone itself, in one place.
///
/// The store is opened once, in `main()`, before the first frame — see
/// [init]. That matters for the theme: reading the saved appearance
/// asynchronously after `runApp` would paint one white frame before the dark
/// theme arrives, which is exactly the flicker this avoids.
///
/// It holds preferences and a cache, never a secret in the security sense:
/// `SharedPreferences` is a plain plist on iOS and an XML file on Android,
/// readable on a rooted or jailbroken device. The session token lives here
/// too for now ([tokenKey]) — the Keychain / Android Keystore is where it
/// belongs once the app ships.
class LocalStore {
  LocalStore._();

  /// Dark mode: true, false, or absent, which means "follow the phone".
  static const String themeKey = 'app_theme_dark_mode';

  /// What the traveller wants to be called on this device.
  static const String nameKey = 'user_display_name';

  /// The notes list, as one JSON string.
  static const String notesKey = 'trip_notes';

  static const String tokenKey = 'auth.token';
  static const String hasAccountKey = 'auth.hasAccount';

  static const String guestName = 'Guest User';

  static SharedPreferences? _prefs;

  /// Opens the store. Called from `main()` before `runApp`, so every read
  /// below is synchronous afterwards and no screen needs a FutureBuilder.
  static Future<SharedPreferences> init() async =>
      _prefs ??= await SharedPreferences.getInstance();

  /// Throws if the store was not opened — a programming error, not something
  /// to handle at runtime.
  static SharedPreferences get prefs {
    final SharedPreferences? prefs = _prefs;
    if (prefs == null) {
      throw StateError('LocalStore.init() must run before runApp()');
    }
    return prefs;
  }

  /// Drops the cached instance. Tests call it between cases, together with
  /// `SharedPreferences.setMockInitialValues`.
  static void reset() => _prefs = null;

  // --- Appearance ---------------------------------------------------------

  /// Null when nothing was chosen: the app then follows the phone.
  static bool? get darkMode => prefs.getBool(themeKey);

  static Future<void> setDarkMode(bool value) => prefs.setBool(themeKey, value);

  static Future<void> clearDarkMode() => prefs.remove(themeKey);

  // --- Display name -------------------------------------------------------

  static String get displayName => prefs.getString(nameKey) ?? guestName;

  static bool get hasDisplayName =>
      (prefs.getString(nameKey) ?? '').trim().isNotEmpty;

  static Future<void> setDisplayName(String value) =>
      prefs.setString(nameKey, value.trim());

  // --- Notes --------------------------------------------------------------

  static String? get notesJson => prefs.getString(notesKey);

  static Future<void> setNotesJson(String value) =>
      prefs.setString(notesKey, value);
}
