import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../data/mock_locals.dart';
import '../models/local_person.dart';
import '../state/app_state.dart';
import '../widgets/hangout_row.dart';
import '../widgets/section_header.dart';

/// "Let's meet" — the request a traveller sends to a local.
///
/// It is a message with a few structured fields, not a checkout. Nothing is
/// charged here: the local has to say yes first, and they are allowed to say no.
class MeetupRequestScreen extends StatefulWidget {
  const MeetupRequestScreen({super.key, required this.person});

  final LocalPerson person;

  @override
  State<MeetupRequestScreen> createState() => _MeetupRequestScreenState();
}

class _MeetupRequestScreenState extends State<MeetupRequestScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _messageController = TextEditingController();

  static const List<String> _days = <String>[
    'Today',
    'Tomorrow',
    'Sat 25 Oct',
    'Sun 26 Oct',
    'Mon 27 Oct',
  ];
  static const List<String> _times = <String>['Morning', 'Afternoon', 'Evening'];

  late HangoutKind _kind = widget.person.hangouts.first.kind;
  String _day = _days.first;
  String _time = _times.last;
  String _place = MockLocals.publicMeetingPlaces.first;
  bool _tellAFriend = true;

  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String? _validateMessage(String? value) {
    final String message = (value ?? '').trim();
    if (message.isEmpty) {
      return 'Write a line about yourself — this is a person, not a booking form';
    }
    if (message.length < 15) {
      return 'A bit more, so they know who they are meeting';
    }
    return null;
  }

  void _send() {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }

    AppScope.of(context).sendMeetupRequest(
      MeetupRequest(
        localId: widget.person.id,
        day: _day,
        timeOfDay: _time,
        kind: _kind,
        place: _place,
        message: _messageController.text.trim(),
      ),
    );

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Sent to ${widget.person.name}. They ${widget.person.responseTime}.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final LocalPerson person = widget.person;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.lg,
        title: Text('Meet ${person.name.split(' ').first}'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidate,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              children: <Widget>[
                Text(
                  '${person.name} is ${person.availability.label.toLowerCase()} '
                  'and ${person.responseTime}.',
                  style: text.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),

                const SectionHeader(title: 'When'),
                const SizedBox(height: AppSpacing.sm),
                _ChipRow(
                  options: _days,
                  selected: _day,
                  onSelect: (String value) => setState(() => _day = value),
                ),
                const SizedBox(height: AppSpacing.md),
                SegmentedButton<String>(
                  segments: <ButtonSegment<String>>[
                    for (final String time in _times)
                      ButtonSegment<String>(value: time, label: Text(time)),
                  ],
                  selected: <String>{_time},
                  showSelectedIcon: false,
                  onSelectionChanged: (Set<String> value) =>
                      setState(() => _time = value.first),
                ),
                const SizedBox(height: AppSpacing.xl),

                const SectionHeader(
                  title: 'What you fancy',
                  subtitle: 'Pick one of their ideas — it can change on the day',
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final HangoutIdea idea in person.hangouts)
                  _IdeaOption(
                    idea: idea,
                    selected: idea.kind == _kind,
                    onTap: () => setState(() => _kind = idea.kind),
                  ),
                const SizedBox(height: AppSpacing.lg),

                const SectionHeader(
                  title: 'Where you meet first',
                  subtitle: 'Public places only, for a first meetup',
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  initialValue: _place,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.cardAll,
                      borderSide: BorderSide(color: AppColors.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.cardAll,
                      borderSide: BorderSide(color: AppColors.line),
                    ),
                  ),
                  items: <DropdownMenuItem<String>>[
                    for (final String place in MockLocals.publicMeetingPlaces)
                      DropdownMenuItem<String>(
                        value: place,
                        child: Text(place, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (String? value) =>
                      setState(() => _place = value ?? _place),
                ),
                const SizedBox(height: AppSpacing.xl),

                const SectionHeader(title: 'Say something'),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _messageController,
                  maxLines: 4,
                  maxLength: 400,
                  validator: _validateMessage,
                  decoration: const InputDecoration(
                    hintText:
                        'Who you are, how long you are in town, what you are '
                        'curious about…',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.cardAll,
                      borderSide: BorderSide(color: AppColors.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.cardAll,
                      borderSide: BorderSide(color: AppColors.line),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                CheckboxListTile(
                  value: _tellAFriend,
                  onChanged: (bool? value) =>
                      setState(() => _tellAFriend = value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Send my plan to a friend',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'They get the place, the time and who you are meeting.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.inkMuted),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                _Summary(
                  person: person,
                  day: _day,
                  time: _time,
                  kind: _kind,
                  place: _place,
                ),
                const SizedBox(height: AppSpacing.lg),

                ElevatedButton.icon(
                  onPressed: _send,
                  icon: const Icon(Icons.send_rounded, size: 19),
                  label: const Text('Send the request'),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded, size: 19),
                  label: const Text('Back to the profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A scrolling row of single-choice chips.
class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (BuildContext context, int index) {
          final String option = options[index];
          final bool isSelected = option == selected;
          return ChoiceChip(
            label: Text(option),
            selected: isSelected,
            onSelected: (_) => onSelect(option),
            showCheckmark: false,
            backgroundColor: Colors.white,
            selectedColor: AppColors.brand,
            side: BorderSide(
              color: isSelected ? AppColors.brand : AppColors.line,
            ),
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.ink,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.pillAll,
            ),
          );
        },
      ),
    );
  }
}

/// One of the local's own ideas, selectable.
class _IdeaOption extends StatelessWidget {
  const _IdeaOption({
    required this.idea,
    required this.selected,
    required this.onTap,
  });

  final HangoutIdea idea;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: selected ? AppColors.brandSoft.withValues(alpha: 0.35) : Colors.white,
        borderRadius: AppRadius.cardAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: AppRadius.cardAll,
              border: Border.all(
                color: selected ? AppColors.brand : AppColors.line,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  hangoutIcon(idea.kind),
                  size: 20,
                  color: selected ? AppColors.brand : AppColors.inkMuted,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(idea.title, style: text.titleSmall),
                      const SizedBox(height: 2),
                      Text(idea.note, style: text.bodySmall),
                    ],
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 19,
                    color: AppColors.brand,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// What is about to be sent, in one block, so nothing is a surprise.
class _Summary extends StatelessWidget {
  const _Summary({
    required this.person,
    required this.day,
    required this.time,
    required this.kind,
    required this.place,
  });

  final LocalPerson person;
  final String day;
  final String time;
  final HangoutKind kind;
  final String place;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: <Widget>[
          _Line(label: 'Who', value: person.name),
          _Line(label: 'When', value: '$day, $time'),
          _Line(label: 'What', value: kind.label),
          _Line(label: 'Where', value: place),
          _Line(label: 'Cost', value: person.costLabel),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 58,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12.5, color: AppColors.inkMuted),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
