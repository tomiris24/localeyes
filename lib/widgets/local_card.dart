import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/local_person.dart';
import 'avatar_circle.dart';
import 'availability_pill.dart';
import 'hangout_row.dart';

/// The card on the Locals feed.
///
/// A person, not a product: the face, how soon they are free and what you have
/// in common come first, and money is the last line rather than a price badge.
class LocalCard extends StatelessWidget {
  const LocalCard({
    super.key,
    required this.person,
    required this.matchNote,
    required this.isSaved,
    required this.onToggleSaved,
    required this.onTap,
  });

  final LocalPerson person;
  final String matchNote;
  final bool isSaved;
  final VoidCallback onToggleSaved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Material(
      color: Colors.white,
      borderRadius: AppRadius.cardAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AvatarCircle(
                    initials: person.initials,
                    size: 52,
                    isVerified: person.isPhoneVerified,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${person.name}, ${person.age}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.place_outlined,
                              size: 13,
                              color: AppColors.inkMuted,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                person.neighbourhood,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: text.bodySmall,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AvailabilityPill(availability: person.availability),
                      ],
                    ),
                  ),
                  // Saving a person is "keep in touch", not "add to basket",
                  // so this is a plain icon and never a bookmark ribbon.
                  IconButton(
                    onPressed: onToggleSaved,
                    visualDensity: VisualDensity.compact,
                    tooltip: isSaved ? 'Remove from my people' : 'Keep for later',
                    icon: Icon(
                      isSaved
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 22,
                      color: isSaved ? AppColors.brand : AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                person.oneLiner,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: text.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: <Widget>[
                  for (final HangoutIdea idea in person.hangouts.take(2))
                    _MiniTag(icon: hangoutIcon(idea.kind), label: idea.title),
                  _MiniTag(
                    icon: Icons.translate_rounded,
                    label: person.languages
                        .map((LanguageSkill l) => l.label)
                        .join(', '),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 14,
                    color: AppColors.brand,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      matchNote,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brand,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    person.costLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small outlined tag used inside the card. Narrower than [TagChip] because
/// several of them share one row on a 320 px screen.
class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width - 72,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.canvas,
          borderRadius: AppRadius.pillAll,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 13, color: AppColors.inkMuted),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brandDeep,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
