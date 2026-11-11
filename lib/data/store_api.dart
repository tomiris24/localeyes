import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/product.dart';

/// A request that did not end with a usable list of products.
///
/// Carries a message that is already written for the screen, so the UI never
/// has to translate a `SocketException` into English itself.
class StoreException implements Exception {
  const StoreException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thin client over the Fake Store REST API.
class StoreApi {
  StoreApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static final Uri _productsUrl = Uri.parse(
    'https://fakestoreapi.com/products',
  );

  /// How long we wait before deciding the network is not coming back. Without
  /// it a dead connection leaves the spinner turning forever.
  static const Duration _timeout = Duration(seconds: 10);

  Future<List<Product>> fetchProducts() async {
    final http.Response response;
    try {
      response = await _client.get(_productsUrl).timeout(_timeout);
    } on TimeoutException {
      throw const StoreException(
        'The store took longer than 10 seconds to answer. '
        'Check your connection and try again.',
      );
    } on SocketException {
      throw const StoreException(
        "You're offline. Reconnect to the internet and retry.",
      );
    } on http.ClientException {
      throw const StoreException(
        "Couldn't reach the store. Check your connection and retry.",
      );
    }

    switch (response.statusCode) {
      case 200:
        break;
      case 404:
        throw const StoreException(
          'The store catalogue is no longer at this address (404).',
        );
      case >= 500:
        throw StoreException(
          'The store is having trouble right now (${response.statusCode}). '
          'Try again in a moment.',
        );
      default:
        throw StoreException(
          'The store answered with ${response.statusCode}, which we cannot use.',
        );
    }

    try {
      final Object? decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw const StoreException('The store sent something unexpected.');
      }
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Product.fromJson)
          .toList();
    } on FormatException {
      throw const StoreException(
        'The store sent a response we could not read.',
      );
    }
  }

  void dispose() => _client.close();
}
