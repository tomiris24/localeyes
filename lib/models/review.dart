/// A review left by a traveller after a tour.
class Review {
  const Review({
    required this.author,
    required this.country,
    required this.rating,
    required this.timeAgo,
    required this.text,
  });

  final String author;
  final String country;
  final double rating;
  final String timeAgo;
  final String text;

  String get initials => author.trim().isEmpty ? '?' : author.trim()[0].toUpperCase();
}
