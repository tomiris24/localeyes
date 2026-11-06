import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/tour.dart';
import 'avatar_circle.dart';
import 'bookmark_badge.dart';
import 'cart_toggle_button.dart';

/// Card used on the discovery feed and on the saved screen.
///
/// It reads like a social post: the guide owns the top row, the photo gets a
/// whole 4:3 frame so it stays the loudest thing on the screen, and the
/// caption underneath carries the title, one quiet meta line and the price.
/// Putting the guide above the photo is the point — "a verified local took
/// you here" is what the app sells, and the old layout never showed it.
///
/// The card is deliberately spare: nothing floats on the photo, every fact
/// appears once, and the price is the only loud thing in the caption. The
/// rating is a single star and a number rather than five glyphs, and there is
/// no "top rated" flag because a visible 4.9 already says it.
///
/// Everything except the photo has a fixed height, so the card height follows
/// from its width alone. That is what lets both feeds ask [gridDelegate] for
/// an exact extent instead of guessing one, and it is why the two screens
/// cannot drift apart.
class TourCard extends StatelessWidget {
  const TourCard({
    super.key,
    required this.tour,
    required this.isSaved,
    required this.onToggleSaved,
    required this.onTap,
  });

  final Tour tour;
  final bool isSaved;
  final VoidCallback onToggleSaved;
  final VoidCallback onTap;

  /// The photos ship between 1.33 and 1.57 wide, so a 4:3 frame crops them by
  /// a little at most. A portrait frame would cut a third off every panorama.
  static const double _photoAspect = 4 / 3;

  /// A card never grows past this, otherwise the photo turns into a banner.
  static const double _maxCardWidth = 420;

  static const double _authorRowHeight = 60;
  static const double _captionHeight = 148;

  /// Text inside the card is capped at this scale. The fixed rows above are
  /// sized for it, so a reader on large system text gets a tighter card
  /// instead of a broken one.
  static const double _maxTextScale = 1.2;

  /// Height this card needs when laid out [width] wide.
  static double heightForWidth(double width) =>
      _authorRowHeight + _captionHeight + width / _photoAspect;

  /// Responsive delegate that pairs the column count with the matching card
  /// height. [availableWidth] is the width left after the feed's own padding.
  static SliverGridDelegate gridDelegate(double availableWidth) {
    final double usable = availableWidth.clamp(1.0, double.infinity);
    final int columns = (usable / _maxCardWidth).ceil().clamp(1, 4);
    final double columnWidth =
        ((usable - AppSpacing.lg * (columns - 1)) / columns).clamp(
          1.0,
          double.infinity,
        );

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      mainAxisExtent: heightForWidth(columnWidth),
      crossAxisSpacing: AppSpacing.lg,
      mainAxisSpacing: AppSpacing.lg,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: _maxTextScale,
      child: Material(
        color: Colors.white,
        borderRadius: AppRadius.cardAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildAuthorRow(context),
              AspectRatio(
                aspectRatio: _photoAspect,
                child: Image.asset(tour.image, fit: BoxFit.cover),
              ),
              _buildCaption(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Avatar, guide name and the area, with the bookmark on the right. The
  /// bookmark used to float on the photo; down here it stops punching a hole
  /// in the image and lands where a post puts its actions.
  Widget _buildAuthorRow(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return SizedBox(
      height: _authorRowHeight,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.md,
          0,
          AppSpacing.sm,
          0,
        ),
        child: Row(
          children: <Widget>[
            AvatarCircle(
              initials: tour.guide.initials,
              size: 36,
              isVerified: tour.guide.isVerified,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    tour.guide.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleSmall,
                  ),
                  Text(
                    tour.area,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall,
                  ),
                ],
              ),
            ),
            BookmarkBadge(
              isSaved: isSaved,
              onPressed: onToggleSaved,
              size: 36,
              onDarkCover: false,
            ),
          ],
        ),
      ),
    );
  }

  /// Title, one meta line, then the price and the cart action.
  ///
  /// The title leads because it is what a reader scans for. The [Spacer] sits
  /// above the price row, so the slack left by a one-line title turns into
  /// breathing room over the action instead of a hole under the heading.
  Widget _buildCaption(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return SizedBox(
      height: _captionHeight,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              tour.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: text.titleMedium,
            ),
            const SizedBox(height: 6),
            Row(
              children: <Widget>[
                const Icon(Icons.star_rounded, size: 15, color: AppColors.star),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    '${tour.rating.toStringAsFixed(1)} '
                    '(${tour.reviewCount}) · ${tour.duration}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: '\$${tour.pricePerPerson.toStringAsFixed(0)}',
                          style: text.titleLarge,
                        ),
                        TextSpan(text: ' / person', style: text.bodySmall),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Adds the tour with one traveller and the first free date.
                // The detail screen is where the date and the group size get
                // chosen properly.
                CartToggleButton(tour: tour),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
