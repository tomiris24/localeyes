import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// What the traveller picked in the short matching quiz.
class MatchFilters {
  const MatchFilters({this.category, this.pace, this.language});

  final String? category;
  final String? pace;
  final String? language;

  bool get isEmpty => category == null && pace == null && language == null;
}

/// Short quiz that replaces "scroll through 40 profiles and hope for the best".
/// In Milestone 2 the answers go to the matching service; here they filter the feed.
Future<MatchFilters?> showMatchSheet(BuildContext context) {
  return showModalBottomSheet<MatchFilters>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (BuildContext context) => const _MatchSheet(),
  );
}

class _MatchSheet extends StatefulWidget {
  const _MatchSheet();

  @override
  State<_MatchSheet> createState() => _MatchSheetState();
}

class _MatchSheetState extends State<_MatchSheet> {
  static const List<String> _categories = <String>[
    'Mountains',
    'City walk',
    'Food',
    'Culture',
    'Ski',
  ];
  static const List<String> _paces = <String>['Easy', 'Moderate', 'Beginner'];
  static const List<String> _languages = <String>['EN', 'RU', 'KZ'];

  String? _category;
  String? _pace;
  String? _language;

  void _apply() {
    Navigator.of(context).pop(
      MatchFilters(category: _category, pace: _pace, language: _language),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.md,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Find your match', style: text.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Three questions. We look at interests, pace and language, '
              'not only at the price.',
              style: text.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            _QuestionBlock(
              question: 'What do you want to see?',
              options: _categories,
              selected: _category,
              onSelected: (String? value) => setState(() => _category = value),
            ),
            _QuestionBlock(
              question: 'Your pace',
              options: _paces,
              selected: _pace,
              onSelected: (String? value) => setState(() => _pace = value),
            ),
            _QuestionBlock(
              question: 'Language of the tour',
              options: _languages,
              selected: _language,
              onSelected: (String? value) => setState(() => _language = value),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: <Widget>[
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(
                    const MatchFilters(),
                  ),
                  child: const Text('Clear'),
                ),
                const SizedBox(width: AppSpacing.md),
                // Expanded: the main action always fills the rest of the row.
                Expanded(
                  child: ElevatedButton(
                    onPressed: _apply,
                    child: const Text('Show my matches'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionBlock extends StatelessWidget {
  const _QuestionBlock({
    required this.question,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String question;
  final List<String> options;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(question, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              for (final String option in options)
                ChoiceChip(
                  label: Text(option),
                  selected: selected == option,
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: selected == option
                        ? Colors.white
                        : AppColors.ink,
                  ),
                  backgroundColor: Colors.white,
                  selectedColor: AppColors.brand,
                  side: BorderSide(
                    color: selected == option
                        ? AppColors.brand
                        : AppColors.line,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.pillAll,
                  ),
                  onSelected: (bool value) =>
                      onSelected(value ? option : null),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
