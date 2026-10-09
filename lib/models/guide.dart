/// A local guide who runs tours on LocalEyes.
class Guide {
  const Guide({
    required this.id,
    required this.name,
    required this.yearsOfExperience,
    required this.languages,
    required this.rating,
    required this.tourCount,
    required this.responseTime,
    required this.bio,
    this.isVerified = true,
  });

  final String id;
  final String name;
  final int yearsOfExperience;
  final List<String> languages;
  final double rating;
  final int tourCount;
  final String responseTime;
  final String bio;
  final bool isVerified;

  /// Two letters used in the avatar circle, e.g. "Aizhan K." -> "AK".
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }
}
