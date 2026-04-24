import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// AntiGravity Design System Colors
class AntiGravityColors {
  static const Color darkBg = Color(0xFF080808);
  static const Color surface = Color(0xFF111111);
  static const Color border = Color(0xFF2A2A2A);
  static const Color goldPrimary = Color(0xFFD4A017);
  static const Color goldAccent = Color(0xFFF5C518);
  static const Color gold1 = Color(0xFF1a1000);
  static const Color gold2 = Color(0xFF2a1f00);
  static const Color liveGreen = Color(0xFF00FF41);
  static const Color textLight = Color(0xFFEEEEEE);
  static const Color textMuted = Color(0xFF999999);
}

// AntiGravity Theme Configuration
ThemeData antiGravityTheme() {
  return ThemeData(
    // Dark Mode
    brightness: Brightness.dark,
    useMaterial3: true,

    // Background Colors
    scaffoldBackgroundColor: AntiGravityColors.darkBg,

    // Color Scheme
    colorScheme: ColorScheme.dark(
      primary: AntiGravityColors.goldAccent,
      secondary: AntiGravityColors.goldPrimary,
      surface: AntiGravityColors.surface,
      inverseSurface: AntiGravityColors.darkBg,
      onPrimary: AntiGravityColors.darkBg,
      onSecondary: AntiGravityColors.darkBg,
      onSurface: AntiGravityColors.textLight,
      outline: AntiGravityColors.border,
    ),

    // Text Themes
    textTheme: TextTheme(
      displayLarge: GoogleFonts.syne(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AntiGravityColors.textLight,
      ),
      displayMedium: GoogleFonts.syne(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AntiGravityColors.textLight,
      ),
      headlineSmall: GoogleFonts.syne(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AntiGravityColors.textLight,
      ),
      titleLarge: GoogleFonts.syne(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AntiGravityColors.textLight,
      ),
      titleMedium: GoogleFonts.syne(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AntiGravityColors.textLight,
      ),
      bodyLarge: GoogleFonts.jetBrainsMono(
        fontSize: 16,
        color: AntiGravityColors.textLight,
      ),
      bodyMedium: GoogleFonts.jetBrainsMono(
        fontSize: 14,
        color: AntiGravityColors.textLight,
      ),
      labelLarge: GoogleFonts.syne(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AntiGravityColors.textLight,
      ),
      labelMedium: GoogleFonts.syne(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AntiGravityColors.textMuted,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: AntiGravityColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(
          color: AntiGravityColors.border,
          width: 1,
        ),
      ),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AntiGravityColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AntiGravityColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AntiGravityColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AntiGravityColors.goldAccent, width: 2),
      ),
      labelStyle: GoogleFonts.syne(
        color: AntiGravityColors.textMuted,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: GoogleFonts.jetBrainsMono(
        color: AntiGravityColors.textMuted,
      ),
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AntiGravityColors.goldAccent,
        foregroundColor: AntiGravityColors.darkBg,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
        textStyle: GoogleFonts.syne(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AntiGravityColors.goldAccent,
        side: const BorderSide(color: AntiGravityColors.goldAccent),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.syne(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: AntiGravityColors.goldAccent,
      size: 24,
    ),

    // App Bar
    appBarTheme: AppBarTheme(
      backgroundColor: AntiGravityColors.surface,
      foregroundColor: AntiGravityColors.textLight,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.syne(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AntiGravityColors.textLight,
      ),
    ),

    // Bottom Navigation
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AntiGravityColors.surface,
      selectedItemColor: AntiGravityColors.goldAccent,
      unselectedItemColor: AntiGravityColors.textMuted,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: AntiGravityColors.border,
      thickness: 1,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AntiGravityColors.surface,
      selectedColor: AntiGravityColors.goldAccent,
      labelStyle: GoogleFonts.syne(
        color: AntiGravityColors.textLight,
        fontWeight: FontWeight.w600,
      ),
      secondaryLabelStyle: GoogleFonts.syne(
        color: AntiGravityColors.darkBg,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: AntiGravityColors.border),
      ),
    ),

    // Dropdown
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AntiGravityColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AntiGravityColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AntiGravityColors.border),
        ),
      ),
    ),
  );
}
