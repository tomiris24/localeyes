import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../data/mock_locals.dart';
import '../models/local_person.dart';
import '../widgets/hangout_row.dart';
import '../widgets/section_header.dart';

/// Signing up as a local.
///
/// The whole point is that this takes a few minutes, not an application
/// process: no licence, no CV, no tour to write. You pick what you are into,
/// what you would happily do with a visitor, and when you are usually around.
class BecomeLocalScreen extends StatefulWidget {
  const BecomeLocalScreen({super.key});

  @override
  State<BecomeLocalScreen> createState() => _BecomeLocalScreenState();
}

class _BecomeLocalScreenState extends State<BecomeLocalScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _oneLinerController = TextEditingController();
  final TextEditingController _timesController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();

  static const List<String> _levels = <String>['Native', 'C1', 'B2', 'B1', 'A2'];
  static const List<String> _spokenHere = <String>[
    'Kazakh',
    'Russian',
    'English',
    'Turkish',
    'Chinese',
    'German',
  ];

  /// Language -> level. A language is only on the profile once its level is
  /// stated, because "English" alone is what travellers cannot read.
  final Map<String, String> _languages = <String, String>{};
  final Set<String> _interests = <String>{};
  final Set<HangoutKind> _hangouts = <HangoutKind>{};

  String _area = MockLocals.areas[1];
  Availability _availability = Availability.weekend;
  MeetupCost _cost = MeetupCost.free;
  bool _acceptedRules = false;

  bool _showInterestsError = false;
  bool _showHangoutsError = false;
  bool _showRulesError = false;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _oneLinerController.dispose();
    _timesController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------- validators

  String? _validateName(String? value) {
    final String name = (value ?? '').trim();
    if (name.isEmpty) return 'Please enter your name';
    if (name.length < 2) return 'Name is too short';
    return null;
  }

  String? _validateAge(String? value) {
    final String raw = (value ?? '').trim();
    if (raw.isEmpty) return 'Please enter your age';
    final int? age = int.tryParse(raw);
    if (age == null) return 'Use digits only';
    if (age < 18) return 'You have to be 18 or over';
    if (age > 100) return 'Please check that number';
    return null;
  }

  String? _validateOneLiner(String? value) {
    final String line = (value ?? '').trim();
    if (line.isEmpty) return 'One sentence is all we need to start';
    if (line.length < 25) return 'A little more — this is what travellers read first';
    return null;
  }

  String? _validateTimes(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Say roughly when, e.g. "weekday evenings"';
    }
    return null;
  }

  String? _validateRate(String? value) {
    if (_cost != MeetupCost.hourly) return null;
    final String raw = (value ?? '').trim();
    if (raw.isEmpty) return 'Enter your hourly rate';
    final double? rate = double.tryParse(raw);
    if (rate == null || rate <= 0) return 'Enter a number above zero';
    return null;
  }

  // ----------------------------------------------------------------- submit

  void _publish() {
    final bool formOk = _formKey.currentState!.validate();
    final bool interestsOk = _interests.isNotEmpty;
    final bool hangoutsOk = _hangouts.isNotEmpty;
    final bool rulesOk = _acceptedRules;

    setState(() {
      _autovalidate = AutovalidateMode.onUserInteraction;
      _showInterestsError = !interestsOk;
      _showHangoutsError = !hangoutsOk;
      _showRulesError = !rulesOk;
    });

    if (!formOk || !interestsOk || !hangoutsOk || !rulesOk) return;

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardAll),
        title: const Text('You are on the map'),
        content: Text(
          '${_nameController.text.trim()}, your profile is live. Travellers '
          'who are into ${_interests.take(2).join(' and ').toLowerCase()} will '
          'see you first.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.lg,
        title: const Text('Become a local'),
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
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.brandSoft.withValues(alpha: 0.35),
                    borderRadius: AppRadius.cardAll,
                  ),
                  child: Text(
                    'You do not need a licence, a route or any experience. If '
                    'you like this city and you like talking to people, that '
                    'is the whole requirement.',
                    style: text.bodyMedium?.copyWith(color: AppColors.brandDeep),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                const SectionHeader(title: 'About you'),
                const SizedBox(height: AppSpacing.md),
                _Field(
                  controller: _nameController,
                  label: 'Name',
                  hint: 'Aizhan K.',
                  validator: _validateName,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 104,
                      child: _Field(
                        controller: _ageController,
                        label: 'Age',
                        hint: '27',
                        keyboardType: TextInputType.number,
                        validator: _validateAge,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _Labelled(
                        label: 'Your area',
                        child: DropdownButtonFormField<String>(
                          initialValue: _area,
                          isExpanded: true,
                          decoration: _decoration(null),
                          items: <DropdownMenuItem<String>>[
                            for (final String area
                                in MockLocals.areas.skip(1))
                              DropdownMenuItem<String>(
                                value: area,
                                child: Text(
                                  area,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: (String? value) =>
                              setState(() => _area = value ?? _area),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _Field(
                  controller: _oneLinerController,
                  label: 'One line about you',
                  hint:
                      'Barista. I can tell you which coffee place is actually '
                      'worth your morning.',
                  maxLines: 3,
                  maxLength: 160,
                  validator: _validateOneLiner,
                ),
                const SizedBox(height: AppSpacing.lg),

                const SectionHeader(
                  title: 'Languages',
                  subtitle: 'Be honest about the level — it is the whole point',
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: <Widget>[
                    for (final String language in _spokenHere)
                      FilterChip(
                        label: Text(language),
                        selected: _languages.containsKey(language),
                        showCheckmark: false,
                        backgroundColor: Colors.white,
                        selectedColor: AppColors.brand,
                        side: BorderSide(
                          color: _languages.containsKey(language)
                              ? AppColors.brand
                              : AppColors.line,
                        ),
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _languages.containsKey(language)
                              ? Colors.white
                              : AppColors.ink,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.pillAll,
                        ),
                        onSelected: (bool on) => setState(() {
                          if (on) {
                            _languages[language] = 'B1';
                          } else {
                            _languages.remove(language);
                          }
                        }),
                      ),
                  ],
                ),
                for (final String language in _languages.keys.toList())
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(language, style: text.titleSmall),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        SizedBox(
                          width: 128,
                          child: DropdownButtonFormField<String>(
                            initialValue: _languages[language],
                            isExpanded: true,
                            decoration: _decoration(null, dense: true),
                            items: <DropdownMenuItem<String>>[
                              for (final String level in _levels)
                                DropdownMenuItem<String>(
                                  value: level,
                                  child: Text(level),
                                ),
                            ],
                            onChanged: (String? value) => setState(
                              () => _languages[language] = value ?? 'B1',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.xl),

                const SectionHeader(
                  title: 'What you are into',
                  subtitle: 'This is how travellers are matched to you',
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: <Widget>[
                    for (final String interest in MockLocals.interests)
                      FilterChip(
                        label: Text(interest),
                        selected: _interests.contains(interest),
                        showCheckmark: false,
                        backgroundColor: Colors.white,
                        selectedColor: AppColors.brand,
                        side: BorderSide(
                          color: _interests.contains(interest)
                              ? AppColors.brand
                              : AppColors.line,
                        ),
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _interests.contains(interest)
                              ? Colors.white
                              : AppColors.ink,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.pillAll,
                        ),
                        onSelected: (bool on) => setState(() {
                          if (on) {
                            _interests.add(interest);
                          } else {
                            _interests.remove(interest);
                          }
                          _showInterestsError = false;
                        }),
                      ),
                  ],
                ),
                if (_showInterestsError) const _FieldError('Pick at least one'),
                const SizedBox(height: AppSpacing.xl),

                const SectionHeader(
                  title: 'What you would happily do',
                  subtitle: 'No route to write — just tick what sounds like you',
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final HangoutKind kind in HangoutKind.values)
                  _HangoutToggle(
                    kind: kind,
                    selected: _hangouts.contains(kind),
                    onChanged: (bool on) => setState(() {
                      if (on) {
                        _hangouts.add(kind);
                      } else {
                        _hangouts.remove(kind);
                      }
                      _showHangoutsError = false;
                    }),
                  ),
                if (_showHangoutsError)
                  const _FieldError('Pick at least one thing'),
                const SizedBox(height: AppSpacing.xl),

                const SectionHeader(title: 'When you are usually around'),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<Availability>(
                  segments: <ButtonSegment<Availability>>[
                    for (final Availability value in Availability.values)
                      ButtonSegment<Availability>(
                        value: value,
                        label: Text(value.shortLabel),
                      ),
                  ],
                  selected: <Availability>{_availability},
                  showSelectedIcon: false,
                  onSelectionChanged: (Set<Availability> value) =>
                      setState(() => _availability = value.first),
                ),
                const SizedBox(height: AppSpacing.md),
                _Field(
                  controller: _timesController,
                  label: 'In your words',
                  hint: 'Most evenings after 6, weekends all day',
                  validator: _validateTimes,
                ),
                const SizedBox(height: AppSpacing.lg),

                const SectionHeader(
                  title: 'Money',
                  subtitle: 'Most people here charge nothing. That is fine.',
                ),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<MeetupCost>(
                  segments: const <ButtonSegment<MeetupCost>>[
                    ButtonSegment<MeetupCost>(
                      value: MeetupCost.free,
                      label: Text('Free'),
                    ),
                    ButtonSegment<MeetupCost>(
                      value: MeetupCost.coffee,
                      label: Text('Coffee'),
                    ),
                    ButtonSegment<MeetupCost>(
                      value: MeetupCost.hourly,
                      label: Text('Hourly'),
                    ),
                  ],
                  selected: <MeetupCost>{_cost},
                  showSelectedIcon: false,
                  onSelectionChanged: (Set<MeetupCost> value) =>
                      setState(() => _cost = value.first),
                ),
                if (_cost == MeetupCost.hourly) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  _Field(
                    controller: _rateController,
                    label: 'Your rate, \$ per hour',
                    hint: '8',
                    keyboardType: TextInputType.number,
                    validator: _validateRate,
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),

                CheckboxListTile(
                  value: _acceptedRules,
                  onChanged: (bool? value) => setState(() {
                    _acceptedRules = value ?? false;
                    _showRulesError = false;
                  }),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'I will meet first-timers in a public place',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Both sides agree to this. It is what makes meeting a '
                    'stranger reasonable.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.inkMuted),
                  ),
                ),
                if (_showRulesError)
                  const _FieldError('You have to agree to this one'),
                const SizedBox(height: AppSpacing.lg),

                ElevatedButton.icon(
                  onPressed: _publish,
                  icon: const Icon(Icons.waving_hand_rounded, size: 19),
                  label: const Text('Put me on the map'),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded, size: 19),
                  label: const Text('Not now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration _decoration(String? hint, {bool dense = false}) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    isDense: dense,
    contentPadding: EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: dense ? 12 : 16,
    ),
    border: const OutlineInputBorder(
      borderRadius: AppRadius.cardAll,
      borderSide: BorderSide(color: AppColors.line),
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: AppRadius.cardAll,
      borderSide: BorderSide(color: AppColors.line),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: AppRadius.cardAll,
      borderSide: BorderSide(color: AppColors.brand),
    ),
  );
}

/// Label above the control, so a long label never squeezes the field itself.
class _Labelled extends StatelessWidget {
  const _Labelled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.textCapitalization = TextCapitalization.sentences,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return _Labelled(
      label: label,
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        maxLength: maxLength,
        textCapitalization: textCapitalization,
        decoration: _decoration(hint),
      ),
    );
  }
}

/// Error line for the pickers, which are not [FormField]s and so cannot show
/// their own message.
class _FieldError extends StatelessWidget {
  const _FieldError(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, left: 2),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.error_outline_rounded,
            size: 15,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.5,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HangoutToggle extends StatelessWidget {
  const _HangoutToggle({
    required this.kind,
    required this.selected,
    required this.onChanged,
  });

  final HangoutKind kind;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: selected,
      onChanged: (bool? value) => onChanged(value ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
      secondary: Icon(
        hangoutIcon(kind),
        size: 19,
        color: selected ? AppColors.brand : AppColors.inkMuted,
      ),
      title: Text(
        kind.label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}
