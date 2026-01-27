import 'package:flutter/material.dart';

class AppTheme {
  // ========================================
  // COLOR PALETTE
  // ========================================

  // Primary Colors
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryGreenDark = Color(0xFF388E3C);
  static const Color primaryGreenLight = Color(0xFF81C784);

  // Secondary Colors
  static const Color secondaryBlue = Color(0xFF2196F3);
  static const Color secondaryBlueDark = Color(0xFF1976D2);

  // Error Colors
  static const Color errorRed = Color(0xFFE53E3E);
  static const Color errorRedDark = Color(0xFFC53030);

  // ========================================
  // BACKWARD COMPATIBILITY CONSTANTS
  // ========================================

  // Static colors for backward compatibility
  static const Color primaryColor = primaryGreen;
  static const Color secondaryColor = secondaryBlue;
  static const Color errorColor = errorRed;
  static const Color surfaceColor = Colors.white;
  static const Color textSecondaryColor = Color(0xFF757575);

  // ========================================
  // THEME-AWARE COLOR HELPERS
  // ========================================

  // Get theme-aware colors
  static ColorScheme getColorScheme(BuildContext context) {
    return Theme.of(context).colorScheme;
  }

  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color getSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  static Color getErrorColor(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }

  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color getOnSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color getTextSecondaryColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.light
        ? const Color(0xFF757575)
        : const Color(0xFF938F99);
  }

  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  static Color getOnBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  // ========================================
  // TYPOGRAPHY CONSTANTS
  // ========================================
  static const String fontFamily = 'Roboto';
  static const double headingFontSize = 24.0;
  static const double bodyFontSize = 16.0;
  static const double captionFontSize = 12.0;

  // ========================================
  // SPACING & DIMENSIONS
  // ========================================
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double borderRadius = 8.0;
  static const double cardElevation = 2.0;

  // ========================================
  // LIGHT THEME
  // ========================================
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: fontFamily,

    // Color Scheme - Material 3 compliant
    colorScheme: const ColorScheme.light(
      // Primary colors
      primary: primaryGreen,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFC8E6C9), // Light green container
      onPrimaryContainer: Color(0xFF1B5E20), // Dark green text
      // Secondary colors
      secondary: secondaryBlue,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFBBDEFB), // Light blue container
      onSecondaryContainer: Color(0xFF0D47A1), // Dark blue text
      // Surface colors (for cards, sheets, etc.)
      surface: Color(0xFFFFFFFF), // Pure white surface
      onSurface: Color(0xFF1C1B1F), // Almost black text on surface
      surfaceContainerHighest: Color(0xFFE7E0EC), // Elevated surfaces
      // Error colors
      error: errorRed,
      onError: Colors.white,
      errorContainer: Color(0xFFFEE2E2),
      onErrorContainer: Color(0xFF7F1D1D),

      // Outline colors
      outline: Color(0xFF79747E),
      outlineVariant: Color(0xFFCAC4D0),

      // Other
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF313033),
      onInverseSurface: Color(0xFFF4EFF4),
      inversePrimary: Color(0xFF81C784),
    ),

    // Scaffold background
    scaffoldBackgroundColor: const Color(0xFFFFFBFE),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        fontFamily: fontFamily,
      ),
    ),

    // Text Theme - Let Flutter handle colors based on context
    textTheme: const TextTheme(
      // Display styles (largest)
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
      ),
      displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
      displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),

      // Headline styles
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(
        fontSize: headingFontSize,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),

      // Title styles
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),

      // Body styles (most common)
      bodyLarge: TextStyle(
        fontSize: bodyFontSize,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        fontSize: captionFontSize,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),

      // Label styles (for buttons, etc.)
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        fontSize: captionFontSize,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: cardElevation,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      margin: const EdgeInsets.all(spacingSmall),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: cardElevation,
        shadowColor: Colors.black.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingSmall + 4,
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryGreen,
        side: const BorderSide(color: primaryGreen, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingSmall + 4,
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingSmall + 4,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      contentPadding: const EdgeInsets.all(spacingMedium),

      // Border styles
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: errorRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: errorRed, width: 2),
      ),

      // Label and hint styles
      labelStyle: const TextStyle(color: Color(0xFF757575), fontSize: 14),
      hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(color: primaryGreen, size: 24),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryGreen,
      unselectedItemColor: Color(0xFF757575),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE0E0E0),
      thickness: 1,
      space: 1,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFE0E0E0),
      deleteIconColor: const Color(0xFF757575),
      disabledColor: const Color(0xFFE0E0E0).withOpacity(0.5),
      selectedColor: primaryGreen.withOpacity(0.2),
      secondarySelectedColor: secondaryBlue.withOpacity(0.2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      labelStyle: const TextStyle(color: Color(0xFF212121), fontSize: 14),
      secondaryLabelStyle: const TextStyle(
        color: Color(0xFF212121),
        fontSize: 14,
      ),
      brightness: Brightness.light,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
  );

  // ========================================
  // DARK THEME
  // ========================================
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: fontFamily,

    // Color Scheme - Material 3 compliant
    colorScheme: const ColorScheme.dark(
      // Primary colors - LIGHTER for dark mode
      primary: Color(0xFF81C784), // Light green for dark mode
      onPrimary: Color(0xFF1B5E20), // Dark green text
      primaryContainer: Color(0xFF2E7D32), // Medium green container
      onPrimaryContainer: Color(0xFFC8E6C9), // Light green text
      // Secondary colors
      secondary: Color(0xFF64B5F6), // Lighter blue for dark mode
      onSecondary: Color(0xFF0D47A1), // Dark blue text
      secondaryContainer: Color(0xFF1976D2), // Medium blue container
      onSecondaryContainer: Color(0xFFBBDEFB), // Light blue text
      // Surface colors
      surface: Color(0xFF1C1B1F), // Dark surface
      onSurface: Color(0xFFE6E1E5), // Light text on surface
      surfaceContainerHighest: Color(0xFF36343B), // Elevated surface
      // Error colors
      error: Color(0xFFF2B8B5), // Light red for dark mode
      onError: Color(0xFF601410), // Dark red text
      errorContainer: Color(0xFF8C1D18),
      onErrorContainer: Color(0xFFF2B8B5),

      // Outline colors
      outline: Color(0xFF938F99),
      outlineVariant: Color(0xFF49454F),

      // Other
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFE6E1E5),
      onInverseSurface: Color(0xFF313033),
      inversePrimary: primaryGreen,
    ),

    // Scaffold background
    scaffoldBackgroundColor: const Color(0xFF1C1B1F),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2E2D32),
      foregroundColor: Color(0xFFE6E1E5),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFFE6E1E5)),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE6E1E5),
        fontFamily: fontFamily,
      ),
    ),

    // Text Theme - Same structure as light theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
      ),
      displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
      displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(
        fontSize: headingFontSize,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      bodyLarge: TextStyle(
        fontSize: bodyFontSize,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        fontSize: captionFontSize,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        fontSize: captionFontSize,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: const Color(0xFF2E2D32),
      elevation: cardElevation,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      margin: const EdgeInsets.all(spacingSmall),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF81C784),
        foregroundColor: const Color(0xFF1B5E20),
        elevation: cardElevation,
        shadowColor: Colors.black.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingSmall + 4,
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF81C784),
        side: const BorderSide(color: Color(0xFF81C784), width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingSmall + 4,
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF81C784),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingSmall + 4,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2E2D32),
      contentPadding: const EdgeInsets.all(spacingMedium),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: Color(0xFF49454F)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: Color(0xFF49454F)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: Color(0xFF81C784), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: Color(0xFFF2B8B5)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: Color(0xFFF2B8B5), width: 2),
      ),

      labelStyle: const TextStyle(color: Color(0xFF938F99), fontSize: 14),
      hintStyle: const TextStyle(color: Color(0xFF79747E), fontSize: 14),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(color: Color(0xFF81C784), size: 24),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF2E2D32),
      selectedItemColor: Color(0xFF81C784),
      unselectedItemColor: Color(0xFF938F99),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: Color(0xFF49454F),
      thickness: 1,
      space: 1,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF49454F),
      deleteIconColor: const Color(0xFF938F99),
      disabledColor: const Color(0xFF49454F).withOpacity(0.5),
      selectedColor: const Color(0xFF81C784).withOpacity(0.2),
      secondarySelectedColor: const Color(0xFF64B5F6).withOpacity(0.2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      labelStyle: const TextStyle(color: Color(0xFFE6E1E5), fontSize: 14),
      secondaryLabelStyle: const TextStyle(
        color: Color(0xFFE6E1E5),
        fontSize: 14,
      ),
      brightness: Brightness.dark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
  );
}
