import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../data/mock_locals.dart';
import '../models/local_person.dart';
import '../models/spot.dart';
import '../state/app_state.dart';
import '../widgets/avatar_circle.dart';
import '../widgets/availability_pill.dart';
import '../widgets/hangout_row.dart';
import '../widgets/section_header.dart';
import '../widgets/spot_card.dart';
import '../widgets/tag_chip.dart';
import 'meetup_request_screen.dart';

/// One local's profile.
///
/// The whole [LocalPerson] is handed in by the feed, the same way the tour
/// detail screen receives its [Tour], so this screen never looks anything up.
class LocalProfileScreen extends StatelessWidget {
  const LocalProfileScreen({super.key, required this.person});

  final LocalPerson person;

  void _requestMeetup(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => MeetupRequestScreen(person: person),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState app = AppScope.of(context);
    final TextTheme text = Theme.of(context).textTheme;
    final List<Spot> theirSpots = MockLocals.spotsBy(person.id);
    final bool pending = app.hasPendingMeetupWith(person.id);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.lg,
        title: Text(person.name),
        actions: <Widget>[
          IconButton(
            tooltip: app.isLocalSaved(person.id)
                ? 'Remove from my people'
                : 'Keep for later',
            onPressed: () {
              final bool saved = app.toggleSavedLocal(person.id);
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      saved ? '${person.name} saved' : '${person.name} removed',
                    ),
                  ),
                );
            },
            icon: Icon(
              app.isLocalSaved(person.id)
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
            ),
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
              _Header(person: person),
              const SizedBox(height: AppSpacing.lg),
              Text(person.bio, style: text.bodyLarge),
              const SizedBox(height: AppSpacing.lg),

              // Languages with the level written out. "English" on its own was
              // the complaint travellers kept making about guide profiles.
              const SectionHeader(title: 'Languages'),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: <Widget>[
                  for (final LanguageSkill skill in person.languages)
                    TagChip(label: skill.label, icon: Icons.translate_rounded),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              const SectionHeader(
                title: 'What we could do',
                subtitle: 'Their suggestions, not a fixed route',
              ),
              for (final HangoutIdea idea in person.hangouts)
                HangoutRow(idea: idea),
              const SizedBox(height: AppSpacing.lg),

              const SectionHeader(title: 'Into'),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: <Widget>[
                  for (final String interest in person.interests)
                    TagChip(
                      label: interest,
                      tone: app.myInterests.contains(interest)
                          ? ChipTone.soft
                          : ChipTone.outline,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              _CostCard(person: person),
              const SizedBox(height: AppSpacing.xl),

              if (theirSpots.isNotEmpty) ...<Widget>[
                SectionHeader(title: '${person.name.split(' ').first}\'s places'),
                const SizedBox(height: AppSpacing.md),
                for (final Spot spot in theirSpots)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: SpotCard(spot: spot),
                  ),
                const SizedBox(height: AppSpacing.sm),
              ],

              const _SafetyCard(),
              const SizedBox(height: AppSpacing.lg),

              // Second way back, matching the tour detail screen.
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded, size: 19),
                label: const Text('Back to people'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _MeetBar(
        person: person,
        pending: pending,
        onPressed: () => _requestMeetup(context),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.person});

  final LocalPerson person;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AvatarCircle(
                initials: person.initials,
                size: 64,
                isVerified: person.isPhoneVerified,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${person.name}, ${person.age}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.headlineSmall,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Lives in ${person.neighbourhood}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AvailabilityPill(availability: person.availability),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(person.oneLiner, style: text.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          // Numbers that say "a person who has done this a few times", not
          // "a business". Meets, not bookings.
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              _Stat(value: '${person.meetCount}', label: 'people met'),
              _Stat(
                value: person.rating.toStringAsFixed(1),
                label: 'out of 5',
              ),
              _Stat(value: person.memberSince, label: 'here since'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              const Icon(
                Icons.schedule_rounded,
                size: 14,
                color: AppColors.inkMuted,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '${person.responseTime} · around ${person.usualTimes.toLowerCase()}',
                  style: text.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11.5, color: AppColors.inkMuted),
        ),
      ],
    );
  }
}

/// Money, stated before anyone asks. Most locals charge nothing, and hiding
/// that behind a "contact for price" line is what makes people hesitate.
class _CostCard extends StatelessWidget {
  const _CostCard({required this.person});

  final LocalPerson person;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.brandSoft.withValues(alpha: 0.35),
        borderRadius: AppRadius.cardAll,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.payments_outlined,
            size: 20,
            color: AppColors.brandDeep,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  person.costLabel,
                  style: text.titleMedium?.copyWith(
                    color: AppColors.brandDeep,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  person.costNote,
                  style: text.bodySmall?.copyWith(color: AppColors.brandDeep),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyCard extends StatelessWidget {
  const _SafetyCard();

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.shield_outlined,
            size: 20,
            color: AppColors.success,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('First meetings are in public', style: text.titleSmall),
                const SizedBox(height: 3),
                Text(
                  'The app only offers public meeting points for a first '
                  'meetup, and you can share your plan with a friend from the '
                  'request screen.',
                  style: text.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Sticky bar at the bottom. One action, written the way a person would say
/// it — "Say hi", not "Book now".
class _MeetBar extends StatelessWidget {
  const _MeetBar({
    required this.person,
    required this.pending,
    required this.onPressed,
  });

  final LocalPerson person;
  final bool pending;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Row(
            children: <Widget>[
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      person.costLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium,
                    ),
                    Text(
                      person.availability.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onPressed,
                  icon: Icon(
                    pending
                        ? Icons.hourglass_top_rounded
                        : Icons.waving_hand_rounded,
                    size: 19,
                  ),
                  label: Text(pending ? 'Waiting for reply' : 'Say hi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
