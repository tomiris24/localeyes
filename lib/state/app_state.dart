import 'package:flutter/material.dart';

import '../data/mock_locals.dart';
import '../data/mock_tours.dart';
import '../models/local_person.dart';
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

/// Where a meetup request stands. A local is a person with a job, not a
/// business, so "declined" is a normal outcome and the UI says so plainly.
enum MeetupStatus { waiting, accepted, declined }

extension MeetupStatusLabel on MeetupStatus {
  String get label => switch (this) {
    MeetupStatus.waiting => 'Waiting for a reply',
    MeetupStatus.accepted => 'Confirmed',
    MeetupStatus.declined => 'Declined',
  };
}

/// One "let's meet" request sent to a local.
class MeetupRequest {
  const MeetupRequest({
    required this.localId,
    required this.day,
    required this.timeOfDay,
    required this.kind,
    required this.place,
    required this.message,
    this.status = MeetupStatus.waiting,
  });

  final String localId;
  final String day;
  final String timeOfDay;
  final HangoutKind kind;
  final String place;
  final String message;
  final MeetupStatus status;

  LocalPerson get local => MockLocals.byId(localId);
}

/// App-wide state shared by every screen: saved tours and the cart.
///
/// It is a plain [ChangeNotifier] on purpose — no extra packages in Milestone 1.
/// In Milestone 3 this is replaced by BLoC.
class AppState extends ChangeNotifier {
  final Set<String> _savedIds = <String>{'t3'};
  final List<CartItem> _cart = <CartItem>[];
  final Set<String> _savedLocalIds = <String>{'l3'};
  final List<MeetupRequest> _meetups = <MeetupRequest>[];

  /// What the traveller said they are into. Used to explain why a local is a
  /// good match; in Milestone 3 this feeds the real matching model.
  final Set<String> _myInterests = <String>{
    'Coffee',
    'Mountains',
    'Photography',
  };

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

  // --- Locals -------------------------------------------------------------

  Set<String> get savedLocalIds => Set<String>.unmodifiable(_savedLocalIds);
  Set<String> get myInterests => Set<String>.unmodifiable(_myInterests);
  List<MeetupRequest> get meetups => List<MeetupRequest>.unmodifiable(_meetups);

  List<LocalPerson> get savedLocals => MockLocals.people
      .where((LocalPerson p) => _savedLocalIds.contains(p.id))
      .toList();

  bool isLocalSaved(String localId) => _savedLocalIds.contains(localId);

  /// Returns true when the local ends up saved, so the UI can show the right
  /// message — the same contract as [toggleSaved].
  bool toggleSavedLocal(String localId) {
    final bool nowSaved = !_savedLocalIds.contains(localId);
    if (nowSaved) {
      _savedLocalIds.add(localId);
    } else {
      _savedLocalIds.remove(localId);
    }
    notifyListeners();
    return nowSaved;
  }

  void toggleInterest(String interest) {
    if (!_myInterests.remove(interest)) _myInterests.add(interest);
    notifyListeners();
  }

  bool hasPendingMeetupWith(String localId) => _meetups.any(
    (MeetupRequest m) =>
        m.localId == localId && m.status == MeetupStatus.waiting,
  );

  void sendMeetupRequest(MeetupRequest request) {
    _meetups.removeWhere((MeetupRequest m) => m.localId == request.localId);
    _meetups.add(request);
    notifyListeners();
  }

  void cancelMeetupRequest(String localId) {
    _meetups.removeWhere((MeetupRequest m) => m.localId == localId);
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
