import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../data/mock_locals.dart';
import '../models/local_person.dart';
import '../models/spot.dart';
import '../widgets/empty_state.dart';
import '../widgets/spot_card.dart';
import 'local_profile_screen.dart';

/// The city described by the people who live in it.
///
/// Every entry is somebody's opinion with their name on it — that is the
/// whole point, so the author line is a link to the person, not a byline.
class SpotsScreen extends StatefulWidget {
  const SpotsScreen({super.key, this.onlyBy});

  /// When set, the screen shows one person's places instead of everybody's.
  final String? onlyBy;

  @override
  State<SpotsScreen> createState() => _SpotsScreenState();
}

class _SpotsScreenState extends State<SpotsScreen> {
  String _area = 'All areas';

  List<Spot> get _results {
    final List<Spot> base = widget.onlyBy == null
        ? MockLocals.spots
        : MockLocals.spotsBy(widget.onlyBy!);
    if (_area == 'All areas') return base;
    return base.where((Spot s) => s.area == _area).toList();
  }

  void _openAuthor(Spot spot) {
    final LocalPerson person = MockLocals.byId(spot.addedById);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => LocalProfileScreen(person: person),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final List<Spot> results = _results;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.lg,
        title: const Text('Through their eyes'),
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
                'Places nobody puts on a tour, added by the people who go '
                'there anyway.',
                style: text.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: MockLocals.areas.length,
                  separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (BuildContext context, int index) {
                    final String area = MockLocals.areas[index];
                    final bool selected = area == _area;
                    return ChoiceChip(
                      label: Text(area),
                      selected: selected,
                      onSelected: (_) => setState(() => _area = area),
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
              ),
              const SizedBox(height: AppSpacing.lg),
              if (results.isEmpty)
                EmptyState(
                  icon: Icons.pin_drop_outlined,
                  title: 'Nothing here yet',
                  message: 'No one has added a place in $_area so far.',
                  actionLabel: 'Show all areas',
                  onAction: () => setState(() => _area = 'All areas'),
                )
              else
                for (final Spot spot in results)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: SpotCard(
                      spot: spot,
                      onTapAuthor: widget.onlyBy == null
                          ? () => _openAuthor(spot)
                          : null,
                    ),
                  ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded, size: 19),
                label: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
