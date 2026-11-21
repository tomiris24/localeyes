import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:localeyes/core/app_theme.dart';
import 'package:localeyes/data/local_store.dart';
import 'package:localeyes/main.dart';
import 'package:localeyes/models/note_item.dart';
import 'package:localeyes/screens/trip_notes_screen.dart';
import 'package:localeyes/state/notes_controller.dart';
import 'package:localeyes/state/settings_controller.dart';

import 'fixtures/seed_data.dart';

/// Opens the phone's storage with [values] already on it, the way `main()`
/// opens it on a cold start.
Future<void> _openStorage([
  Map<String, Object> values = const <String, Object>{},
]) async {
  SharedPreferences.setMockInitialValues(values);
  LocalStore.reset();
  await LocalStore.init();
}

Future<void> _pumpNotes(WidgetTester tester, NotesController notes) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<NotesController>.value(
      value: notes,
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const TripNotesScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('NoteItem JSON', () {
    test('a note survives a round trip through a JSON string', () {
      const NoteItem note = NoteItem(
        id: 'n1',
        title: 'Book the Kolsai transfer',
        dateText: '21 Nov 2026',
        isCompleted: true,
      );

      final String encoded = jsonEncode(note.toJson());
      final NoteItem back = NoteItem.fromJson(
        jsonDecode(encoded) as Map<String, dynamic>,
      );

      expect(back.id, note.id);
      expect(back.title, note.title);
      expect(back.dateText, note.dateText);
      expect(back.isCompleted, isTrue);
    });

    test('a missing field falls back instead of throwing', () {
      final NoteItem note = NoteItem.fromJson(<String, dynamic>{'id': 'n2'});

      expect(note.title, 'Untitled note');
      expect(note.isCompleted, isFalse);
    });
  });

  group('NotesController', () {
    setUp(_openStorage);

    test('a new note is prepended and written to disk as JSON', () async {
      final NotesController notes = NotesController();
      await notes.add('Buy a SIM at the airport');
      await notes.add('Message Aizhan about Saturday');

      expect(notes.notes.first.title, 'Message Aizhan about Saturday');
      expect(notes.notes.length, 2);

      final Object? stored = jsonDecode(LocalStore.notesJson!);
      expect(stored, isA<List<Object?>>());
      expect((stored! as List<Object?>).length, 2);
    });

    test('an empty note is not added', () async {
      final NotesController notes = NotesController();
      await notes.add('   ');

      expect(notes.notes, isEmpty);
    });

    test('toggling and deleting are both written through', () async {
      final NotesController notes = NotesController();
      await notes.add('Charge the power bank');
      await notes.add('Print the insurance');

      final String id = notes.notes.first.id;
      await notes.toggle(id);
      expect(notes.notes.first.isCompleted, isTrue);
      expect(notes.remaining, 1);

      await notes.remove(id);
      expect(notes.notes.length, 1);

      final List<Object?> stored =
          jsonDecode(LocalStore.notesJson!) as List<Object?>;
      expect(stored.length, 1);
      expect(
        (stored.first! as Map<String, dynamic>)['title'],
        'Charge the power bank',
      );
    });

    test('UNDO puts the note back at its old position', () async {
      final NotesController notes = NotesController();
      await notes.add('First');
      await notes.add('Second');
      await notes.add('Third');

      final NoteItem middle = notes.notes[1];
      await notes.remove(middle.id);
      await notes.restore(middle, 1);

      expect(notes.notes[1].id, middle.id);
    });

    test('a cold start reads the same list back', () async {
      final NotesController first = NotesController();
      await first.add('Book the Kolsai transfer');
      await first.toggle(first.notes.first.id);

      // The process is gone; the storage file is not.
      final String onDisk = LocalStore.notesJson!;
      await _openStorage(<String, Object>{LocalStore.notesKey: onDisk});

      final NotesController second = NotesController();
      expect(second.notes.length, 1);
      expect(second.notes.first.title, 'Book the Kolsai transfer');
      expect(second.notes.first.isCompleted, isTrue);
    });

    test('a corrupt file reads as an empty list, not a crash', () async {
      await _openStorage(<String, Object>{LocalStore.notesKey: '{not json'});

      expect(NotesController().notes, isEmpty);
    });
  });

  group('SettingsController', () {
    setUp(_openStorage);

    test('nothing saved means "follow the phone"', () async {
      final SettingsController settings = SettingsController();

      expect(settings.darkMode, isNull);
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.displayName, 'Guest User');
    });

    test('the switch and the name are written to disk', () async {
      final SettingsController settings = SettingsController();
      await settings.setDarkMode(true);
      await settings.setDisplayName('  Tomiris  ');

      expect(LocalStore.prefs.getBool(LocalStore.themeKey), isTrue);
      expect(LocalStore.prefs.getString(LocalStore.nameKey), 'Tomiris');
      expect(settings.themeMode, ThemeMode.dark);
      expect(settings.displayName, 'Tomiris');
    });

    test('an empty name falls back to Guest User', () async {
      final SettingsController settings = SettingsController();
      await settings.setDisplayName('   ');

      expect(settings.displayName, 'Guest User');
      expect(settings.hasDisplayName, isFalse);
    });
  });

  group('The notes screen', () {
    setUp(_openStorage);

    testWidgets('typing a note adds it, ticking it crosses it out', (
      WidgetTester tester,
    ) async {
      final NotesController notes = NotesController();
      await _pumpNotes(tester, notes);

      expect(find.text('No notes yet'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Buy a SIM');
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Buy a SIM'), findsOneWidget);
      expect(notes.notes.single.title, 'Buy a SIM');

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      expect(notes.notes.single.isCompleted, isTrue);

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();
      expect(notes.notes, isEmpty);
      expect(find.text('UNDO'), findsOneWidget);
    });
  });

  group('Cold restart', () {
    testWidgets('the app opens dark, with the saved name, on the first frame', (
      WidgetTester tester,
    ) async {
      // What the previous run left on the phone.
      await SeedData.installApp(
        storage: <String, Object>{
          LocalStore.themeKey: true,
          LocalStore.nameKey: 'Tomiris',
          LocalStore.notesKey: jsonEncode(<Map<String, dynamic>>[
            const NoteItem(
              id: 'n1',
              title: 'Book the Kolsai transfer',
              dateText: '21 Nov 2026',
            ).toJson(),
          ]),
        },
      );

      await tester.pumpWidget(const LocalEyesApp());
      // One frame only: the theme must already be the right one.
      await tester.pump();

      final MaterialApp app = tester.widget<MaterialApp>(
        find.byType(MaterialApp),
      );
      expect(app.themeMode, ThemeMode.dark);
      expect(SettingsController.instance.displayName, 'Tomiris');
      expect(NotesController().notes.single.title, 'Book the Kolsai transfer');

      await tester.pumpAndSettle();
    });
  });
}
