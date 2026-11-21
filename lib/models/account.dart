import 'json.dart';

/// Which side of the marketplace an account belongs to.
enum UserRole { traveller, guide }

extension UserRoleLabel on UserRole {
  String get label => switch (this) {
    UserRole.traveller => 'Traveller',
    UserRole.guide => 'Guide',
  };
}

/// The signed-in person, as the server describes them. Never holds a
/// password: the app only ever sees the token it got back.
class Account {
  const Account({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.memberSince,
  });

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    id: asString(json['id']),
    name: asString(json['name'], 'Traveller'),
    email: asString(json['email']),
    role: asEnum(json['role'], UserRole.values, UserRole.traveller),
    memberSince: DateTime.tryParse(asString(json['memberSince'])),
  );

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final DateTime? memberSince;

  /// Two letters for the avatar circle, e.g. "Tomiris Suleimenova" -> "TS".
  String get initials {
    final List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length < 2) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  /// "Tomiris S." — the short form the profile and the cards show.
  String get shortName {
    final List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) return name.trim();
    return '${parts.first} ${parts[1][0].toUpperCase()}.';
  }
}
