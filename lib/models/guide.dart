import 'json.dart';

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

  factory Guide.fromJson(Map<String, dynamic> json) => Guide(
    id: asString(json['id']),
    name: asString(json['name'], 'A local guide'),
    yearsOfExperience: asInt(json['yearsOfExperience']),
    languages: asStringList(json['languages']),
    rating: asDouble(json['rating']),
    tourCount: asInt(json['tourCount']),
    responseTime: asString(json['responseTime']),
    bio: asString(json['bio']),
    isVerified: asBool(json['isVerified'], true),
  );

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
