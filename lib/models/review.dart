import 'json.dart';

/// A review left by a traveller after a tour.
class Review {
  const Review({
    required this.author,
    required this.country,
    required this.rating,
    required this.timeAgo,
    required this.text,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    author: asString(json['author'], 'A traveller'),
    country: asString(json['country']),
    rating: asDouble(json['rating']),
    timeAgo: asString(json['timeAgo']),
    text: asString(json['text']),
  );

  final String author;
  final String country;
  final double rating;
  final String timeAgo;
  final String text;

  String get initials =>
      author.trim().isEmpty ? '?' : author.trim()[0].toUpperCase();
}
