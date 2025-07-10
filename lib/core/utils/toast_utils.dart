import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../theme/app_colors.dart';

class ToastUtils {
  static late FToast _fToast;
  
  static void init(BuildContext context) {
    _fToast = FToast();
    _fToast.init(context);
  }
  
  static void showSuccess(String message, {bool isDarkMode = false}) {
    _showCustomToast(
      message: message,
      backgroundColor: Colors.green.withOpacity(0.9),
      iconColor: Colors.white,
      textColor: Colors.white,
      icon: Icons.check_circle,
      isDarkMode: isDarkMode,
    );
  }
  
  static void showError(String message, {bool isDarkMode = false}) {
    _showCustomToast(
      message: message,
      backgroundColor: Colors.red.shade400.withOpacity(0.9),
      iconColor: Colors.white,
      textColor: Colors.white,
      icon: Icons.error,
      isDarkMode: isDarkMode,
    );
  }
  
  static void showInfo(String message, {bool isDarkMode = false}) {
    _showCustomToast(
      message: message,
      backgroundColor: AppColors.yellow.withOpacity(0.9),
      iconColor: Colors.white,
      textColor: Colors.white,
      icon: Icons.info,
      isDarkMode: isDarkMode,
    );
  }
  
  static void _showCustomToast({
    required String message,
    required Color backgroundColor,
    required Color iconColor,
    required Color textColor,
    required IconData icon,
    bool isDarkMode = false,
  }) {
    Widget toast = Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            // Glassmorphism effect
            color: isDarkMode 
                ? Colors.black.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    _fToast.showToast(
      child: toast,
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 3),
    );
  }
  
  static void cancel() {
    _fToast.removeCustomToast();
  }
}