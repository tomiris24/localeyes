import 'dart:convert';
import 'dart:io';

import 'package:localeyes/models/catalog_item.dart';
import 'package:localeyes/models/local_person.dart';
import 'package:localeyes/models/spot.dart';
import 'package:localeyes/models/taxonomy.dart';
import 'package:localeyes/models/tour.dart';
import 'package:localeyes/data/api_client.dart';
import 'package:localeyes/data/auth_api.dart';
import 'package:localeyes/data/local_store.dart';
import 'package:localeyes/data/localeyes_api.dart';
import 'package:localeyes/state/auth_controller.dart';
import 'package:localeyes/state/settings_controller.dart';
import 'package:localeyes/state/data_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_server.dart';

/// The same JSON the database is seeded with (`server/seed/`), read straight
/// off disk.
///
/// Widget tests need data without a server, and inventing a second set would
/// let the fixtures drift away from what the app really receives. This way a
/// field that changes in the seed changes in the tests too.
class SeedData {
  SeedData._();

  static List<Object?> _list(String name) =>
      jsonDecode(File('server/seed/$name.json').readAsStringSync())
          as List<Object?>;

  static Map<String, dynamic> _object(String name) =>
      jsonDecode(File('server/seed/$name.json').readAsStringSync())
          as Map<String, dynamic>;

  static List<Tour> get tours =>
      _list('tours').cast<Map<String, dynamic>>().map(Tour.fromJson).toList();

  static List<LocalPerson> get people =>
      _list('locals')
          .cast<Map<String, dynamic>>()
          .map(LocalPerson.fromJson)
          .toList();

  static List<Spot> get spots =>
      _list('spots').cast<Map<String, dynamic>>().map(Spot.fromJson).toList();

  static List<CatalogItem> get catalog =>
      _list('catalog')
          .cast<Map<String, dynamic>>()
          .map(CatalogItem.fromJson)
          .toList();

  static Taxonomy get taxonomy => Taxonomy.fromJson(_object('taxonomy'));

  /// Puts the app in the state a signed-in traveller sees: a [DataStore]
  /// filled from a [FakeServer] and a session on it, the way `main.dart`
  /// restores one at launch. Everything the test then does goes through the
  /// same JSON the server sends.
  static Future<DataStore> installApp({
    Map<String, Object> storage = const <String, Object>{},
  }) async {
    // The phone's storage, as `main()` opens it before the first frame.
    SharedPreferences.setMockInitialValues(storage);
    LocalStore.reset();
    await LocalStore.init();
    SettingsController.instance = SettingsController();

    final FakeServer server = FakeServer();

    final DataStore store = DataStore(
      api: LocalEyesApi(client: ApiClient(client: server.client())),
    );
    await store.load();
    DataStore.instance = store;

    server.addAccount(
      name: 'Tomiris Suleimenova',
      email: 'tomiris@narxoz.kz',
      password: 'secret123',
    );
    final AuthController auth = AuthController(
      api: AuthApi(client: ApiClient(client: server.client())),
    );
    await auth.signIn(email: 'tomiris@narxoz.kz', password: 'secret123');
    AuthController.instance = auth;

    return store;
  }
}
