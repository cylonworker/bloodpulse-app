import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Light Theme Colors
  static const Color _lightPrimary = Color(0xFF2196F3);
  static const Color _lightBackground = Color(0xFFF7F9FB);
  static const Color _lightSurface = Color(0xFFFFFFFF);

  // Dark Theme Colors
  static const Color _darkBackground = Color(0xFF1A1A2E);
  static const Color _darkSurface = Color(0xFF16213E);

  // OLED Theme Colors
  static const Color _oledBackground = Color(0xFF000000);
  static const Color _oledSurface = Color(0xFF121212);

  // Health Indicator Colors
  static const Color healthNormal = Color(0xFF4CAF50);
  static const Color healthElevated = Color(0xFFFFC107);
  static const Color healthHighNormal = Color(0xFFFF9800);
  static const Color healthHypertension1 = Color(0xFFFF5722);
  static const Color healthHypertension2 = Color(0xFFF44336);
  static const Color healthCrisis = Color(0xFFB71C1C);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: _lightPrimary,
      surface: _lightSurface,
    ),
    scaffoldBackgroundColor: _lightBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: _lightSurface,
      foregroundColor: Colors.black87,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: _lightSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _lightSurface,
      selectedItemColor: _lightPrimary,
      unselectedItemColor: Colors.grey,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: _lightPrimary,
      surface: _darkSurface,
    ),
    scaffoldBackgroundColor: _darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkSurface,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: _darkSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _darkSurface,
      selectedItemColor: _lightPrimary,
      unselectedItemColor: Colors.grey,
    ),
  );

  static ThemeData oledTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: _lightPrimary,
      surface: _oledSurface,
    ),
    scaffoldBackgroundColor: _oledBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: _oledBackground,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: _oledSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _oledSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _oledBackground,
      selectedItemColor: _lightPrimary,
      unselectedItemColor: Colors.grey,
    ),
  );

  static ThemeData getTheme(String themeMode) {
    switch (themeMode) {
      case 'dark':
        return darkTheme;
      case 'oled':
        return oledTheme;
      case 'light':
      default:
        return lightTheme;
    }
  }
}