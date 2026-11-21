import 'json.dart';

/// One line on the traveller's own list: "book the Kolsai transfer",
/// "buy a SIM at the airport".
///
/// Notes never reach the server. They are written on the phone, stored on the
/// phone as JSON, and survive the app being force-quit — which is the whole
/// point of them being a separate model from anything in `DataStore`.
class NoteItem {
  const NoteItem({
    required this.id,
    required this.title,
    required this.dateText,
    this.isCompleted = false,
  });

  /// Rebuilds a note from one decoded JSON object. Every field has a
  /// fallback: a list written by an older build of the app must still open.
  factory NoteItem.fromJson(Map<String, dynamic> json) => NoteItem(
    id: asString(json['id']),
    title: asString(json['title'], 'Untitled note'),
    dateText: asString(json['dateText']),
    isCompleted: asBool(json['isCompleted']),
  );

  final String id;
  final String title;

  /// When it was written, already formatted for the row — the list is read,
  /// never sorted by date, so a string is enough.
  final String dateText;

  final bool isCompleted;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'dateText': dateText,
    'isCompleted': isCompleted,
  };

  NoteItem copyWith({String? title, bool? isCompleted}) => NoteItem(
    id: id,
    title: title ?? this.title,
    dateText: dateText,
    isCompleted: isCompleted ?? this.isCompleted,
  );
}
