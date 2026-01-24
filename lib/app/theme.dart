import 'package:flutter/material.dart';

class AppTheme {
  // Màu sắc chính của ứng dụng
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color primaryVariant = Color(0xFF388E3C);
  static const Color secondaryColor = Color(0xFF2196F3);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);

  // Typography
  static const String fontFamily = 'Roboto';
  static const double headingFontSize = 24.0;
  static const double bodyFontSize = 16.0;
  static const double captionFontSize = 12.0;

  // Spacing và Border Radius
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double borderRadius = 8.0;
  static const double cardElevation = 4.0;

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Color Scheme
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      error: errorColor,
      onError: Colors.white,
      surface: surfaceColor,
      onSurface: textPrimaryColor,
    ),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    // Text Theme
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: headingFontSize,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
      ),
      bodyLarge: TextStyle(
        fontSize: bodyFontSize,
        fontWeight: FontWeight.normal,
        color: textPrimaryColor,
      ),
      bodyMedium: TextStyle(
        fontSize: bodyFontSize - 2,
        fontWeight: FontWeight.normal,
        color: textSecondaryColor,
      ),
      labelSmall: TextStyle(
        fontSize: captionFontSize,
        fontWeight: FontWeight.normal,
        color: textSecondaryColor,
      ),
    ),

    // Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingSmall,
        ),
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      margin: const EdgeInsets.all(spacingSmall),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: errorColor),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.all(spacingMedium),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(color: primaryColor, size: 24),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondaryColor,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      error: errorColor,
      onError: Colors.white,
      surface: Color(0xFF121212),
      onSurface: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),

    // Text Theme cho Dark Theme
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: headingFontSize,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: bodyFontSize,
        fontWeight: FontWeight.normal,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontSize: bodyFontSize - 2,
        fontWeight: FontWeight.normal,
        color: Colors.white70,
      ),
      labelSmall: TextStyle(
        fontSize: captionFontSize,
        fontWeight: FontWeight.normal,
        color: Colors.white70,
      ),
    ),

    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    ),
  );

  // Phương thức tiện ích để lấy màu sắc theo context
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : textPrimaryColor;
  }

  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E1E1E)
        : surfaceColor;
  }
}
