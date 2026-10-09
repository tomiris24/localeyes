import 'package:flutter/material.dart';

import '../data/mock_tours.dart';
import '../models/tour.dart';

/// One tour added to the cart, together with the options the traveller picked.
class CartItem {
  CartItem({required this.tourId, required this.guests, required this.date});

  final String tourId;
  final int guests;
  final String date;

  Tour get tour => MockData.byId(tourId);
  double get total => tour.totalFor(guests);
}

/// App-wide state shared by every screen: saved tours and the cart.
///
/// It is a plain [ChangeNotifier] on purpose — no extra packages in Milestone 1.
/// In Milestone 3 this is replaced by BLoC.
class AppState extends ChangeNotifier {
  final Set<String> _savedIds = <String>{'t3'};
  final List<CartItem> _cart = <CartItem>[];

  Set<String> get savedIds => Set<String>.unmodifiable(_savedIds);
  List<CartItem> get cart => List<CartItem>.unmodifiable(_cart);

  int get cartCount => _cart.length;
  double get cartTotal =>
      _cart.fold(0, (double sum, CartItem item) => sum + item.total);

  List<Tour> get savedTours =>
      MockData.tours.where((Tour t) => _savedIds.contains(t.id)).toList();

  bool isSaved(String tourId) => _savedIds.contains(tourId);

  /// Returns true when the tour ends up saved, so the UI can show the right message.
  bool toggleSaved(String tourId) {
    final bool nowSaved = !_savedIds.contains(tourId);
    if (nowSaved) {
      _savedIds.add(tourId);
    } else {
      _savedIds.remove(tourId);
    }
    notifyListeners();
    return nowSaved;
  }

  bool isInCart(String tourId) =>
      _cart.any((CartItem item) => item.tourId == tourId);

  void addToCart(CartItem item) {
    _cart.removeWhere((CartItem existing) => existing.tourId == item.tourId);
    _cart.add(item);
    notifyListeners();
  }

  void removeFromCart(String tourId) {
    _cart.removeWhere((CartItem item) => item.tourId == tourId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}

/// Makes [AppState] available to the whole widget tree without a state package.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState super.notifier, required super.child});

  static AppState of(BuildContext context) {
    final AppScope? scope =
        context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope found above this widget');
    return scope!.notifier!;
  }
}
