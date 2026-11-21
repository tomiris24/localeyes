import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// A request that did not come back with usable data.
///
/// Carries a message already written for the screen, so no widget has to turn
/// a `SocketException` into English itself.
class ApiException implements Exception {
  const ApiException(this.message, {this.code});

  final String message;

  /// Set when the server named the case, e.g. `email_taken`, so the screen can
  /// react instead of only showing the sentence.
  final String? code;

  @override
  String toString() => message;
}

/// Thin JSON client over the LocalEyes REST API (`server/`).
///
/// The host is a compile-time setting: the iOS simulator reaches the laptop on
/// `localhost`, an Android emulator needs `10.0.2.2`, and a phone on the same
/// Wi-Fi needs the laptop's LAN address.
///
///     flutter run --dart-define=API_BASE_URL=http://192.168.0.10:3000/api
class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      baseUrl = baseUrl ?? defaultBaseUrl;

  /// The one client the app runs on. It carries the session token, so signing
  /// in once is enough for every call the app makes afterwards.
  static ApiClient shared = ApiClient();

  static const String defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );

  final http.Client _client;
  final String baseUrl;

  /// The session token, once somebody has signed in. Every request carries it
  /// from then on, so a route that needs an account simply works.
  String? authToken;

  /// How long we wait before deciding the server is not coming back. Without
  /// it a dead connection leaves the spinner turning forever.
  static const Duration _timeout = Duration(seconds: 10);

  Future<List<Map<String, dynamic>>> getList(
    String path, {
    Map<String, String>? query,
  }) async {
    final Object? body = await _send('GET', path, query: query);
    if (body is! List) {
      throw const ApiException('The server sent something unexpected.');
    }
    return body.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getObject(
    String path, {
    Map<String, String>? query,
  }) async {
    final Object? body = await _send('GET', path, query: query);
    if (body is! Map<String, dynamic>) {
      throw const ApiException('The server sent something unexpected.');
    }
    return body;
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, Object?> body = const <String, Object?>{},
  }) async {
    final Object? response = await _send('POST', path, body: body);
    if (response is! Map<String, dynamic>) {
      throw const ApiException('The server sent something unexpected.');
    }
    return response;
  }

  Future<List<Map<String, dynamic>>> postList(
    String path, {
    Map<String, Object?> body = const <String, Object?>{},
  }) async {
    final Object? response = await _send('POST', path, body: body);
    if (response is! List) {
      throw const ApiException('The server sent something unexpected.');
    }
    return response.cast<Map<String, dynamic>>();
  }

  Future<void> delete(String path) => _send('DELETE', path);

  Future<Object?> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, Object?>? body,
  }) async {
    final Uri url = Uri.parse('$baseUrl$path')
        .replace(queryParameters: query?.isEmpty ?? true ? null : query);

    final http.Response response;
    try {
      final http.Request request = http.Request(method, url);
      final String? token = authToken;
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      if (body != null) {
        request.headers['Content-Type'] = 'application/json';
        request.body = jsonEncode(body);
      }
      final http.StreamedResponse streamed = await _client
          .send(request)
          .timeout(_timeout);
      response = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw const ApiException(
        'The server took longer than 10 seconds to answer. '
        'Check that it is running and try again.',
      );
    } on SocketException {
      throw const ApiException(
        'Cannot reach the LocalEyes server. Start it with '
        '`npm start` in server/, then retry.',
      );
    } on http.ClientException {
      throw const ApiException(
        'The connection dropped before the answer arrived. Try again.',
      );
    }

    if (response.statusCode == 204 || response.body.isEmpty) return null;

    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const ApiException('The server sent something unreadable.');
    }

    if (response.statusCode >= 400) {
      final Map<String, dynamic> error = decoded is Map<String, dynamic>
          ? decoded
          : const <String, dynamic>{};
      final Object? message = error['error'];
      final Object? code = error['code'];
      throw ApiException(
        message is String
            ? message
            : 'The server answered with ${response.statusCode}.',
        code: code is String ? code : null,
      );
    }

    return decoded;
  }

  void close() => _client.close();
}
