import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../models/account.dart';
import '../state/app_state.dart';
import '../state/auth_controller.dart';
import '../state/notes_controller.dart';
import '../state/settings_controller.dart';
import '../widgets/avatar_circle.dart';
import '../widgets/photo_header.dart';
import '../widgets/section_header.dart';
import '../widgets/tag_chip.dart';
import 'become_local_screen.dart';
import 'saved_screen.dart';
import 'trip_notes_screen.dart';

/// Traveller profile. Verification and preferences are what make the
/// two-sided trust system work for guides as well.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  /// Two letters for the avatar, from whatever the traveller called
  /// themselves on this phone.
  static String _initials(String name) {
    final List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length < 2) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

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
    final AuthController auth = context.watch<AuthController>();
    final SettingsController settings = context.watch<SettingsController>();
    final NotesController notes = context.watch<NotesController>();
    final Account? account = auth.account;
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const PhotoHeader(title: 'Profile'),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: context.palette.surface,
                  borderRadius: AppRadius.cardAll,
                  border: Border.all(color: context.palette.line),
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        AvatarCircle(
                          initials: _initials(settings.displayName),
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
                                settings.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: text.titleLarge,
                              ),
                              if (account != null) ...<Widget>[
                                const SizedBox(height: 2),
                                Text(
                                  account.email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: text.bodySmall,
                                ),
                              ],
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: AppSpacing.xs,
                                runSpacing: AppSpacing.xs,
                                children: <Widget>[
                                  if (account != null)
                                    TagChip(
                                      label: account.role.label,
                                      icon: Icons.badge_outlined,
                                      dense: true,
                                    ),
                                  const TagChip(
                                    label: 'ID verified',
                                    icon: Icons.verified_user_outlined,
                                    tone: ChipTone.success,
                                    dense: true,
                                  ),
                                ],
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
              const SizedBox(height: AppSpacing.sm),
              _MenuTile(
                icon: Icons.checklist_rounded,
                title: 'Trip notes',
                subtitle: notes.notes.isEmpty
                    ? 'Nothing written down yet'
                    : '${notes.remaining} left of ${notes.notes.length}',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const TripNotesScreen(),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(
                title: 'On this phone',
                subtitle: 'Kept locally, with or without a connection',
              ),
              const SizedBox(height: AppSpacing.md),
              const _AppearanceCard(),
              const SizedBox(height: AppSpacing.sm),
              const _DisplayNameCard(),
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
              // Signing out is the only account action that belongs here:
              // this person already has an account, so there is nothing to
              // create. The sign-in form comes back by itself, because
              // AuthGate is watching the same controller.
              OutlinedButton.icon(
                onPressed: auth.signOut,
                icon: const Icon(Icons.logout_rounded, size: 19),
                label: const Text('Log out'),
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
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.palette.line),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.palette.brandTint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 19, color: context.palette.brand),
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
          Icon(Icons.chevron_right_rounded, color: context.palette.inkMuted),
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

/// The dark-mode switch. The choice is written to the phone immediately, and
/// `main()` reads it back before the first frame on the next launch — which
/// is why a dark app opens dark, with no white flash in between.
class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard();

  @override
  Widget build(BuildContext context) {
    final SettingsController settings = context.watch<SettingsController>();
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 4, AppSpacing.sm, 4),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: context.palette.line),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Dark mode', style: text.titleSmall),
                Text(
                  settings.darkMode == null
                      ? 'Following your phone'
                      : 'Saved on this phone',
                  style: text.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: settings.isDark(context),
            onChanged: settings.setDarkMode,
            activeThumbColor: context.palette.brandDeep,
          ),
        ],
      ),
    );
  }
}

/// The name shown at the top of this screen. It is a preference, not an
/// account field: it never leaves the phone, and a fresh install reads back
/// "Guest User".
class _DisplayNameCard extends StatefulWidget {
  const _DisplayNameCard();

  @override
  State<_DisplayNameCard> createState() => _DisplayNameCardState();
}

class _DisplayNameCardState extends State<_DisplayNameCard> {
  late final TextEditingController _controller = TextEditingController(
    text: context.read<SettingsController>().hasDisplayName
        ? context.read<SettingsController>().displayName
        : '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final SettingsController settings = context.read<SettingsController>();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    await settings.setDisplayName(_controller.text);
    if (!mounted) return;
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text('Saved as ${settings.displayName}')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: context.palette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Display name', style: text.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _save(),
                  decoration: InputDecoration(
                    hintText: 'Guest User',
                    filled: true,
                    fillColor: context.palette.surfaceHigh,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: 12,
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
                      borderSide: BorderSide(color: context.palette.brand),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, AppSize.buttonMedium),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
