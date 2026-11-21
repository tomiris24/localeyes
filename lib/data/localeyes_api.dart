import '../models/catalog_item.dart';
import '../models/local_person.dart';
import '../models/spot.dart';
import '../models/taxonomy.dart';
import '../models/tour.dart';
import 'api_client.dart';

/// Every call the app makes to its own backend, in one place.
///
/// The screens never see a URL or a JSON map: they ask for tours and get
/// [Tour]s. Milestone 1 read the same objects out of Dart files in this
/// folder; now they come out of MongoDB.
class LocalEyesApi {
  LocalEyesApi({ApiClient? client}) : _client = client ?? ApiClient.shared;

  final ApiClient _client;

  String get baseUrl => _client.baseUrl;

  Future<List<Tour>> fetchTours({String? category, String? query}) async {
    final List<Map<String, dynamic>> body = await _client.getList(
      '/tours',
      query: <String, String>{
        if (category != null && category != 'All') 'category': category,
        if (query != null && query.isNotEmpty) 'q': query,
      },
    );
    return body.map(Tour.fromJson).toList();
  }

  Future<Tour> fetchTour(String id) async =>
      Tour.fromJson(await _client.getObject('/tours/$id'));

  Future<List<LocalPerson>> fetchLocals() async {
    final List<Map<String, dynamic>> body = await _client.getList('/locals');
    return body.map(LocalPerson.fromJson).toList();
  }

  Future<List<Spot>> fetchSpots() async {
    final List<Map<String, dynamic>> body = await _client.getList('/spots');
    return body.map(Spot.fromJson).toList();
  }

  Future<List<CatalogItem>> fetchCatalog() async {
    final List<Map<String, dynamic>> body = await _client.getList('/catalog');
    return body.map(CatalogItem.fromJson).toList();
  }

  Future<Taxonomy> fetchTaxonomy() async =>
      Taxonomy.fromJson(await _client.getObject('/taxonomy'));

  /// Pull-to-refresh: the server invents the new row, so two phones refreshing
  /// the catalog end up with the same list.
  Future<CatalogItem> addCatalogItem() async =>
      CatalogItem.fromJson(await _client.post('/catalog'));

  /// "Reset catalog" — back to the rows the database was seeded with.
  Future<List<CatalogItem>> resetCatalog() async {
    final List<Map<String, dynamic>> body = await _client.postList(
      '/catalog/reset',
    );
    return body.map(CatalogItem.fromJson).toList();
  }

  Future<void> deleteCatalogItem(String id) => _client.delete('/catalog/$id');

  /// UNDO after a swipe: the same row, with the id it had before.
  Future<CatalogItem> restoreCatalogItem(CatalogItem item) async =>
      CatalogItem.fromJson(
        await _client.post(
          '/catalog',
          body: <String, Object?>{
            'id': item.id,
            'title': item.title,
            'category': item.category,
            'rating': item.rating,
            'price': item.price,
          },
        ),
      );

  /// Sends the meetup form. The local answers it in a later milestone.
  Future<void> sendMeetupRequest({
    required String localId,
    required String travellerName,
    required String when,
    required String meetingPlace,
    required String message,
  }) => _client.post(
    '/locals/$localId/meetups',
    body: <String, Object?>{
      'travellerName': travellerName,
      'when': when,
      'meetingPlace': meetingPlace,
      'message': message,
    },
  );
}
