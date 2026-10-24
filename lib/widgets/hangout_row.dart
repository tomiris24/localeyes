import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/local_person.dart';

/// The icon that stands for each kind of hangout. Kept next to the widget that
/// draws it so the model itself stays pure Dart.
IconData hangoutIcon(HangoutKind kind) => switch (kind) {
  HangoutKind.coffee => Icons.local_cafe_outlined,
  HangoutKind.walk => Icons.directions_walk_rounded,
  HangoutKind.food => Icons.ramen_dining_outlined,
  HangoutKind.photo => Icons.photo_camera_outlined,
  HangoutKind.nightOut => Icons.nightlife_outlined,
  HangoutKind.music => Icons.music_note_outlined,
  HangoutKind.sport => Icons.hiking_rounded,
  HangoutKind.language => Icons.translate_rounded,
};

/// One thing a local offers to do, with their own note under it.
class HangoutRow extends StatelessWidget {
  const HangoutRow({super.key, required this.idea});

  final HangoutIdea idea;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.canvas,
              shape: BoxShape.circle,
            ),
            child: Icon(hangoutIcon(idea.kind), size: 19, color: AppColors.brand),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(idea.title, style: text.titleSmall),
                const SizedBox(height: 2),
                Text(idea.note, style: text.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
