import '../models/catalog_item.dart';

/// Demo catalog data, and the generator that pull-to-refresh uses.
class CatalogSeed {
  CatalogSeed._();

  /// A fresh copy every time, so "Reset catalog" really starts over.
  static List<CatalogItem> initial() => <CatalogItem>[
    const CatalogItem(
      id: 'c1',
      title: 'Kolsai Lakes: slow hike to the second lake',
      category: 'Mountains',
      rating: 4.9,
      price: 85,
    ),
    const CatalogItem(
      id: 'c2',
      title: 'Green Bazaar tasting walk',
      category: 'Food',
      rating: 4.8,
      price: 30,
    ),
    const CatalogItem(
      id: 'c3',
      title: 'Soviet mosaics and modernism',
      category: 'Culture',
      rating: 4.7,
      price: 25,
    ),
    const CatalogItem(
      id: 'c4',
      title: 'Charyn Canyon day trip',
      category: 'Mountains',
      rating: 4.9,
      price: 95,
    ),
    const CatalogItem(
      id: 'c5',
      title: 'Old Almaty courtyards on foot',
      category: 'City walk',
      rating: 4.6,
      price: 20,
    ),
    const CatalogItem(
      id: 'c6',
      title: 'Shymbulak: first turns on the slope',
      category: 'Ski',
      rating: 4.8,
      price: 120,
    ),
    const CatalogItem(
      id: 'c7',
      title: 'Koktobe at sunset with a photographer',
      category: 'Photography',
      rating: 4.9,
      price: 45,
    ),
    const CatalogItem(
      id: 'c8',
      title: 'Zenkov Cathedral and Panfilov Park',
      category: 'Culture',
      rating: 4.5,
      price: 15,
    ),
  ];

  static const List<String> _titles = <String>[
    'Big Almaty Lake before the crowds',
    'Night market and late supper',
    'Medeu steps at dusk',
    'Street art in the western districts',
    'Butakovka waterfall, easy pace',
    'Apple orchards of Alatau',
  ];

  static const List<String> _categories = <String>[
    'Mountains',
    'Food',
    'City walk',
    'Culture',
    'Photography',
  ];

  /// Builds the item that lands at index 0 after a refresh. [seq] is just a
  /// counter from the screen, so every new id is unique.
  static CatalogItem generate(int seq) {
    final int i = (seq - 1) % _titles.length;
    return CatalogItem(
      id: 'new-$seq',
      title: _titles[i],
      category: _categories[i % _categories.length],
      // Keeps the demo data believable: 4.5 … 4.9, price 20 … 110.
      rating: 4.5 + (seq % 5) * 0.1,
      price: 20 + (seq % 10) * 10,
      isNew: true,
    );
  }
}
