import 'package:flutter/foundation.dart';

import '../data/api_client.dart';
import '../data/localeyes_api.dart';
import '../models/catalog_item.dart';
import '../models/local_person.dart';
import '../models/spot.dart';
import '../models/taxonomy.dart';
import '../models/tour.dart';

/// Where the app is in its first conversation with the server.
enum DataStatus { idle, loading, ready, failed }

/// Everything the app shows, read from the REST API once at startup and kept
/// in memory afterwards.
///
/// Milestone 1 had the same lists as `const` data in `lib/data/`. The screens
/// still read them the same way — synchronously, in `build` — but the truth
/// now lives in MongoDB and arrives over HTTP. The one-off load happens behind
/// [StartupGate], so no screen has to handle "not loaded yet".
class DataStore extends ChangeNotifier {
  DataStore({LocalEyesApi? api}) : _api = api ?? LocalEyesApi();

  /// A store that is already full. Widget tests build one from the seed files
  /// and install it as [instance], so nothing in a test touches the network.
  factory DataStore.ready({
    List<Tour> tours = const <Tour>[],
    List<LocalPerson> people = const <LocalPerson>[],
    List<Spot> spots = const <Spot>[],
    List<CatalogItem> catalog = const <CatalogItem>[],
    Taxonomy taxonomy = Taxonomy.empty,
    LocalEyesApi? api,
  }) {
    return DataStore(api: api)
      .._tours = tours
      .._people = people
      .._spots = spots
      .._catalog = catalog
      .._taxonomy = taxonomy
      .._status = DataStatus.ready;
  }

  /// The instance the app runs on. Models and plain state objects reach it
  /// here, where there is no [BuildContext] to look it up with; widgets get
  /// the same object from the provider.
  static DataStore instance = DataStore();

  final LocalEyesApi _api;

  DataStatus _status = DataStatus.idle;
  String? _error;

  List<Tour> _tours = <Tour>[];
  List<LocalPerson> _people = <LocalPerson>[];
  List<Spot> _spots = <Spot>[];
  List<CatalogItem> _catalog = <CatalogItem>[];
  Taxonomy _taxonomy = Taxonomy.empty;

  DataStatus get status => _status;
  String? get error => _error;
  bool get isReady => _status == DataStatus.ready;

  List<Tour> get tours => List<Tour>.unmodifiable(_tours);
  List<LocalPerson> get people => List<LocalPerson>.unmodifiable(_people);
  List<Spot> get spots => List<Spot>.unmodifiable(_spots);
  List<CatalogItem> get catalog => List<CatalogItem>.unmodifiable(_catalog);
  Taxonomy get taxonomy => _taxonomy;

  List<String> get categories => _taxonomy.tourCategories;
  List<String> get interests => _taxonomy.interests;
  List<String> get areas => _taxonomy.areas;
  List<String> get publicMeetingPlaces => _taxonomy.publicMeetingPlaces;

  /// Pulls the whole dataset in one round of parallel requests. Five small
  /// collections on a phone: one wait, and every screen is ready.
  Future<void> load() async {
    _status = DataStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final List<Object> results = await Future.wait(<Future<Object>>[
        _api.fetchTours(),
        _api.fetchLocals(),
        _api.fetchSpots(),
        _api.fetchCatalog(),
        _api.fetchTaxonomy(),
      ]);
      _tours = results[0] as List<Tour>;
      _people = results[1] as List<LocalPerson>;
      _spots = results[2] as List<Spot>;
      _catalog = results[3] as List<CatalogItem>;
      _taxonomy = results[4] as Taxonomy;
      _status = DataStatus.ready;
    } on ApiException catch (error) {
      _error = error.message;
      _status = DataStatus.failed;
    }
    notifyListeners();
  }

  Tour tourById(String id) => _tours.firstWhere(
    (Tour tour) => tour.id == id,
    orElse: () => throw StateError('No tour with id $id'),
  );

  LocalPerson localById(String id) => _people.firstWhere(
    (LocalPerson person) => person.id == id,
    orElse: () => throw StateError('No local with id $id'),
  );

  List<Spot> spotsBy(String localId) =>
      _spots.where((Spot spot) => spot.addedById == localId).toList();

  /// Pull-to-refresh on the catalog: the server makes the row, we put it on
  /// top the way the screen expects.
  Future<CatalogItem> addCatalogItem() async {
    final CatalogItem item = await _api.addCatalogItem();
    _catalog = <CatalogItem>[item, ..._catalog];
    notifyListeners();
    return item;
  }

  Future<void> removeCatalogItem(CatalogItem item) async {
    _catalog = _catalog.where((CatalogItem c) => c.id != item.id).toList();
    notifyListeners();
    await _api.deleteCatalogItem(item.id);
  }

  /// UNDO: the row lands back on its old index, not on top.
  Future<void> restoreCatalogItem(CatalogItem item, int index) async {
    final List<CatalogItem> next = List<CatalogItem>.of(_catalog);
    next.insert(index.clamp(0, next.length), item);
    _catalog = next;
    notifyListeners();
    await _api.restoreCatalogItem(item);
  }

  Future<void> resetCatalog() async {
    _catalog = await _api.resetCatalog();
    notifyListeners();
  }

  Future<void> sendMeetupRequest({
    required String localId,
    required String travellerName,
    required String when,
    required String meetingPlace,
    required String message,
  }) => _api.sendMeetupRequest(
    localId: localId,
    travellerName: travellerName,
    when: when,
    meetingPlace: meetingPlace,
    message: message,
  );
}
