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

  List<Widget> _buildScreens() {
    // Ленивая инициализация экранов - создаем их только при необходимости
    return [
      ParcelsScreen(
        key: const ValueKey('parcels'),
        currentIndex: _currentIndex,
        onNavTap: (index) => _onTabTapped(index),
      ),
      ShopScreen(
        key: const ValueKey('shop'),
        currentIndex: _currentIndex,
        onNavTap: (index) => _onTabTapped(index),
      ),
      FavoritesScreen(
        key: const ValueKey('favorites'),
        currentIndex: _currentIndex,
        onNavTap: (index) => _onTabTapped(index),
      ),
      AddressesScreen(
        key: const ValueKey('addresses'),
        currentIndex: _currentIndex,
        onNavTap: (index) => _onTabTapped(index),
      ),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _buildScreens(),
      ),
    );
  }
}

