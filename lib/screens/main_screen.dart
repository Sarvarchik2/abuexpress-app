import 'package:flutter/material.dart';
import 'parcels_screen.dart';
import 'shop_bottom_sheet.dart';
import 'addresses_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (mounted) {
      // Открываем магазин как модальный bottom sheet при нажатии на "Магазин" (индекс 1)
      if (index == 1) {
        _showShopBottomSheet();
        return; // Не меняем индекс, остаемся на текущем экране
      }
      
      // Для остальных вкладок меняем индекс
      if (index != _currentIndex) {
        setState(() {
          _currentIndex = index;
        });
      }
    }
  }

  void _showShopBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => const ShopBottomSheet(),
    ).then((_) {
      // Обновляем состояние после закрытия bottom sheet
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          try {
            return IndexedStack(
              index: _currentIndex,
              children: [
                ParcelsScreen(
                  key: const ValueKey('parcels'),
                  currentIndex: _currentIndex,
                  onNavTap: _onTabTapped,
                ),
                // Магазин открывается как bottom sheet, но нужен экран для индекса
                ParcelsScreen(
                  key: const ValueKey('shop'),
                  currentIndex: _currentIndex,
                  onNavTap: _onTabTapped,
                ),
                AddressesScreen(
                  key: const ValueKey('addresses'),
                  currentIndex: _currentIndex,
                  onNavTap: _onTabTapped,
                ),
                SettingsScreen(
                  key: const ValueKey('settings'),
                  currentIndex: _currentIndex,
                  onNavTap: _onTabTapped,
                ),
              ],
            );
          } catch (e, stackTrace) {
            debugPrint('Error building MainScreen: $e');
            debugPrint('Stack trace: $stackTrace');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Ошибка загрузки: $e'),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

