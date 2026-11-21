import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/api_client.dart';
import '../data/auth_api.dart';
import '../data/local_store.dart';
import '../models/account.dart';

/// Whether anybody is signed in — and whether we know yet.
enum AuthStatus { unknown, signedOut, signedIn }

/// The session: who is signed in, and the token that proves it.
///
/// The token is kept in `SharedPreferences`, so closing the app does not sign
/// anybody out; the first thing the app does at launch is ask the server
/// whether that token is still good.
class AuthController extends ChangeNotifier {
  AuthController({AuthApi? api}) : _api = api ?? AuthApi();

  /// The instance the app runs on, the way [DataStore] works.
  static AuthController instance = AuthController();

  static const String _tokenKey = LocalStore.tokenKey;
  static const String _hasAccountKey = LocalStore.hasAccountKey;

  final AuthApi _api;

  AuthStatus _status = AuthStatus.unknown;
  Account? _account;
  String? _error;
  bool _busy = false;

  /// True once somebody has registered on this device. The auth screen then
  /// opens on "Sign in" instead of the sign-up form.
  bool _hasAccount = false;

  AuthStatus get status => _status;
  Account? get account => _account;
  String? get error => _error;
  bool get isBusy => _busy;
  bool get hasAccountOnDevice => _hasAccount;

  /// Reads the stored token and checks it with the server. Called once, at
  /// launch, before anything else is shown.
  Future<void> restore() async {
    final SharedPreferences prefs = await LocalStore.init();
    _hasAccount = prefs.getBool(_hasAccountKey) ?? false;
    final String? token = prefs.getString(_tokenKey);

    if (token == null || token.isEmpty) {
      _settle(AuthStatus.signedOut);
      return;
    }

    try {
      _account = await _api.me(token);
      _settle(AuthStatus.signedIn);
    } on ApiException {
      // Expired or rejected: start clean rather than keep a dead token.
      await prefs.remove(_tokenKey);
      _api.forgetToken();
      _settle(AuthStatus.signedOut);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) => _run(
    () =>
        _api.register(name: name, email: email, password: password, role: role),
  );

  Future<bool> signIn({required String email, required String password}) =>
      _run(() => _api.signIn(email: email, password: password));

  Future<void> signOut() async {
    final SharedPreferences prefs = await LocalStore.init();
    await prefs.remove(_tokenKey);
    _api.forgetToken();
    _account = null;
    _error = null;
    _settle(AuthStatus.signedOut);
  }

  /// The one path both forms take: show the spinner, call the server, keep the
  /// token, or hand the message back to the form.
  Future<bool> _run(Future<Session> Function() call) async {
    _busy = true;
    _error = null;
    notifyListeners();

    try {
      final Session session = await call();
      final SharedPreferences prefs = await LocalStore.init();
      await prefs.setString(_tokenKey, session.token);
      await prefs.setBool(_hasAccountKey, true);
      _hasAccount = true;
      _account = session.account;
      _busy = false;
      _settle(AuthStatus.signedIn);
      return true;
    } on ApiException catch (error) {
      _error = error.message;
      _errorCode = error.code;
      _busy = false;
      // A refused attempt still answers the gate's question: nobody is in.
      _settle(AuthStatus.signedOut);
      return false;
    }
  }

  String? _errorCode;

  /// `email_taken` — the account is already there, so the screen offers to
  /// sign in instead of trying to create a second one.
  String? get errorCode => _errorCode;

  void clearError() {
    if (_error == null) return;
    _error = null;
    _errorCode = null;
    notifyListeners();
  }

  void _settle(AuthStatus status) {
    _status = status;
    notifyListeners();
  }
}
