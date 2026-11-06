import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/avatar_circle.dart';
import '../widgets/section_header.dart';
import '../widgets/tag_chip.dart';
import 'become_local_screen.dart';
import 'register_screen.dart';
import 'saved_screen.dart';

/// Traveller profile. Verification and preferences are what make the
/// two-sided trust system work for guides as well.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const List<String> _interests = <String>[
    'Mountains',
    'Food',
    'Photography',
    'Slow pace',
    'Small groups',
    'EN / RU',
  ];

  @override
  Widget build(BuildContext context) {
    final AppState app = AppScope.of(context);
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), titleSpacing: AppSpacing.lg),
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
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.cardAll,
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const AvatarCircle(
                          initials: 'TS',
                          size: 60,
                          isVerified: true,
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Tomiris S.',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: text.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              const TagChip(
                                label: 'ID verified',
                                icon: Icons.verified_user_outlined,
                                tone: ChipTone.success,
                                dense: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: <Widget>[
                        _Stat(value: '6', label: 'Trips'),
                        _Stat(
                          value: '${app.savedTours.length}',
                          label: 'Saved',
                        ),
                        const _Stat(value: '4.9', label: 'As a guest'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Your lists'),
              const SizedBox(height: AppSpacing.md),
              _MenuTile(
                icon: Icons.bookmark_outline_rounded,
                title: 'Saved tours',
                subtitle: app.savedTours.isEmpty
                    ? 'Nothing saved yet'
                    : '${app.savedTours.length} waiting for you',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const SavedScreen(),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(
                title: 'What I like',
                subtitle: 'Guides see this before they accept a booking',
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: <Widget>[
                  for (final String interest in _interests)
                    TagChip(label: interest),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Safety'),
              const SizedBox(height: AppSpacing.md),
              const _MenuTile(
                icon: Icons.badge_outlined,
                title: 'Identity document',
                subtitle: 'Checked on 2 Oct 2026',
              ),
              const _MenuTile(
                icon: Icons.share_location_rounded,
                title: 'Share live location',
                subtitle: 'Always ask before a tour starts',
              ),
              const _MenuTile(
                icon: Icons.support_agent_rounded,
                title: 'Safety manager',
                subtitle: 'Available 24/7 during a tour',
              ),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Account'),
              const SizedBox(height: AppSpacing.md),
              const _MenuTile(
                icon: Icons.credit_card_rounded,
                title: 'Payment methods',
                subtitle: 'Deposit 20%, the rest after the tour',
              ),
              const _MenuTile(
                icon: Icons.translate_rounded,
                title: 'App language',
                subtitle: 'English',
              ),
              const SizedBox(height: AppSpacing.md),
              // Anyone can switch sides. A traveller who liked the city is the
              // most likely person to sign up as a local back home.
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        const BecomeLocalScreen(),
                  ),
                ),
                icon: const Icon(Icons.waving_hand_rounded, size: 19),
                label: const Text('Become a local'),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const RegisterScreen(),
                  ),
                ),
                icon: const Icon(Icons.person_add_alt_rounded, size: 19),
                label: const Text('Create a new account'),
              ),
            ],
          ),
        ),
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
    final TextTheme text = Theme.of(context).textTheme;

    return Expanded(
      child: Column(
        children: <Widget>[
          Text(value, style: text.titleLarge),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  /// Set on the tiles that lead somewhere. The rest are read-only rows.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    final Widget body = Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.brandSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 19, color: AppColors.brand),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleSmall,
                ),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: onTap == null
          ? body
          : InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: body,
            ),
    );
  }
}
