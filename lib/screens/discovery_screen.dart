import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../core/app_theme.dart';
import '../data/mock_tours.dart';
import '../models/tour.dart';
import '../state/app_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/cart_badge_button.dart';
import '../widgets/match_sheet.dart';
import '../widgets/section_header.dart';
import '../widgets/tour_card.dart';
import 'cart_screen.dart';
import 'store_screen.dart';
import 'tour_detail_screen.dart';

/// Main discovery feed: search, categories, the matching card and the tour grid.
class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _category = 'All';
  String _query = '';
  MatchFilters _match = const MatchFilters();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Tour> get _results {
    return MockData.tours.where((Tour tour) {
      final bool byCategory = _category == 'All' || tour.category == _category;
      final bool byQuery =
          _query.isEmpty ||
          tour.title.toLowerCase().contains(_query) ||
          tour.area.toLowerCase().contains(_query) ||
          tour.guide.name.toLowerCase().contains(_query);
      final bool byMatchCategory =
          _match.category == null || tour.category == _match.category;
      final bool byPace =
          _match.pace == null || tour.facts.difficulty == _match.pace;
      final bool byLanguage =
          _match.language == null ||
          tour.guide.languages.contains(_match.language);
      return byCategory && byQuery && byMatchCategory && byPace && byLanguage;
    }).toList();
  }

  void _selectCategory(String category) {
    setState(() {
      _category = category;
      _match = const MatchFilters();
    });
  }

  void _search(String value) {
    setState(() => _query = value.trim().toLowerCase());
  }

  Future<void> _openMatchSheet() async {
    final MatchFilters? filters = await showMatchSheet(context);
    if (filters == null || !mounted) return;
    setState(() {
      _match = filters;
      _category = 'All';
    });
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _category = 'All';
      _match = const MatchFilters();
    });
  }

  void _openTour(Tour tour) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => TourDetailScreen(tour: tour),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState app = AppScope.of(context);
    final List<Tour> results = _results;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.maxContentWidth,
            ),
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(child: _buildHeader(context, app)),
                SliverToBoxAdapter(child: _buildCategories()),
                SliverToBoxAdapter(child: _buildMatchCard(context)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: SectionHeader(
                      title: _match.isEmpty
                          ? 'Tours near Almaty'
                          : 'Your matches',
                      subtitle:
                          '${results.length} ${results.length == 1 ? "tour" : "tours"} '
                          'from verified local guides',
                      actionLabel:
                          (_match.isEmpty &&
                              _category == 'All' &&
                              _query.isEmpty)
                          ? null
                          : 'Reset',
                      onAction: _clearFilters,
                    ),
                  ),
                ),
                if (results.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.travel_explore_rounded,
                      title: 'No tours match that',
                      message:
                          'Try another category, or clear the filters and '
                          'browse everything we have in Almaty.',
                      actionLabel: 'Clear filters',
                      onAction: _clearFilters,
                    ),
                  )
                else
                  SliverLayoutBuilder(
                    builder:
                        (
                          BuildContext context,
                          SliverConstraints constraints,
                        ) => SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            0,
                            AppSpacing.lg,
                            AppSpacing.xl,
                          ),
                          sliver: SliverGrid(
                            // One column on a phone, two or three on a tablet. The
                            // card itself decides how tall it has to be at that
                            // column width.
                            gridDelegate: TourCard.gridDelegate(
                              constraints.crossAxisExtent - AppSpacing.lg * 2,
                            ),
                            delegate: SliverChildBuilderDelegate((
                              BuildContext context,
                              int index,
                            ) {
                              final Tour tour = results[index];
                              return TourCard(
                                tour: tour,
                                isSaved: app.isSaved(tour.id),
                                onToggleSaved: () => app.toggleSaved(tour.id),
                                onTap: () => _openTour(tour),
                              );
                            }, childCount: results.length),
                          ),
                        ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppState app) {
    final TextTheme text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.place_rounded,
                          size: 15,
                          color: AppColors.brand,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Almaty, Kazakhstan',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Find your local',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.headlineMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Opens the store feed, which loads its products over the network.
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const StoreScreen(),
                  ),
                ),
                tooltip: 'Store',
                icon: const Icon(Icons.storefront_rounded),
              ),
              const SizedBox(width: AppSpacing.xs),
              CartBadgeButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const CartScreen(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _searchController,
            onChanged: _search,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search tours, places, guides',
              hintStyle: text.bodyMedium,
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.inkMuted,
              ),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        _search('');
                      },
                    ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
                borderSide: const BorderSide(color: AppColors.brand),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          0,
        ),
        itemCount: MockData.categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (BuildContext context, int index) {
          final String category = MockData.categories[index];
          final bool selected = category == _category;
          return GestureDetector(
            onTap: () => _selectCategory(category),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: selected ? AppColors.brand : Colors.transparent,
                borderRadius: AppRadius.pillAll,
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? Colors.white : AppColors.inkMuted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.cardAll,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Not sure who to pick?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Answer three questions and we show the guides that '
                    'fit your pace and language.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // A text button, not a filled one. This is an offer, not
                  // the thing the screen is for, and the tour cards below
                  // should stay the loudest part of the feed.
                  TextButton(
                    onPressed: _openMatchSheet,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.brand,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Match me  →'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
