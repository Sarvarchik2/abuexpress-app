import 'dart:async';
import 'package:flutter/material.dart';
import '../models/api/departure_time.dart';
import '../utils/theme.dart';
import '../utils/theme_helper.dart'; // For AppTheme

class DepartureTimerCard extends StatefulWidget {
  final List<DepartureTime> departureTimes;
  final VoidCallback onSendTap;

  const DepartureTimerCard({
    super.key,
    required this.departureTimes,
    required this.onSendTap,
  });

  @override
  State<DepartureTimerCard> createState() => _DepartureTimerCardState();
}

class _DepartureTimerCardState extends State<DepartureTimerCard> {
  late Timer _timer;
  int _currentIndex = 0;
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Duration _getTimeLeft(DateTime departureTime) {
    final now = DateTime.now();
    if (now.isAfter(departureTime)) {
      return Duration.zero;
    }
    return departureTime.difference(now);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.departureTimes.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0C10), // Dark background like screenshot
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF2A2D35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background graphic lines (simplified)
          Positioned(
            right: -20,
            top: 20,
            child: Opacity(
              opacity: 0.1,
              child: Icon(
                Icons.share_outlined, // Placeholder for network lines
                size: 200,
                color: AppTheme.gold,
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Text(
                  "Posilkalarni jo'natish vaqti",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Tezroq yetkazib berish uchun buyurtma berishga ulguring",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),

                // Carousel for countries if multiple
                SizedBox(
                  height: 140,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.departureTimes.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final item = widget.departureTimes[index];
                      final timeLeft = _getTimeLeft(item.departureTime);
                      
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.country,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildTimeItem(timeLeft.inDays, "KUN"),
                              _buildDivider(),
                              _buildTimeItem(timeLeft.inHours % 24, "SOAT"),
                              _buildDivider(),
                              _buildTimeItem(timeLeft.inMinutes % 60, "DAQIQA"),
                              _buildDivider(),
                              _buildTimeItem(timeLeft.inSeconds % 60, "SONIYA"),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                
                // Indicators if multiple
                if (widget.departureTimes.length > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.departureTimes.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentIndex == index 
                              ? AppTheme.gold 
                              : Colors.white.withOpacity(0.2),
                        ),
                      );
                    }),
                  ),

                const SizedBox(height: 16),
                
                // Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: widget.onSendTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: const BorderSide(color: AppTheme.gold),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Posilkani jo'natish",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeItem(int value, String label) {
    return Column(
      children: [
        Text(
          value.toString().padLeft(2, '0'), 
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: AppTheme.gold,
    );
  }
}
