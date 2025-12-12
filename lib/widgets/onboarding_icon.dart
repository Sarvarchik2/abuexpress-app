import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/onboarding_item.dart';

class OnboardingIcon extends StatelessWidget {
  final OnboardingIconType iconType;

  const OnboardingIcon({
    super.key,
    required this.iconType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: _buildIcon(),
      ),
    );
  }

  Widget _buildIcon() {
    String assetPath;
    double iconSize;
    
    switch (iconType) {
      case OnboardingIconType.airplane:
        assetPath = 'lib/assets/intro/logo.svg';
        iconSize = 190; // Логотип почти на весь круг (200px)
        break;
      case OnboardingIconType.box:
        assetPath = 'lib/assets/intro/box.svg';
        iconSize = 120;
        break;
      case OnboardingIconType.shoppingBag:
        assetPath = 'lib/assets/intro/drop.svg';
        iconSize = 120;
        break;
      case OnboardingIconType.globe:
        assetPath = 'lib/assets/intro/world.svg';
        iconSize = 120;
        break;
    }

    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: SvgPicture.asset(
        assetPath,
        fit: iconType == OnboardingIconType.airplane 
            ? BoxFit.contain // Для логотипа contain, чтобы не обрезать
            : BoxFit.contain,
        alignment: Alignment.center,
        colorFilter: const ColorFilter.mode(
          Color(0xFF0A0E27),
          BlendMode.srcIn,
        ),
      ),
    );
  }
}


