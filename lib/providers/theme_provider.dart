import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/storage/secure_storage_service.dart';

enum AppThemeMode { light, dark, system }

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  ThemeNotifier() : super(AppThemeMode.system) {
    loadThemePreference();
  }

  final SecureStorageService _storageService = SecureStorageService();

  Future<void> loadThemePreference() async {
    try {
      final themeString = await _storageService.getThemePreference();
      if (themeString != null) {
        switch (themeString) {
          case 'light':
            state = AppThemeMode.light;
            break;
          case 'dark':
            state = AppThemeMode.dark;
            break;
          case 'system':
            state = AppThemeMode.system;
            break;
        }
      }
    } catch (e) {
      // If loading fails, keep default system theme
    }
  }

  Future<void> setTheme(AppThemeMode themeMode) async {
    try {
      state = themeMode;
      await _storageService.setThemePreference(themeMode.name);
    } catch (e) {
      // Handle error silently or show error message
    }
  }

  Future<void> toggleTheme() async {
    switch (state) {
      case AppThemeMode.light:
        await setTheme(AppThemeMode.dark);
        break;
      case AppThemeMode.dark:
        await setTheme(AppThemeMode.light);
        break;
      case AppThemeMode.system:
        await setTheme(AppThemeMode.light);
        break;
    }
  }
}

// Provider for getting the actual theme mode based on system settings
final actualThemeModeProvider = Provider<ThemeMode>((ref) {
  final themeMode = ref.watch(themeProvider);
  
  switch (themeMode) {
    case AppThemeMode.light:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
    case AppThemeMode.system:
      return ThemeMode.system;
  }
});

// Provider for checking if dark mode is active
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeProvider);
  
  switch (themeMode) {
    case AppThemeMode.light:
      return false;
    case AppThemeMode.dark:
      return true;
    case AppThemeMode.system:
      // This would need to be updated based on system theme
      // For now, we'll return false as default
      return false;
  }
});

// Provider for theme-dependent colors
final themeColorsProvider = Provider<Map<String, Color>>((ref) {
  final isDarkMode = ref.watch(isDarkModeProvider);
  
  if (isDarkMode) {
    return {
      'background': Colors.black,
      'surface': const Color(0xFF1F2937),
      'primary': const Color(0xFFFFC107),
      'onPrimary': Colors.black,
      'secondary': const Color(0xFF9CA3AF),
      'onSecondary': Colors.white,
      'error': Colors.red,
      'onError': Colors.white,
      'text': Colors.white,
      'textSecondary': const Color(0xFF9CA3AF),
    };
  } else {
    return {
      'background': Colors.white,
      'surface': const Color(0xFFF3F4F6),
      'primary': const Color(0xFFFFC107),
      'onPrimary': Colors.black,
      'secondary': const Color(0xFF6B7280),
      'onSecondary': Colors.white,
      'error': Colors.red,
      'onError': Colors.white,
      'text': Colors.black,
      'textSecondary': const Color(0xFF374151),
    };
  }
});