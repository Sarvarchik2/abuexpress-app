import 'package:flutter/material.dart';
import '../utils/theme.dart' show AppTheme;

class CustomSnackBar {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  static void show({
    required BuildContext context,
    required String message,
    String? title,
    IconData? icon,
    Color? backgroundColor,
    Color? iconColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    if (_isShowing) {
      hide();
    }

    _isShowing = true;
    final overlay = Overlay.of(context);
    
    _overlayEntry = OverlayEntry(
      builder: (context) => _AnimatedSnackBar(
        message: message,
        title: title,
        icon: icon,
        backgroundColor: backgroundColor,
        iconColor: iconColor,
        onDismiss: () => hide(),
      ),
    );

    overlay.insert(_overlayEntry!);

    Future.delayed(duration, () {
      hide();
    });
  }

  static void hide() {
    if (_overlayEntry != null && _isShowing) {
      _isShowing = false;
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  static void success({
    required BuildContext context,
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      title: title,
      icon: Icons.check_circle_rounded,
      iconColor: const Color(0xFF10B981), // Зеленый цвет для успеха
      backgroundColor: const Color(0xFF1E293B), // Темно-синий фон
      duration: duration,
    );
  }

  static void error({
    required BuildContext context,
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context: context,
      message: message,
      title: title,
      icon: Icons.error_rounded,
      iconColor: const Color(0xFFEF4444), // Красный цвет для ошибки
      backgroundColor: const Color(0xFF1E293B), // Темно-синий фон
      duration: duration,
    );
  }

  static void info({
    required BuildContext context,
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      title: title,
      icon: Icons.info_rounded,
      iconColor: AppTheme.gold,
      backgroundColor: const Color(0xFF1E293B), // Темно-синий фон
      duration: duration,
    );
  }

  static void warning({
    required BuildContext context,
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      title: title,
      icon: Icons.warning_rounded,
      iconColor: const Color(0xFFF59E0B), // Оранжевый цвет для предупреждения
      backgroundColor: const Color(0xFF1E293B), // Темно-синий фон
      duration: duration,
    );
  }
}

class _AnimatedSnackBar extends StatefulWidget {
  final String message;
  final String? title;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final VoidCallback onDismiss;

  const _AnimatedSnackBar({
    required this.message,
    this.title,
    this.icon,
    this.backgroundColor,
    this.iconColor,
    required this.onDismiss,
  });

  @override
  State<_AnimatedSnackBar> createState() => _AnimatedSnackBarState();
}

class _AnimatedSnackBarState extends State<_AnimatedSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.backgroundColor ?? const Color(0xFF1E293B);
    final iconColor = widget.iconColor ?? AppTheme.gold;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _dismiss,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (widget.icon != null) ...[
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.icon,
                          color: iconColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Color(0xFFE2E8F0),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _dismiss,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFF94A3B8),
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

