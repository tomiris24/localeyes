import '../data/mock_tours.dart';
import 'tour.dart';

/// One tour added to the cart, together with the options the traveller picked.
///
/// Only the tour id is stored, not the whole [Tour]: the tour belongs to the
/// catalogue, the cart only remembers what was chosen about it.
class CartItem {
  const CartItem({
    required this.tourId,
    required this.guests,
    required this.date,
  });

  /// What the "add to cart" button on a card creates: one traveller, the first
  /// date the guide has free. The detail screen lets you change both.
  factory CartItem.quick(Tour tour) =>
      CartItem(tourId: tour.id, guests: 1, date: tour.availableDates.first);

  final String tourId;
  final int guests;
  final String date;

  Tour get tour => MockData.byId(tourId);
  double get total => tour.totalFor(guests);
}
