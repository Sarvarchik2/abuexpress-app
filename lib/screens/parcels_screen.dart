import 'package:flutter/material.dart';
import 'add_parcel_screen.dart';
import 'settings_screen.dart';
import '../models/parcel.dart';
import '../widgets/bottom_navigation_bar.dart';

class ParcelsScreen extends StatefulWidget {
  final int currentIndex;
  final Function(int) onNavTap;
  
  const ParcelsScreen({
    super.key,
    required this.currentIndex,
    required this.onNavTap,
  });

  @override
  State<ParcelsScreen> createState() => _ParcelsScreenState();
}

class _ParcelsScreenState extends State<ParcelsScreen> {
  String _selectedFilter = 'Все';
  List<Parcel> _parcels = [];

  final List<String> _filters = ['Все', 'На складе', 'В пути', 'В таможне', 'Доставлен'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header with user profile
                _buildHeader(),
                const SizedBox(height: 20),
                // Filter buttons
                _buildFilters(),
                const SizedBox(height: 24),
                // My Parcels section
                _buildMyParcelsHeader(),
                const SizedBox(height: 16),
                // Empty state or parcel list
                Expanded(
                  child: _parcels.isEmpty
                      ? _buildEmptyState()
                      : _buildParcelsList(),
                ),
                // Spacer для навигации
                const SizedBox(height: 80),
              ],
            ),
          ),
          // Навигация прикреплена к низу
          CustomBottomNavigationBar(
            currentIndex: widget.currentIndex,
            onTap: widget.onNavTap,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'АЖ',
                    style: TextStyle(
                      color: Color(0xFF0A0E27),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF0A0E27),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // User info
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Журабаев Асадбек',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'ID: 12345678',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Notification icon
          Stack(
            children: [
              const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 28,
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '2',
                      style: TextStyle(
                        color: Color(0xFF0A0E27),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Settings icon
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            child: const Icon(
              Icons.settings_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFFD700)
                    : const Color(0xFF1A1F3A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF0A0E27)
                        : Colors.white,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMyParcelsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Мои посылки',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddParcelScreen(),
                ),
              );
              if (result != null && result is Parcel) {
                setState(() {
                  _parcels.add(result);
                });
              }
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add,
                color: Color(0xFF0A0E27),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 100),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F3A),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_outlined,
              color: Colors.white54,
              size: 60,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'У вас пока нет посылок',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Добавьте первую посылку, чтобы начать отслеживать её статус',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddParcelScreen(),
                ),
              );
              if (result != null && result is Parcel) {
                setState(() {
                  _parcels.add(result);
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Добавить посылку',
              style: TextStyle(
                color: Color(0xFF0A0E27),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildParcelsList() {
    final filteredParcels = _selectedFilter == 'Все'
        ? _parcels
        : _parcels.where((p) => p.status == _selectedFilter).toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: filteredParcels.length,
      itemBuilder: (context, index) {
        final parcel = filteredParcels[index];
        return _buildParcelCard(parcel);
      },
    );
  }

  Widget _buildParcelCard(Parcel parcel) {
    Color statusColor;
    Color statusTextColor;
    
    switch (parcel.status) {
      case 'На складе':
        statusColor = const Color(0xFF3B82F6); // Синий
        statusTextColor = Colors.white;
        break;
      case 'В пути':
        statusColor = const Color(0xFFFFD700); // Желтый
        statusTextColor = const Color(0xFF0A0E27);
        break;
      case 'Доставлен':
        statusColor = const Color(0xFF374151); // Темно-серый
        statusTextColor = Colors.white;
        break;
      default:
        statusColor = const Color(0xFF1A1F3A);
        statusTextColor = Colors.white;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Icon - квадратная иконка с темно-желтым фоном и желтым контуром коробки
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFB8860B).withOpacity(0.3), // Темно-желтый фон
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inbox_outlined,
              color: Color(0xFFFFD700), // Желтый контур
              size: 28,
              weight: 1.5,
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parcel.productName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${parcel.trackNumber}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      parcel.formattedDate,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      parcel.formattedWeight,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              parcel.status,
              style: TextStyle(
                color: statusTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


