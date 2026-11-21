import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../models/note_item.dart';
import '../state/notes_controller.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_header.dart';

/// The traveller's own list for this trip: book the transfer, buy a SIM,
/// message Aizhan about Saturday.
///
/// Nothing here goes to the server. The list is written to the phone as JSON
/// after every change, so it is all still there after the app is force-quit —
/// and it works on a plane with no signal at all.
class TripNotesScreen extends StatefulWidget {
  const TripNotesScreen({super.key});

  @override
  State<TripNotesScreen> createState() => _TripNotesScreenState();
}

class _TripNotesScreenState extends State<TripNotesScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final String text = _controller.text.trim();
    if (text.isEmpty) {
      _focus.requestFocus();
      return;
    }
    await context.read<NotesController>().add(text);
    if (!mounted) return;
    _controller.clear();
    _focus.requestFocus();
  }

  void _remove(NoteItem note) {
    final NotesController notes = context.read<NotesController>();
    final int index = notes.notes.indexOf(note);
    if (index < 0) return;

    notes.remove(note.id);

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('${note.title} deleted'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () => notes.restore(note, index),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final NotesController notes = context.watch<NotesController>();
    final List<NoteItem> items = notes.notes;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.lg,
        title: const Text('Trip notes'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focus,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _add(),
                        decoration: InputDecoration(
                          hintText: 'Book the Kolsai transfer…',
                          filled: true,
                          fillColor: context.palette.surfaceHigh,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: 14,
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: AppRadius.pillAll,
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: AppRadius.pillAll,
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppRadius.pillAll,
                            borderSide: BorderSide(
                              color: context.palette.brand,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: Material(
                        color: context.palette.brandDeep,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: _add,
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (items.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: SectionHeader(
                    title: 'On this trip',
                    subtitle: notes.remaining == 0
                        ? 'Everything is done'
                        : '${notes.remaining} left of ${items.length}',
                  ),
                ),
              Expanded(
                child: items.isEmpty
                    ? const EmptyState(
                        icon: Icons.checklist_rounded,
                        title: 'No notes yet',
                        message:
                            'Write down what you still have to do before the '
                            'trip. The list stays on this phone, even offline.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.xl,
                        ),
                        itemCount: items.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (BuildContext context, int index) {
                          final NoteItem note = items[index];
                          return _NoteRow(
                            note: note,
                            onToggle: () => notes.toggle(note.id),
                            onDelete: () => _remove(note),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteRow extends StatelessWidget {
  const _NoteRow({
    required this.note,
    required this.onToggle,
    required this.onDelete,
  });

  final NoteItem note;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: context.palette.line),
      ),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: note.isCompleted,
            onChanged: (_) => onToggle(),
            activeColor: context.palette.brandDeep,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    note.title,
                    style: text.titleSmall?.copyWith(
                      decoration: note.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: note.isCompleted
                          ? context.palette.inkMuted
                          : context.palette.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(note.dateText, style: text.bodySmall),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: onDelete,
            tooltip: 'Delete note',
            icon: Icon(
              Icons.delete_outline_rounded,
              color: context.palette.inkMuted,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
    );
  }
}
