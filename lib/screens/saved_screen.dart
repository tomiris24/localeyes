import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/tour.dart';
import '../state/app_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/tour_card.dart';
import 'tour_detail_screen.dart';

/// Tours the traveller bookmarked. The list reacts to the bookmark badge
/// on every other screen, because all of them read the same [AppState].
class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key, this.onBrowse});

  final VoidCallback? onBrowse;

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
              onAction: onBrowse,
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.maxContentWidth,
                ),
                child: GridView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 420,
                        mainAxisExtent: 326,
                        crossAxisSpacing: AppSpacing.lg,
                        mainAxisSpacing: AppSpacing.lg,
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
    );
  }
}
