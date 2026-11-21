import '../models/account.dart';
import 'api_client.dart';

/// What the server answers a sign-in or a sign-up with: the account and the
/// token every later request carries.
class Session {
  const Session({required this.account, required this.token});

  final Account account;
  final String token;
}

/// Accounts: register, sign in, and "is this token still good?".
class AuthApi {
  AuthApi({ApiClient? client}) : _client = client ?? ApiClient.shared;

  final ApiClient _client;

  Future<Session> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async => _session(
    await _client.post(
      '/auth/register',
      body: <String, Object?>{
        'name': name,
        'email': email,
        'password': password,
        'role': role.name,
      },
    ),
  );

  Future<Session> signIn({
    required String email,
    required String password,
  }) async => _session(
    await _client.post(
      '/auth/login',
      body: <String, Object?>{'email': email, 'password': password},
    ),
  );

  /// The token the app kept from last time, checked against the server.
  Future<Account> me(String token) async {
    final String? previous = _client.authToken;
    _client.authToken = token;
    try {
      final Map<String, dynamic> body = await _client.getObject('/auth/me');
      return Account.fromJson(
        body['user'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      );
    } on ApiException {
      _client.authToken = previous;
      rethrow;
    }
  }

  Session _session(Map<String, dynamic> body) {
    final Session session = Session(
      account: Account.fromJson(
        body['user'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      token: body['token'] as String? ?? '',
    );
    _client.authToken = session.token;
    return session;
  }

  void forgetToken() => _client.authToken = null;
}
