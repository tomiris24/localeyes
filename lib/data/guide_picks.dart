import '../models/guide.dart';
import '../models/product.dart';
import '../models/tour.dart';
import '../state/data_store.dart';

/// Why a piece of kit is in the app at all: a guide suggested it for one of
/// their tours.
///
/// The catalogue comes from a public API that knows nothing about Almaty, so
/// the pairing is derived from the product id. That keeps it stable between
/// launches and between pull-to-refreshes — the same item never changes hands.
class GuidePick {
  const GuidePick({required this.tour, required this.note});

  final Tour tour;

  /// One line in the guide's own voice, picked by the kind of item.
  final String note;

  Guide get guide => tour.guide;

  factory GuidePick.forProduct(Product product) {
    final List<Tour> tours = DataStore.instance.tours;
    final List<String> notes = _notesFor(product.category);
    return GuidePick(
      tour: tours[product.id % tours.length],
      note: notes[product.id % notes.length],
    );
  }

  static List<String> _notesFor(String apiCategory) => switch (apiCategory
      .toLowerCase()) {
    "men's clothing" || "women's clothing" => const <String>[
      'The lake is ten degrees colder than the city. Bring a layer you can '
          'take off on the way up.',
      'Wind comes down the valley after four. Long sleeves, even in July.',
      'Nothing white — the trail dust gets into everything.',
    ],
    'electronics' => const <String>[
      'Charge it the night before. There is no socket between the village '
          'and the second lake.',
      'Keep it in an inside pocket: the cold eats the battery fast up there.',
    ],
    'jewelery' || 'jewellery' => const <String>[
      'A small gift travels well — the families we eat with always notice.',
      'Leave the heavy pieces in the hotel safe and take one thing you like.',
    ],
    _ => const <String>[
      'Pack light. Everything you carry, you carry up the climb as well.',
    ],
  };
}
