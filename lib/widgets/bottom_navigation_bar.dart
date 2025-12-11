import 'dart:ui';
import 'package:flutter/material.dart';

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
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
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
                        _buildNavItem(Icons.inbox_outlined, 'Посылки', 0),
                        const SizedBox(width: 12),
                        _buildNavItem(Icons.shopping_bag_outlined, 'Магазин', 1),
                        const SizedBox(width: 12),
                        _buildNavItem(Icons.favorite_outline, 'Избранное', 2),
                        const SizedBox(width: 12),
                        _buildNavItem(Icons.location_on_outlined, 'Адреса', 3),
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

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFB8860B).withOpacity(0.9)
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
                  : Colors.white,
              size: 20,
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFFFFD700)
                    : Colors.white,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: -0.2,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}