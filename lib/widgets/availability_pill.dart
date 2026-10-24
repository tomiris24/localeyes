import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/local_person.dart';

/// Shows how soon a local can meet.
///
/// "Free today" is the whole reason a traveller opens the app on the evening
/// they land, so it gets the success colour and everything else stays quiet.
class AvailabilityPill extends StatelessWidget {
  const AvailabilityPill({super.key, required this.availability, this.dense = false});

  final Availability availability;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final bool soon =
        availability == Availability.today ||
        availability == Availability.tomorrow;

    final Color background = soon
        ? AppColors.success.withValues(alpha: 0.12)
        : AppColors.canvas;
    final Color foreground = soon ? AppColors.success : AppColors.inkMuted;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.pillAll,
        border: soon ? null : Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: foreground, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              dense ? availability.shortLabel : availability.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: dense ? 11 : 12,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
