import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/tour.dart';
import '../state/app_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/tour_card.dart';
import 'home_shell.dart';
import 'tour_detail_screen.dart';

/// Tours the traveller bookmarked. The list reacts to the bookmark badge
/// on every other screen, because all of them read the same [AppState].
///
/// This opens from the profile as a route rather than owning a tab, so it
/// gets a back arrow from the navigator for free.
class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  /// Leaves the saved list and lands on the feed.
  ///
  /// Popping alone would drop the traveller back on the profile, which is
  /// not what "browse tours" promises, so this also asks the shell to switch
  /// tabs. Outside the shell — a test, or a deep link — the pop is all there
  /// is to do.
  void _browse(BuildContext context) {
    final HomeTabs? tabs = HomeTabs.maybeOf(context);
    Navigator.of(context).pop();
    tabs?.openExplore();
  }

  @override
  Widget build(BuildContext context) {
    final AppState app = AppScope.of(context);
    final List<Tour> saved = app.savedTours;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved tours'),
        titleSpacing: AppSpacing.lg,
      ),
      body: saved.isEmpty
          ? EmptyState(
              icon: Icons.bookmark_outline_rounded,
              title: 'Nothing saved yet',
              message:
                  'Tap the bookmark on a tour and it will wait for you here '
                  'until you decide.',
              actionLabel: 'Browse tours',
              onAction: () => _browse(context),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.maxContentWidth,
                ),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) =>
                      GridView.builder(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        gridDelegate: TourCard.gridDelegate(
                          constraints.maxWidth - AppSpacing.lg * 2,
                        ),
                        itemCount: saved.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Tour tour = saved[index];
                          return TourCard(
                            tour: tour,
                            isSaved: true,
                            onToggleSaved: () => app.toggleSaved(tour.id),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    TourDetailScreen(tour: tour),
                              ),
                            ),
                          );
                        },
                      ),
                ),
              ),
            ),
    );
  }
}
