import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../data/local_store.dart';
import '../models/note_item.dart';

/// The traveller's own list, kept on the phone.
///
/// The whole list is one JSON string in [LocalStore.notesKey]: there are a
/// handful of notes, they are always read together, and one `setString` after
/// every change is simpler — and atomic — compared with a key per note.
///
/// Reads are synchronous because the store is already open by the time any
/// screen builds; only the write to disk is awaited, and the list in memory
/// has changed before it starts.
class NotesController extends ChangeNotifier {
  NotesController() {
    _notes = _read();
  }

  late List<NoteItem> _notes;

  List<NoteItem> get notes => List<NoteItem>.unmodifiable(_notes);

  int get remaining => _notes.where((NoteItem n) => !n.isCompleted).length;

  /// Newest first, the way the list is read.
  Future<void> add(String title) {
    final String text = title.trim();
    if (text.isEmpty) return Future<void>.value();

    final DateTime now = DateTime.now();
    _notes = <NoteItem>[
      NoteItem(
        id: now.microsecondsSinceEpoch.toString(),
        title: text,
        dateText: _formatDate(now),
      ),
      ..._notes,
    ];
    notifyListeners();
    return _save();
  }

  Future<void> toggle(String id) {
    _notes = <NoteItem>[
      for (final NoteItem note in _notes)
        if (note.id == id)
          note.copyWith(isCompleted: !note.isCompleted)
        else
          note,
    ];
    notifyListeners();
    return _save();
  }

  Future<void> remove(String id) {
    _notes = _notes.where((NoteItem note) => note.id != id).toList();
    notifyListeners();
    return _save();
  }

  /// Puts a note back where it was, for the UNDO on the delete SnackBar.
  Future<void> restore(NoteItem note, int index) {
    final List<NoteItem> next = List<NoteItem>.of(_notes);
    next.insert(index.clamp(0, next.length), note);
    _notes = next;
    notifyListeners();
    return _save();
  }

  /// Re-reads the disk. The app does this at startup by building the
  /// controller; a test uses it to prove a second launch sees the same list.
  void reload() {
    _notes = _read();
    notifyListeners();
  }

  List<NoteItem> _read() {
    final String? raw = LocalStore.notesJson;
    if (raw == null || raw.isEmpty) return <NoteItem>[];

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) return <NoteItem>[];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(NoteItem.fromJson)
          .toList();
    } on FormatException {
      // A half-written or hand-edited file should not take the screen down.
      return <NoteItem>[];
    }
  }

  Future<void> _save() => LocalStore.setNotesJson(
    jsonEncode(<Map<String, dynamic>>[
      for (final NoteItem note in _notes) note.toJson(),
    ]),
  );

  static String _formatDate(DateTime date) {
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
