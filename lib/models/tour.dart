import 'guide.dart';
import 'review.dart';

/// One stop of the route, shown on the "Route" tab of the detail screen.
class RouteStop {
  const RouteStop({required this.time, required this.title, required this.note});

  final String time;
  final String title;
  final String note;
}

/// The honest tour details travellers said they were missing
/// (difficulty, walking time, real group size, language level).
class TourFacts {
  const TourFacts({
    required this.difficulty,
    required this.walkingTime,
    required this.groupSize,
    required this.languageLevel,
    required this.meetingPoint,
  });

  final String difficulty;
  final String walkingTime;
  final String groupSize;
  final String languageLevel;
  final String meetingPoint;
}

/// A tour offered by a guide. This is the "product" of the app.
class Tour {
  const Tour({
    required this.id,
    required this.title,
    required this.area,
    required this.image,
    required this.imageCredit,
    required this.category,
    required this.pricePerPerson,
    required this.rating,
    required this.reviewCount,
    required this.duration,
    required this.tags,
    required this.summary,
    required this.included,
    required this.route,
    required this.facts,
    required this.guide,
    required this.reviews,
    required this.availableDates,
    this.maxGuests = 8,
  });

  final String id;
  final String title;
  final String area;
  final String image;
  final String imageCredit;
  final String category;
  final double pricePerPerson;
  final double rating;
  final int reviewCount;
  final String duration;
  final List<String> tags;
  final String summary;
  final List<String> included;
  final List<RouteStop> route;
  final TourFacts facts;
  final Guide guide;
  final List<Review> reviews;
  final List<String> availableDates;
  final int maxGuests;

  bool get isTopRated => rating >= 4.9;

  double totalFor(int guests) => pricePerPerson * guests;
}
