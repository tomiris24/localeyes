import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/review.dart';
import '../models/tour.dart';
import '../state/app_state.dart';
import '../widgets/avatar_circle.dart';
import '../widgets/booking_bar.dart';
import '../widgets/cover_header.dart';
import '../widgets/fact_tile.dart';
import '../widgets/guide_strip.dart';
import '../widgets/quantity_stepper.dart';
import '../widgets/rating_stars.dart';
import '../widgets/section_header.dart';
import '../widgets/tag_chip.dart';
import 'cart_screen.dart';

/// Detail screen of one tour — the "item detail" screen of the app.
///
/// Layout plan:
///  * [CoverHeader] is a Stack: photo + gradients + bookmark badge on top.
///  * Title, rating, price and category badges use Row and Wrap.
///  * [BookingBar] is a sticky bottom bar where the main button uses Expanded.
///  * Below 840 px everything is one column, above it the screen splits in two.
class TourDetailScreen extends StatefulWidget {
  const TourDetailScreen({super.key, required this.tour});

  final Tour tour;

  @override
  State<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen> {
  static const List<String> _tabs = <String>['About', 'Route', 'Reviews'];

  int _guests = 2;
  int _tabIndex = 0;
  late String _selectedDate = widget.tour.availableDates.first;

  Tour get _tour => widget.tour;

  @override
  void didUpdateWidget(TourDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the screen is reused for another tour, reset the booking options.
    if (oldWidget.tour.id != widget.tour.id) {
      _guests = 2;
      _tabIndex = 0;
      _selectedDate = widget.tour.availableDates.first;
    }
  }

  void _selectTab(int index) => setState(() => _tabIndex = index);

  void _changeGuests(int value) => setState(() => _guests = value);

  void _selectDate(String date) => setState(() => _selectedDate = date);

  void _toggleSaved() {
    final bool nowSaved = AppScope.of(context).toggleSaved(_tour.id);
    _showMessage(nowSaved ? 'Saved to your list' : 'Removed from your list');
  }

  void _addToCart() {
    AppScope.of(context).addToCart(
      CartItem(tourId: _tour.id, guests: _guests, date: _selectedDate),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$_guests × ${_tour.title} added to cart'),
          action: SnackBarAction(
            label: 'View cart',
            textColor: Colors.white,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const CartScreen()),
            ),
          ),
        ),
      );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final AppState app = AppScope.of(context);
    final bool isSaved = app.isSaved(_tour.id);
    final bool inCart = app.isInCart(_tour.id);

    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool isWide = constraints.maxWidth >= AppSpacing.wideBreakpoint;
          return isWide
              ? _buildWideLayout(context, constraints, isSaved)
              : _buildNarrowLayout(context, constraints, isSaved);
        },
      ),
      bottomNavigationBar: BookingBar(
        total: _tour.totalFor(_guests),
        caption: 'for $_guests · $_selectedDate',
        label: inCart ? 'Update cart' : 'Add to cart',
        icon: inCart
            ? Icons.check_rounded
            : Icons.add_shopping_cart_rounded,
        onPressed: _addToCart,
      ),
    );
  }

  // ---------------------------------------------------------------- layouts

  Widget _buildNarrowLayout(
    BuildContext context,
    BoxConstraints constraints,
    bool isSaved,
  ) {
    final double coverHeight = (constraints.maxHeight * 0.36).clamp(200.0, 340.0);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CoverHeader(
            tour: _tour,
            isSaved: isSaved,
            onToggleSaved: _toggleSaved,
            height: coverHeight,
            topInset: MediaQuery.paddingOf(context).top,
            onShare: () => _showMessage('Sharing is coming in Milestone 2'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ..._mainColumn(context),
                const SizedBox(height: AppSpacing.xl),
                ..._sideColumn(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideLayout(
    BuildContext context,
    BoxConstraints constraints,
    bool isSaved,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      CoverHeader(
                        tour: _tour,
                        isSaved: isSaved,
                        onToggleSaved: _toggleSaved,
                        height: (constraints.maxHeight * 0.5).clamp(260.0, 420.0),
                        borderRadius: AppRadius.cardAll,
                        onShare: () =>
                            _showMessage('Sharing is coming in Milestone 2'),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      ..._sideColumn(context),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _mainColumn(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------ content

  /// Title, rating, badges and the tab block.
  List<Widget> _mainColumn(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return <Widget>[
      // Title on the left, price on the right. Expanded stops long titles
      // from pushing the price off the screen.
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              _tour.title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: text.headlineSmall,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '\$${_tour.pricePerPerson.toStringAsFixed(0)}',
                style: text.headlineSmall?.copyWith(color: AppColors.brand),
              ),
              Text('per person', style: text.bodySmall),
            ],
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.md),

      // Star rating + review count + duration.
      Row(
        children: <Widget>[
          RatingStars(rating: _tour.rating, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Text(_tour.rating.toStringAsFixed(1), style: text.titleSmall),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '(${_tour.reviewCount} reviews) · ${_tour.duration}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.bodySmall,
            ),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.lg),

      // Category badges. Wrap moves them to the next line instead of overflowing.
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: <Widget>[
          TagChip(label: _tour.category, icon: Icons.local_offer_outlined),
          for (final String tag in _tour.tags)
            TagChip(label: tag, tone: ChipTone.outline),
        ],
      ),
      const SizedBox(height: AppSpacing.xl),

      _buildTabBar(context),
      const SizedBox(height: AppSpacing.lg),
      _buildTabContent(context),
    ];
  }

  /// Facts, guide, dates and group size.
  List<Widget> _sideColumn(BuildContext context) {
    return <Widget>[
      const SectionHeader(
        title: 'Good to know',
        subtitle: 'The details travellers usually have to ask for',
      ),
      const SizedBox(height: AppSpacing.md),
      _buildFactsGrid(),
      const SizedBox(height: AppSpacing.xl),
      const SectionHeader(title: 'Your guide'),
      const SizedBox(height: AppSpacing.md),
      GuideStrip(
        guide: _tour.guide,
        onMessage: () => _showMessage('Chat opens in Milestone 2'),
      ),
      const SizedBox(height: AppSpacing.xl),
      const SectionHeader(title: 'Pick a date'),
      const SizedBox(height: AppSpacing.md),
      _buildDatePicker(context),
      const SizedBox(height: AppSpacing.xl),
      _buildGuestPicker(context),
    ];
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: AppColors.brandSoft,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        children: List<Widget>.generate(_tabs.length, (int index) {
          final bool selected = _tabIndex == index;
          // Expanded gives all three tabs the same width on any screen.
          return Expanded(
            child: GestureDetector(
              onTap: () => _selectTab(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: AppRadius.pillAll,
                ),
                child: Text(
                  _tabs[index],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    // The soft blue track is too dark for the muted grey:
                    // the deep brand colour keeps unselected tabs readable.
                    color: selected ? AppColors.brand : AppColors.brandDeep,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: switch (_tabIndex) {
        1 => _buildRoute(context),
        2 => _buildReviews(context),
        _ => _buildAbout(context),
      },
    );
  }

  Widget _buildAbout(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      key: const ValueKey<String>('about'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(_tour.summary, style: text.bodyLarge),
        const SizedBox(height: AppSpacing.lg),
        Text('What is included', style: text.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        for (final String item in _tour.included)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(
                  Icons.check_circle_rounded,
                  size: 17,
                  color: AppColors.success,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(item, style: text.bodyMedium)),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(
                Icons.shield_outlined,
                size: 18,
                color: AppColors.success,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'ID of the guide is checked. You can share your live location '
                  'with a friend during the tour, and the route is agreed in the '
                  'chat before you meet.',
                  style: text.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoute(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      key: const ValueKey<String>('route'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = 0; i < _tour.route.length; i++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 52,
                child: Text(
                  _tour.route[i].time,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleSmall?.copyWith(color: AppColors.brand),
                ),
              ),
              Column(
                children: <Widget>[
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: AppColors.brand,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (i != _tour.route.length - 1)
                    Container(width: 2, height: 46, color: AppColors.line),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(_tour.route[i].title, style: text.titleSmall),
                      if (_tour.route[i].note.isNotEmpty)
                        Text(_tour.route[i].note, style: text.bodySmall),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildReviews(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      key: const ValueKey<String>('reviews'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final Review review in _tour.reviews)
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
                  children: <Widget>[
                    AvatarCircle(initials: review.initials, size: 38),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            review.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleSmall,
                          ),
                          Text(
                            '${review.country} · ${review.timeAgo}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    RatingStars(rating: review.rating, size: 13),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(review.text, style: text.bodyMedium),
              ],
            ),
          ),
      ],
    );
  }

  /// Two facts per row on phones, more on wide screens, never an overflow:
  /// the tile width is calculated from the space the parent really gives us.
  Widget _buildFactsGrid() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = constraints.maxWidth >= 520 ? 3 : 2;
        final double tileWidth =
            (constraints.maxWidth - AppSpacing.md * (columns - 1)) / columns;

        final List<FactTile> tiles = <FactTile>[
          FactTile(
            icon: Icons.terrain_outlined,
            label: 'Difficulty',
            value: _tour.facts.difficulty,
          ),
          FactTile(
            icon: Icons.directions_walk_rounded,
            label: 'Walking',
            value: _tour.facts.walkingTime,
          ),
          FactTile(
            icon: Icons.groups_outlined,
            label: 'Group size',
            value: _tour.facts.groupSize,
          ),
          FactTile(
            icon: Icons.translate_rounded,
            label: 'Language',
            value: _tour.facts.languageLevel,
          ),
          FactTile(
            icon: Icons.pin_drop_outlined,
            label: 'Meeting point',
            value: _tour.facts.meetingPoint,
          ),
          FactTile(
            icon: Icons.schedule_rounded,
            label: 'Duration',
            value: _tour.duration,
          ),
        ];

        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: <Widget>[
            for (final FactTile tile in tiles)
              SizedBox(width: tileWidth, child: tile),
          ],
        );
      },
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: <Widget>[
        for (final String date in _tour.availableDates)
          _DateChip(
            label: date,
            selected: date == _selectedDate,
            onTap: () => _selectDate(date),
          ),
      ],
    );
  }

  Widget _buildGuestPicker(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Travellers', style: text.titleMedium),
              Text(
                'This guide takes up to ${_tour.maxGuests} people',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: text.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        QuantityStepper(
          value: _guests,
          min: 1,
          max: _tour.maxGuests,
          onChanged: _changeGuests,
        ),
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.brand : Colors.white,
      borderRadius: AppRadius.pillAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.pillAll,
            border: Border.all(
              color: selected ? AppColors.brand : AppColors.line,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
