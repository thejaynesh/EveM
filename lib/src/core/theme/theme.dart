import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Define new primary seed color - a vibrant and energetic blue
  static const Color primarySeedColor = Color(0xFF1E88E5); // Deep Sky Blue

  static final TextTheme _appTextTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(
      fontSize: 57,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
    bodyMedium: GoogleFonts.openSans(fontSize: 14, color: Colors.black87),
    labelLarge: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
  );

  static ThemeData get lightTheme {
    final ColorScheme lightColorScheme = ColorScheme.fromSeed(
      seedColor: primarySeedColor,
      brightness: Brightness.light,
      primary: primarySeedColor,
      onPrimary: Colors.white,
      secondary: const Color(0xFF6200EE), // A contrasting purple
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black87,
      // background and onBackground are derived from surface and onSurface in M3
      error: Colors.redAccent,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      textTheme: _appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: lightColorScheme.primary,
        foregroundColor: lightColorScheme.onPrimary,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: lightColorScheme.onPrimary,
        ),
        elevation: 4,
        shadowColor: lightColorScheme.shadow,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: lightColorScheme.onPrimary,
          backgroundColor: lightColorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          textStyle: _appTextTheme.labelLarge,
          elevation: 6,
          // shadowColor with opacity is acceptable for specific button glow effects
          shadowColor: lightColorScheme.primary.withAlpha(
            (255 * 0.4).round(),
          ), // Fix: replaced withOpacity
        ),
      ),
      cardTheme: const CardThemeData(
        // FIX: Changed to CardThemeData and made it const
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        // shadowColor is now derived from elevation and surface tint in M3, so direct assignment is removed.
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightColorScheme.primary, width: 2),
        ),
        labelStyle: GoogleFonts.openSans(color: Colors.grey[700]),
        hintStyle: GoogleFonts.openSans(color: Colors.grey[500]),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lightColorScheme.secondary,
        foregroundColor: lightColorScheme.onSecondary,
        elevation: 8,
      ),
      scaffoldBackgroundColor:
          lightColorScheme.surface, // Use surface for consistency
    );
  }

  static ThemeData get darkTheme {
    final ColorScheme darkColorScheme = ColorScheme.fromSeed(
      seedColor: primarySeedColor,
      brightness: Brightness.dark,
      primary: const Color(0xFF64B5F6), // Lighter blue for dark mode primary
      onPrimary: Colors.black,
      secondary: const Color(0xFFBB86FC), // A contrasting light purple
      onSecondary: Colors.black,
      surface: const Color(0xFF1E1E1E), // Dark surface
      onSurface: Colors.white70,
      // background and onBackground are derived from surface and onSurface in M3
      error: Colors.red[300],
      onError: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      textTheme: _appTextTheme.apply(
        bodyColor: Colors.white70,
        displayColor: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkColorScheme.surface,
        foregroundColor: darkColorScheme.onSurface,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: darkColorScheme.onSurface,
        ),
        elevation: 4,
        shadowColor: darkColorScheme.shadow,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: darkColorScheme.onPrimary,
          backgroundColor: darkColorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          textStyle: _appTextTheme.labelLarge?.copyWith(
            color: darkColorScheme.onPrimary,
          ),
          elevation: 6,
          shadowColor: darkColorScheme.primary.withAlpha(
            (255 * 0.4).round(),
          ), // Fix: replaced withOpacity
        ),
      ),
      cardTheme: const CardThemeData(
        // FIX: Changed to CardThemeData and made it const
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        // shadowColor is now derived from elevation and surface tint in M3, so direct assignment is removed.
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkColorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkColorScheme.primary, width: 2),
        ),
        labelStyle: GoogleFonts.openSans(color: Colors.white70),
        hintStyle: GoogleFonts.openSans(color: Colors.white54),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkColorScheme.secondary,
        foregroundColor: darkColorScheme.onSecondary,
        elevation: 8,
      ),
      scaffoldBackgroundColor:
          darkColorScheme.surface, // Use surface for consistency
    );
  }
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }

  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}
