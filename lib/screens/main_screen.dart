import 'package:flutter/material.dart';
import 'parcels_screen.dart';
import 'shop_screen.dart';
import 'favorites_screen.dart';
import 'addresses_screen.dart';
import '../widgets/bottom_navigation_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  List<Widget> _buildScreens() {
    return [
      ParcelsScreen(
        currentIndex: _currentIndex,
        onNavTap: (index) => _onTabTapped(index),
      ),
      ShopScreen(
        currentIndex: _currentIndex,
        onNavTap: (index) => _onTabTapped(index),
      ),
      FavoritesScreen(
        currentIndex: _currentIndex,
        onNavTap: (index) => _onTabTapped(index),
      ),
      AddressesScreen(
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

