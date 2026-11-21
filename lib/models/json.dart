/// Readers that never throw on a missing or mistyped field.
///
/// A document in MongoDB can lose a key between milestones; one absent
/// `title` should not take a whole screen down.
String asString(Object? value, [String fallback = '']) =>
    value is String ? value : fallback;

double asDouble(Object? value, [double fallback = 0]) => switch (value) {
  final num n => n.toDouble(),
  final String s => double.tryParse(s) ?? fallback,
  _ => fallback,
};

int asInt(Object? value, [int fallback = 0]) => switch (value) {
  final num n => n.toInt(),
  final String s => int.tryParse(s) ?? fallback,
  _ => fallback,
};

bool asBool(Object? value, [bool fallback = false]) =>
    value is bool ? value : fallback;

List<String> asStringList(Object? value) =>
    value is List ? value.whereType<String>().toList() : const <String>[];

List<Map<String, dynamic>> asObjectList(Object? value) => value is List
    ? value.whereType<Map<String, dynamic>>().toList()
    : const <Map<String, dynamic>>[];

Map<String, dynamic> asObject(Object? value) =>
    value is Map<String, dynamic> ? value : const <String, dynamic>{};

/// Turns the stored enum name back into the enum, falling back to [fallback]
/// when the server sends a value this build does not know yet.
T asEnum<T extends Enum>(Object? value, List<T> values, T fallback) {
  if (value is! String) return fallback;
  for (final T candidate in values) {
    if (candidate.name == value) return candidate;
  }
  return fallback;
}
