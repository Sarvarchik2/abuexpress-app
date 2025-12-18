import 'package:flutter/material.dart';
import 'parcels_screen.dart';
import 'shop_screen.dart';
import 'favorites_screen.dart';
import 'addresses_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (mounted && index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    }
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
                ShopScreen(
                  key: const ValueKey('shop'),
                  currentIndex: _currentIndex,
                  onNavTap: _onTabTapped,
                ),
                FavoritesScreen(
                  key: const ValueKey('favorites'),
                  currentIndex: _currentIndex,
                  onNavTap: _onTabTapped,
                ),
                AddressesScreen(
                  key: const ValueKey('addresses'),
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

