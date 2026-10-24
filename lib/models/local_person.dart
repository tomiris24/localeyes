/// How soon a local is around for a meetup.
///
/// This is the first thing a traveller looks at, so it is a real field on the
/// person and not a free-text line: someone who is free tonight is a different
/// offer from someone who needs a week's notice.
enum Availability { today, tomorrow, weekend, laterOn }

extension AvailabilityLabel on Availability {
  String get label => switch (this) {
    Availability.today => 'Free today',
    Availability.tomorrow => 'Free tomorrow',
    Availability.weekend => 'Free this weekend',
    Availability.laterOn => 'Plan a few days ahead',
  };

  String get shortLabel => switch (this) {
    Availability.today => 'Today',
    Availability.tomorrow => 'Tomorrow',
    Availability.weekend => 'Weekend',
    Availability.laterOn => 'Later on',
  };
}

/// What meeting a local costs.
///
/// Most people on LocalEyes are not professional guides, so "free" and
/// "buy me a coffee" are first-class options rather than an edge case.
enum MeetupCost { free, coffee, hourly }

/// The kind of hangout a local offers. A local picks two or three of these
/// instead of writing a tour description from scratch — that is what keeps
/// signing up down to a couple of minutes.
enum HangoutKind { coffee, walk, food, photo, nightOut, music, sport, language }

extension HangoutKindLabel on HangoutKind {
  String get label => switch (this) {
    HangoutKind.coffee => 'Coffee and a chat',
    HangoutKind.walk => 'Walk around my neighbourhood',
    HangoutKind.food => 'Eat where locals eat',
    HangoutKind.photo => 'Show you the good photo spots',
    HangoutKind.nightOut => 'Night out',
    HangoutKind.music => 'Live music and gigs',
    HangoutKind.sport => 'Hike, run or ride',
    HangoutKind.language => 'Language exchange',
  };
}

/// One language a local speaks, with the level stated honestly.
///
/// "English" alone is what travellers complained about: it can mean anything
/// from a menu order to a two-hour conversation.
class LanguageSkill {
  const LanguageSkill({required this.language, required this.level});

  final String language;
  final String level;

  String get label => '$language · $level';
}

/// Something a local offers to do, in their own words.
class HangoutIdea {
  const HangoutIdea({required this.kind, required this.note});

  final HangoutKind kind;

  /// The local's own line about it, e.g. "the bazaar before 10, when the
  /// sellers still have time to talk".
  final String note;

  String get title => kind.label;
}

/// A person who lives here and is happy to show travellers around.
///
/// This is deliberately not a [Guide]: no licence, no years of experience, no
/// tour catalogue. Anyone who wants to meet travellers can be one.
class LocalPerson {
  const LocalPerson({
    required this.id,
    required this.name,
    required this.age,
    required this.neighbourhood,
    required this.oneLiner,
    required this.bio,
    required this.languages,
    required this.interests,
    required this.hangouts,
    required this.availability,
    required this.usualTimes,
    required this.cost,
    required this.meetCount,
    required this.rating,
    required this.responseTime,
    required this.memberSince,
    required this.favouriteSpotIds,
    this.hourlyRate = 0,
    this.isPhoneVerified = true,
  });

  final String id;
  final String name;
  final int age;
  final String neighbourhood;

  /// One sentence shown on the card, written by the local.
  final String oneLiner;
  final String bio;
  final List<LanguageSkill> languages;
  final List<String> interests;
  final List<HangoutIdea> hangouts;
  final Availability availability;

  /// When this person is usually around, e.g. "weekday evenings".
  final String usualTimes;
  final MeetupCost cost;
  final double hourlyRate;
  final int meetCount;
  final double rating;
  final String responseTime;
  final String memberSince;
  final List<String> favouriteSpotIds;
  final bool isPhoneVerified;

  /// Two letters for the avatar circle, e.g. "Aizhan K." -> "AK".
  String get initials {
    final List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  String get costLabel => switch (cost) {
    MeetupCost.free => 'Free',
    MeetupCost.coffee => 'Buy me a coffee',
    MeetupCost.hourly => '\$${hourlyRate.toStringAsFixed(0)} / hour',
  };

  /// The longer version shown on the profile, so nobody is surprised later.
  String get costNote => switch (cost) {
    MeetupCost.free => 'I do not charge. We split whatever we order.',
    MeetupCost.coffee => 'No fee. Get the coffee or the lunch and we are even.',
    MeetupCost.hourly =>
      '\$${hourlyRate.toStringAsFixed(0)} an hour. Transport and food are separate.',
  };

  /// A short line naming what this person and the traveller have in common.
  /// Milestone 3 replaces it with the real matching model.
  String matchNote(Set<String> travellerInterests) {
    final List<String> shared = interests
        .where((String i) => travellerInterests.contains(i))
        .toList();
    if (shared.isEmpty) return 'New to you — different interests, same city';
    if (shared.length == 1) return 'You both like ${shared.first.toLowerCase()}';
    return 'You both like ${shared.take(2).map((String s) => s.toLowerCase()).join(' and ')}';
  }
}
