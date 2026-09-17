import 'package:flutter/material.dart';

/// Full Kidova logo (mascot + wordmark), used as a hero banner on the
/// main landing tab.
class BrandLogoBanner extends StatelessWidget {
  final double height;

  const BrandLogoBanner({super.key, this.height = 108});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/branding/logo.png',
      height: height,
      fit: BoxFit.contain,
    );
  }
}

/// Small square app-icon badge used to give secondary screens a
/// consistent touch of brand identity in their app bars.
class BrandIconBadge extends StatelessWidget {
  final double size;

  const BrandIconBadge({super.key, this.size = 34});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.28),
      child: Image.asset(
        'assets/branding/app_icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
