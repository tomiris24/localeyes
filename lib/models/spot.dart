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
    this.bestTime = 'Any time',
  });

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
}
