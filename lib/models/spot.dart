import 'json.dart';

/// A place in the city as a resident sees it.
///
/// A spot is not a tour and not an attraction listing: the point is [why] —
/// the reason this particular person cares about it.
class Spot {
  const Spot({
    required this.id,
    required this.name,
    required this.area,
    required this.kind,
    required this.why,
    required this.addedById,
    required this.addedByName,
    required this.saveCount,
    required this.lat,
    required this.lng,
    this.bestTime = 'Any time',
  });

  factory Spot.fromJson(Map<String, dynamic> json) => Spot(
    id: asString(json['id']),
    name: asString(json['name'], 'A place in the city'),
    area: asString(json['area']),
    kind: asString(json['kind']),
    why: asString(json['why']),
    addedById: asString(json['addedById']),
    addedByName: asString(json['addedByName']),
    saveCount: asInt(json['saveCount']),
    bestTime: asString(json['bestTime'], 'Any time'),
    lat: asDouble(json['lat']),
    lng: asDouble(json['lng']),
  );

  final String id;
  final String name;
  final String area;

  /// Short category: "Bazaar", "Viewpoint", "Canteen", "Courtyard".
  final String kind;

  /// The local's own sentence about the place, shown as a quote.
  final String why;

  final String addedById;
  final String addedByName;
  final int saveCount;
  final String bestTime;

  /// Where the place is, so the map tab can pin it.
  final double lat;
  final double lng;
}
