import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/tour.dart';

/// The cart, shared by every screen through `ChangeNotifierProvider`.
///
/// This is the one place that knows what has been added. The feed, the detail
/// screen and the cart screen never keep their own copy — they read this
/// object and rebuild when it calls [notifyListeners], which is why removing a
/// tour on the cart screen has already flipped the button on the card behind
/// it before the back arrow is pressed.
class CartProvider extends ChangeNotifier {
  /// Keyed by tour id, so the same tour cannot sit in the cart twice.
  /// A `Map` in Dart keeps insertion order, so the cart lists the tours in the
  /// order they were added.
  final Map<String, CartItem> _items = <String, CartItem>{};

  /// The cart contents, in the order they were added. Unmodifiable, so no
  /// screen can change the cart behind the provider's back and skip the
  /// notification.
  List<CartItem> get items => List<CartItem>.unmodifiable(_items.values);

  /// What the badge on the app bar shows.
  int get count => _items.length;

  bool get isEmpty => _items.isEmpty;

  /// Sum of every line in the cart — price per person × travellers.
  double get total =>
      _items.values.fold(0, (double sum, CartItem item) => sum + item.total);

  String get totalLabel => '\$${total.toStringAsFixed(0)}';

  /// Whether this tour is already in the cart. The "Add to cart" buttons read
  /// this to decide which of their two states to draw.
  bool contains(String tourId) => _items.containsKey(tourId);

  /// Adds the tour with the chosen date and group size, or replaces what was
  /// there — that is what "Update cart" on the detail screen does.
  void add(CartItem item) {
    _items[item.tourId] = item;
    notifyListeners();
  }

  /// The toggle on a tour card: one tap puts the tour in with its default
  /// options, the next takes it back out.
  ///
  /// Returns true when the tour ends up in the cart, so the caller can show
  /// the right message.
  bool toggle(Tour tour) {
    final bool nowInCart = !_items.containsKey(tour.id);
    if (nowInCart) {
      _items[tour.id] = CartItem.quick(tour);
    } else {
      _items.remove(tour.id);
    }
    notifyListeners();
    return nowInCart;
  }

  /// Used by the delete button next to each row of the cart screen.
  void remove(String tourId) {
    if (_items.remove(tourId) == null) return;
    notifyListeners();
  }

  /// "Clear All". Does nothing — and notifies nobody — on an already empty
  /// cart, so no screen rebuilds for no reason.
  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }
}
