import 'json.dart';

/// The fixed vocabularies every filter is built from: tour categories, the
/// interests a traveller and a local are matched on, the city areas and the
/// public places the app suggests for a first meetup.
///
/// They come from the database too, so adding a category does not need a new
/// build of the app.
class Taxonomy {
  const Taxonomy({
    required this.tourCategories,
    required this.interests,
    required this.areas,
    required this.publicMeetingPlaces,
  });

  factory Taxonomy.fromJson(Map<String, dynamic> json) => Taxonomy(
    tourCategories: asStringList(json['tourCategories']),
    interests: asStringList(json['interests']),
    areas: asStringList(json['areas']),
    publicMeetingPlaces: asStringList(json['publicMeetingPlaces']),
  );

  static const Taxonomy empty = Taxonomy(
    tourCategories: <String>['All'],
    interests: <String>[],
    areas: <String>['All areas'],
    publicMeetingPlaces: <String>[],
  );

  final List<String> tourCategories;
  final List<String> interests;
  final List<String> areas;
  final List<String> publicMeetingPlaces;
}
