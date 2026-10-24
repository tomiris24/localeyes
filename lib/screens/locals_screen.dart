import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../data/mock_locals.dart';
import '../models/local_person.dart';
import '../state/app_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/local_card.dart';
import 'become_local_screen.dart';
import 'local_profile_screen.dart';
import 'spots_screen.dart';

/// The main feed of the app: people who live here, not tours.
///
/// The order is deliberate — whoever is free soonest comes first, because the
/// traveller is usually already in the city when they open this.
class LocalsScreen extends StatefulWidget {
  const LocalsScreen({super.key});

  @override
  State<LocalsScreen> createState() => _LocalsScreenState();
}

class _LocalsScreenState extends State<LocalsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';
  Availability? _when;
  String? _interest;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LocalPerson> get _results {
    final List<LocalPerson> found = MockLocals.people.where((LocalPerson p) {
      final bool byQuery =
          _query.isEmpty ||
          p.name.toLowerCase().contains(_query) ||
          p.neighbourhood.toLowerCase().contains(_query) ||
          p.oneLiner.toLowerCase().contains(_query) ||
          p.interests.any((String i) => i.toLowerCase().contains(_query));
      final bool byWhen = _when == null || p.availability == _when;
      final bool byInterest =
          _interest == null || p.interests.contains(_interest);
      return byQuery && byWhen && byInterest;
    }).toList();

    // Soonest first, then the people who have met the most travellers.
    found.sort((LocalPerson a, LocalPerson b) {
      final int byWhen = a.availability.index.compareTo(b.availability.index);
      if (byWhen != 0) return byWhen;
      return b.meetCount.compareTo(a.meetCount);
    });
    return found;
  }

  void _search(String value) =>
      setState(() => _query = value.trim().toLowerCase());

  void _selectWhen(Availability? value) => setState(() => _when = value);

  void _selectInterest(String? value) => setState(() => _interest = value);

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _when = null;
      _interest = null;
    });
  }

  void _openPerson(LocalPerson person) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => LocalProfileScreen(person: person),
      ),
    );
  }

  void _openSpots() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const SpotsScreen(),
      ),
    );
  }

  void _openBecomeLocal() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const BecomeLocalScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState app = AppScope.of(context);
    final TextTheme text = Theme.of(context).textTheme;
    final List<LocalPerson> results = _results;
    final int freeToday = MockLocals.people
        .where((LocalPerson p) => p.availability == Availability.today)
        .length;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.lg,
        title: const Text('Meet a local'),
        actions: <Widget>[
          IconButton(
            onPressed: _openBecomeLocal,
            tooltip: 'Become a local',
            icon: const Icon(Icons.waving_hand_outlined),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            children: <Widget>[
              Text(
                '$freeToday people are free today in Almaty.',
                style: text.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _searchController,
                onChanged: _search,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Coffee, mountains, a name…',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: 14,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: AppRadius.pillAll,
                    borderSide: BorderSide(color: AppColors.line),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: AppRadius.pillAll,
                    borderSide: BorderSide(color: AppColors.line),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: AppRadius.pillAll,
                    borderSide: BorderSide(color: AppColors.brand),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _FilterRow(
                labels: <String>[
                  'Anyone',
                  ...Availability.values.map(
                    (Availability a) => a.shortLabel,
                  ),
                ],
                selectedIndex: _when == null ? 0 : _when!.index + 1,
                onSelect: (int index) => _selectWhen(
                  index == 0 ? null : Availability.values[index - 1],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _FilterRow(
                labels: <String>['Any interest', ...MockLocals.interests],
                selectedIndex: _interest == null
                    ? 0
                    : MockLocals.interests.indexOf(_interest!) + 1,
                onSelect: (int index) => _selectInterest(
                  index == 0 ? null : MockLocals.interests[index - 1],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SpotsBanner(onTap: _openSpots),
              const SizedBox(height: AppSpacing.lg),
              if (results.isEmpty)
                EmptyState(
                  icon: Icons.person_search_outlined,
                  title: 'Nobody matches that yet',
                  message:
                      'Only six people are signed up in this demo. Clear the '
                      'filters to see all of them.',
                  actionLabel: 'Clear filters',
                  onAction: _clearFilters,
                )
              else
                for (final LocalPerson person in results)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: LocalCard(
                      person: person,
                      matchNote: person.matchNote(app.myInterests),
                      isSaved: app.isLocalSaved(person.id),
                      onToggleSaved: () {
                        final bool saved = app.toggleSavedLocal(person.id);
                        ScaffoldMessenger.of(context)
                          ..clearSnackBars()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(
                                saved
                                    ? '${person.name} saved'
                                    : '${person.name} removed',
                              ),
                            ),
                          );
                      },
                      onTap: () => _openPerson(person),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A horizontally scrolling row of choice chips.
///
/// It scrolls instead of wrapping so the filters never push the first card
/// off a small screen.
class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.labels,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (BuildContext context, int index) {
          final bool selected = index == selectedIndex;
          return ChoiceChip(
            label: Text(labels[index]),
            selected: selected,
            onSelected: (_) => onSelect(index),
            showCheckmark: false,
            backgroundColor: Colors.white,
            selectedColor: AppColors.brand,
            side: BorderSide(
              color: selected ? AppColors.brand : AppColors.line,
            ),
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.ink,
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

/// Entry point to the spots map — the city described by the people who live
/// in it, browsable before you commit to meeting anyone.
class _SpotsBanner extends StatelessWidget {
  const _SpotsBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.brand,
      borderRadius: AppRadius.cardAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.pin_drop_outlined,
                color: AppColors.brandSoft,
                size: 26,
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'The city through their eyes',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Places locals added themselves, and why they matter',
                      style: TextStyle(fontSize: 12.5, color: AppColors.brandSoft),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 19,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
