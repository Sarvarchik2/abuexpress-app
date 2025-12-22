import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/theme_helper.dart';
import '../utils/localization_helper.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: ThemeHelper.isDark(context) 
                    ? Colors.black.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: ThemeHelper.isDark(context)
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
              child: SafeArea(
                top: false,
                bottom: false,
                child: SizedBox(
                  height: 65,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildNavItem(context, Icons.inbox_outlined, context.l10n.translate('parcels'), 0),
                        const SizedBox(width: 12),
                        _buildNavItem(context, Icons.shopping_bag_outlined, context.l10n.translate('shop'), 1),
                        const SizedBox(width: 12),
                        _buildNavItem(context, Icons.location_on_outlined, context.l10n.translate('addresses'), 2),
                        const SizedBox(width: 12),
                        _buildNavItem(context, Icons.settings_outlined, context.l10n.translate('settings'), 3),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    final textColor = ThemeHelper.getTextColor(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          debugPrint('Bottom nav item tapped: $index');
          onTap(index);
        },
        borderRadius: BorderRadius.circular(60),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFB8860B).withValues(alpha: 0.9)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(60),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFFFFD700)
                  : textColor,
              size: 20,
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFFFFD700)
                    : textColor,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: -0.2,
              ),
              child: Text(label),
            ),
          ],
        ),
        ),
      ),
    );
  }
}