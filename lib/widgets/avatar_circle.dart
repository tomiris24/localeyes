import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Initials avatar in brand colours. No photo assets of real people are used.
class AvatarCircle extends StatelessWidget {
  const AvatarCircle({
    super.key,
    required this.initials,
    this.size = 48,
    this.isVerified = false,
  });

  final String initials;
  final double size;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    final Widget circle = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.brand, AppColors.brandDeep],
        ),
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    if (!isVerified) return circle;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          circle,
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.verified_rounded,
                size: size * 0.32,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
