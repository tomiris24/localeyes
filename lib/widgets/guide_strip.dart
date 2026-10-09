import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/guide.dart';
import 'avatar_circle.dart';

/// The guide block on the detail screen: who you are actually going with.
class GuideStrip extends StatelessWidget {
  const GuideStrip({super.key, required this.guide, this.onMessage});

  final Guide guide;
  final VoidCallback? onMessage;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
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
              AvatarCircle(
                initials: guide.initials,
                size: 52,
                isVerified: guide.isVerified,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      guide.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${guide.yearsOfExperience} years guiding · '
                      '${guide.tourCount} tours · ${guide.languages.join(" / ")}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(guide.bio, style: text.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              const Icon(
                Icons.schedule_rounded,
                size: 15,
                color: AppColors.inkMuted,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  guide.responseTime,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              OutlinedButton(
                onPressed: onMessage,
                child: const Text('Message'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
