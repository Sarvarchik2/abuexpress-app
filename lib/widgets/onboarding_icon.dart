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
    bool isPng = false;
    
    switch (iconType) {
      case OnboardingIconType.airplane:
        assetPath = 'lib/assets/icon/12abu-logo.png';
        iconSize = 200; // Логотип почти на весь круг (200px)
        isPng = true;
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
      child: isPng
          ? Image.asset(
              assetPath,
              fit: BoxFit.contain,
              alignment: Alignment.center,
            )
          : SvgPicture.asset(
              assetPath,
              fit: BoxFit.contain,
              alignment: Alignment.center,
              colorFilter: const ColorFilter.mode(
                Color(0xFF0A0E27),
                BlendMode.srcIn,
              ),
            ),
    );
  }
}


