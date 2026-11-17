import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// A route that could not be built, with a message already written for the UI.
class RouteException implements Exception {
  const RouteException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// A line through the chosen spots, as the road network actually runs.
class CityRoute {
  const CityRoute({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;

  String get distanceLabel => distanceMeters < 1000
      ? '${distanceMeters.round()} m'
      : '${(distanceMeters / 1000).toStringAsFixed(1)} km';

  String get durationLabel {
    final int minutes = (durationSeconds / 60).round();
    if (minutes < 60) return '$minutes min';
    return '${minutes ~/ 60} h ${minutes % 60} min';
  }
}

/// Routing through the public OSRM demo server: no key, no account.
///
/// Its demo instance only carries the driving network, so the time it returns
/// is a drive, not a walk — the UI says so rather than pretending otherwise.
class RouteApi {
  RouteApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const Duration _timeout = Duration(seconds: 10);

  Future<CityRoute> fetchRoute(List<LatLng> stops) async {
    if (stops.length < 2) {
      throw const RouteException('Pick at least two places for a route.');
    }

    // OSRM wants lng,lat — the opposite order to everything else here.
    final String path = stops
        .map((LatLng p) => '${p.longitude},${p.latitude}')
        .join(';');
    final Uri url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/$path'
      '?overview=full&geometries=geojson',
    );

    final http.Response response;
    try {
      response = await _client.get(url).timeout(_timeout);
    } on TimeoutException {
      throw const RouteException(
        'The routing service took too long. Try again in a moment.',
      );
    } on SocketException {
      throw const RouteException(
        "You're offline, so the route cannot be built.",
      );
    } on http.ClientException {
      throw const RouteException("Couldn't reach the routing service.");
    }

    if (response.statusCode != 200) {
      throw RouteException(
        'The routing service answered with ${response.statusCode}.',
      );
    }

    try {
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (json['code'] != 'Ok') {
        throw const RouteException('No route runs through these places.');
      }

      final List<dynamic> routes = json['routes'] as List<dynamic>;
      if (routes.isEmpty) {
        throw const RouteException('No route runs through these places.');
      }

      final Map<String, dynamic> route = routes.first as Map<String, dynamic>;
      final List<dynamic> coordinates =
          (route['geometry'] as Map<String, dynamic>)['coordinates']
              as List<dynamic>;

      return CityRoute(
        points: <LatLng>[
          for (final dynamic pair in coordinates)
            LatLng(
              ((pair as List<dynamic>)[1] as num).toDouble(),
              (pair[0] as num).toDouble(),
            ),
        ],
        distanceMeters: (route['distance'] as num).toDouble(),
        durationSeconds: (route['duration'] as num).toDouble(),
      );
    } on RouteException {
      rethrow;
    } catch (_) {
      // Any shape we did not expect lands here rather than as a red screen.
      throw const RouteException(
        'The routing service sent something we could not read.',
      );
    }
  }

  void dispose() => _client.close();
}
