import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:localeyes/data/api_client.dart';
import 'package:localeyes/data/localeyes_api.dart';
import 'package:localeyes/state/data_store.dart';

/// The REST API of `server/`, answered in memory from the seed files.
///
/// Widget tests cannot reach MongoDB, but they should not fake the data layer
/// away either: the app still encodes a request, decodes JSON and builds its
/// models. Only the socket is replaced.
class FakeServer {
  FakeServer() {
    _catalog = _seedList('catalog');
  }

  /// The titles the real server hands out on pull-to-refresh, in the same
  /// order — a test can say which one it expects to see.
  static const List<String> generatedTitles = <String>[
    'Big Almaty Lake before the crowds',
    'Night market and late supper',
    'Medeu steps at dusk',
    'Street art in the western districts',
    'Butakovka waterfall, easy pace',
    'Apple orchards of Alatau',
  ];

  static const List<String> _generatedCategories = <String>[
    'Mountains',
    'Food',
    'City walk',
    'Culture',
    'Photography',
  ];

  late List<Map<String, dynamic>> _catalog;
  int _created = 0;

  /// The accounts this fake server knows, by email — the same one-per-email
  /// rule the real `users` collection has.
  final Map<String, Map<String, dynamic>> _users =
      <String, Map<String, dynamic>>{};

  static List<Map<String, dynamic>> _seedList(String name) =>
      (jsonDecode(File('server/seed/$name.json').readAsStringSync())
              as List<Object?>)
          .cast<Map<String, dynamic>>()
          .map((Map<String, dynamic> item) => <String, dynamic>{...item})
          .toList();

  static Map<String, dynamic> _seedObject(String name) =>
      jsonDecode(File('server/seed/$name.json').readAsStringSync())
          as Map<String, dynamic>;

  DataStore buildStore() => DataStore(
    api: LocalEyesApi(client: ApiClient(client: client())),
  );

  /// Puts an account in place, so a test can sign in without registering
  /// first.
  void addAccount({
    required String name,
    required String email,
    required String password,
    String role = 'traveller',
  }) {
    _users[email.toLowerCase()] = <String, dynamic>{
      'id': 'u${_users.length + 1}',
      'name': name,
      'email': email.toLowerCase(),
      'password': password,
      'role': role,
    };
  }

  http.Client client() => MockClient((http.Request request) async {
    final String path = request.url.path.replaceFirst('/api', '');

    if (path.startsWith('/auth')) return _auth(request, path);

    if (request.method == 'GET') {
      return switch (path) {
        '/tours' => _json(_seedList('tours')),
        '/locals' => _json(_seedList('locals')),
        '/spots' => _json(_seedList('spots')),
        '/catalog' => _json(_catalog),
        '/taxonomy' => _json(_seedObject('taxonomy')),
        _ => _notFound(),
      };
    }

    if (request.method == 'POST' && path == '/catalog/reset') {
      _catalog = _seedList('catalog');
      return _json(_catalog);
    }

    if (request.method == 'POST' && path == '/catalog') {
      final Map<String, dynamic> body =
          jsonDecode(request.body) as Map<String, dynamic>;
      final int i = _created % generatedTitles.length;
      _created++;
      final Map<String, dynamic> item = <String, dynamic>{
        'id': body['id'] ?? 'c-new-$_created',
        'title': body['title'] ?? generatedTitles[i],
        'category':
            body['category'] ??
            _generatedCategories[i % _generatedCategories.length],
        'rating': body['rating'] ?? 4.6,
        'price': body['price'] ?? 40,
        'isNew': body['id'] == null,
      };
      _catalog = <Map<String, dynamic>>[item, ..._catalog];
      return _json(item, status: 201);
    }

    if (request.method == 'DELETE' && path.startsWith('/catalog/')) {
      final String id = path.substring('/catalog/'.length);
      _catalog = _catalog
          .where((Map<String, dynamic> item) => item['id'] != id)
          .toList();
      return http.Response('', 204);
    }

    if (request.method == 'POST' && path.endsWith('/meetups')) {
      return _json(<String, dynamic>{'status': 'pending'}, status: 201);
    }

    return _notFound();
  });

  Future<http.Response> _auth(http.Request request, String path) async {
    final Map<String, dynamic> body = request.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(request.body) as Map<String, dynamic>;
    final String email = (body['email'] as String? ?? '').toLowerCase();

    if (request.method == 'POST' && path == '/auth/register') {
      if (_users.containsKey(email)) {
        return _json(<String, String>{
          'error':
              'An account with this email already exists. Sign in instead.',
          'code': 'email_taken',
        }, status: 409);
      }
      addAccount(
        name: body['name'] as String? ?? '',
        email: email,
        password: body['password'] as String? ?? '',
        role: body['role'] as String? ?? 'traveller',
      );
      return _json(_session(email), status: 201);
    }

    if (request.method == 'POST' && path == '/auth/login') {
      final Map<String, dynamic>? user = _users[email];
      if (user == null || user['password'] != body['password']) {
        return _json(<String, String>{
          'error': 'Wrong email or password',
        }, status: 401);
      }
      return _json(_session(email));
    }

    if (request.method == 'GET' && path == '/auth/me') {
      final String token =
          request.headers['Authorization']?.replaceFirst('Bearer ', '') ?? '';
      final Map<String, dynamic>? user =
          _users[token.replaceFirst('token-', '')];
      if (user == null) {
        return _json(<String, String>{
          'error': 'Your session has expired',
        }, status: 401);
      }
      return _json(<String, dynamic>{'user': _public(user)});
    }

    return _notFound();
  }

  Map<String, dynamic> _session(String email) => <String, dynamic>{
    'token': 'token-$email',
    'user': _public(_users[email]!),
  };

  Map<String, dynamic> _public(Map<String, dynamic> user) => <String, dynamic>{
    'id': user['id'],
    'name': user['name'],
    'email': user['email'],
    'role': user['role'],
  };

  http.Response _json(Object? body, {int status = 200}) => http.Response(
    jsonEncode(body),
    status,
    headers: <String, String>{'content-type': 'application/json'},
  );

  http.Response _notFound() =>
      _json(<String, String>{'error': 'Not found'}, status: 404);
}
