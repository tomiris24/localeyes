import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../data/mock_tours.dart';
import '../models/tour.dart';
import '../state/app_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/match_sheet.dart';
import '../widgets/section_header.dart';
import '../widgets/tour_card.dart';
import 'cart_screen.dart';
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
      final bool byCategory =
          _category == 'All' || tour.category == _category;
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
                      title: _match.isEmpty ? 'Tours near Almaty' : 'Your matches',
                      subtitle:
                          '${results.length} ${results.length == 1 ? "tour" : "tours"} '
                          'from verified local guides',
                      actionLabel:
                          (_match.isEmpty && _category == 'All' && _query.isEmpty)
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
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.xl,
                    ),
                    sliver: SliverGrid(
                      // One column on a phone, two or three on a tablet.
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 420,
                            mainAxisExtent: 326,
                            crossAxisSpacing: AppSpacing.lg,
                            mainAxisSpacing: AppSpacing.lg,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          final Tour tour = results[index];
                          return TourCard(
                            tour: tour,
                            isSaved: app.isSaved(tour.id),
                            onToggleSaved: () => app.toggleSaved(tour.id),
                            onTap: () => _openTour(tour),
                          );
                        },
                        childCount: results.length,
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
              _CartButton(
                count: app.cartCount,
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
              border: OutlineInputBorder(
                borderRadius: AppRadius.pillAll,
                borderSide: const BorderSide(color: AppColors.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.pillAll,
                borderSide: const BorderSide(color: AppColors.line),
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
                color: selected ? AppColors.brand : Colors.white,
                borderRadius: AppRadius.pillAll,
                border: Border.all(
                  color: selected ? AppColors.brand : AppColors.line,
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.ink,
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
          borderRadius: AppRadius.cardAll,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[AppColors.brand, AppColors.brandDeep],
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Not sure who to pick?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Answer three questions and we show the guides that '
                    'fit your pace and language.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.86),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: _openMatchSheet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.brandDeep,
                      minimumSize: const Size(0, 42),
                    ),
                    child: const Text('Match me'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Icon(
              Icons.auto_awesome_rounded,
              size: 42,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  const _CartButton({required this.count, required this.onPressed});

  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              const Icon(
                Icons.shopping_bag_outlined,
                size: 22,
                color: AppColors.ink,
              ),
              if (count > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 16,
                    height: 16,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.brand,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
