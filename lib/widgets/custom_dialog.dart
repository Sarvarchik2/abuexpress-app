import 'package:flutter/material.dart';
import '../utils/theme_helper.dart';
import '../utils/theme.dart' show AppTheme;

class CustomDialog extends StatelessWidget {
  final String? title;
  final String? message;
  final Widget? content;
  final List<Widget>? actions;
  final IconData? icon;
  final Color? iconColor;
  final bool showCloseButton;

  const CustomDialog({
    super.key,
    this.title,
    this.message,
    this.content,
    this.actions,
    this.icon,
    this.iconColor,
    this.showCloseButton = true,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? message,
    Widget? content,
    List<Widget>? actions,
    IconData? icon,
    Color? iconColor,
    bool showCloseButton = true,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // Анимация появления сверху
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.5),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: CustomDialog(
              title: title,
              message: message,
              content: content,
              actions: actions,
              icon: icon,
              iconColor: iconColor,
              showCloseButton: showCloseButton,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final textSecondaryColor = ThemeHelper.getTextSecondaryColor(context);
    final cardColor = ThemeHelper.getCardColor(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with icon and close button
            Stack(
              children: [
                if (icon != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: (iconColor ?? AppTheme.gold).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          color: iconColor ?? AppTheme.gold,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                if (showCloseButton)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: textSecondaryColor,
                        size: 24,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: backgroundColor.withOpacity(0.5),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ),
              ],
            ),
            // Title
            if (title != null) ...[
              Padding(
                padding: EdgeInsets.only(
                  top: icon != null ? 16 : 24,
                  left: 24,
                  right: 24,
                ),
                child: Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            // Message or Content
            if (message != null || content != null) ...[
              Padding(
                padding: EdgeInsets.only(
                  top: title != null ? 12 : (icon != null ? 16 : 24),
                  left: 24,
                  right: 24,
                ),
                child: content ??
                    Text(
                      message!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textSecondaryColor,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
              ),
            ],
            // Actions
            if (actions != null && actions!.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: actions!.length == 1
                      ? [Expanded(child: actions!.first)]
                      : actions!
                          .map((action) => Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: action != actions!.last
                                        ? 8
                                        : 0,
                                  ),
                                  child: action,
                                ),
                              ))
                          .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Удобные методы для создания диалогов
class CustomDialogActions {
  static Widget primaryButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppTheme.gold,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: ThemeHelper.isDark(context)
                ? const Color(0xFF0A0E27)
                : const Color(0xFF212121),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static Widget secondaryButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
  }) {
    final textColor = ThemeHelper.getTextColor(context);
    final cardColor = ThemeHelper.getCardColor(context);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: cardColor,
          side: BorderSide(
            color: textColor.withOpacity(0.2),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

