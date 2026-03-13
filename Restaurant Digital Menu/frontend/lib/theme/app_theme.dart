import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Warm, Classic Brand Palette ─────────────────────────────────────────
  static const Color primary      = Color(0xFFC84B31); // warm terracotta/saffron
  static const Color primaryDark  = Color(0xFFA33626); // deep burnt sienna
  static const Color primaryLight = Color(0xFFE8705A); // light coral – hover state
  static const Color gold         = Color(0xFFC9961A); // antique gold
  static const Color goldLight    = Color(0xFFF5C842); // bright golden accent
  static const Color background   = Color(0xFFFDF8F2); // warm cream / ivory
  static const Color surface      = Color(0xFFFFFFFF); // pure white
  static const Color surfaceWarm  = Color(0xFFFFFBF7); // very light warm white
  static const Color surfaceCard  = Color(0xFFFFF9F5); // card background
  static const Color textPrimary  = Color(0xFF1C0A00); // espresso / warm near-black
  static const Color textSecondary = Color(0xFF7A6A5A); // warm mocha
  static const Color textHint     = Color(0xFFB5A595); // light hint text
  static const Color vegGreen     = Color(0xFF3D7A48); // forest green
  static const Color nonVegRed    = Color(0xFFC0392B); // deep red
  static const Color divider      = Color(0xFFEDE0D0); // warm beige border
  static const Color dividerLight = Color(0xFFF5EEE6); // lighter divider
  static const Color amber        = Color(0xFFE07B3A); // warm amber accent
  static const Color success      = Color(0xFF059669); // emerald green
  static const Color successLight = Color(0xFFDCFCE7); // very light green
  static const Color cardBg       = Color(0xFFFFFBF7); // very light warm white

  // ─── Shadow presets ───────────────────────────────────────────────────────
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: const Color(0xFF1C0A00).withAlpha(10),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: const Color(0xFF1C0A00).withAlpha(12),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF1C0A00).withAlpha(6),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: const Color(0xFF1C0A00).withAlpha(16),
      blurRadius: 30,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: const Color(0xFF1C0A00).withAlpha(8),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> primaryShadow({int alpha = 70}) => [
    BoxShadow(
      color: primary.withAlpha(alpha),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // ─── Gradient presets ─────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFDF8F2), Color(0xFFFFF0E6)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient imageOverlayGradient({
    double strength = 200,
    Alignment begin = Alignment.topCenter,
    Alignment end = Alignment.bottomCenter,
    double startStop = 0.35,
  }) =>
      LinearGradient(
        begin: begin,
        end: end,
        colors: [
          Colors.transparent,
          Colors.black.withAlpha(strength.toInt()),
        ],
        stops: [startStop, 1.0],
      );

  // ─── Typography helpers ───────────────────────────────────────────────────
  static TextStyle display(
          {double size = 32, FontWeight weight = FontWeight.w700}) =>
      GoogleFonts.playfairDisplay(
          fontSize: size, fontWeight: weight, color: textPrimary, height: 1.2);

  static TextStyle heading(
          {double size = 22, FontWeight weight = FontWeight.w700}) =>
      GoogleFonts.playfairDisplay(
          fontSize: size, fontWeight: weight, color: textPrimary, height: 1.3);

  static TextStyle label(
          {double size = 13,
          FontWeight weight = FontWeight.w600,
          Color? color}) =>
      GoogleFonts.outfit(
          fontSize: size,
          fontWeight: weight,
          color: color ?? textPrimary,
          letterSpacing: 0.2);

  static TextStyle body(
          {double size = 13,
          FontWeight weight = FontWeight.w400,
          Color? color}) =>
      GoogleFonts.outfit(
          fontSize: size,
          fontWeight: weight,
          color: color ?? textSecondary,
          height: 1.55);

  static ThemeData get light {
    final baseText = GoogleFonts.outfitTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: gold,
        surface: surface,
        onPrimary: Colors.white,
        surfaceContainerHighest: surfaceWarm,
      ),
      scaffoldBackgroundColor: background,

      // ─── AppBar ────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withAlpha(18),
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimary, size: 22),
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // ─── Bottom Navigation ─────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        indicatorColor: primary.withAlpha(20),
        surfaceTintColor: Colors.transparent,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 23);
          }
          return IconThemeData(color: textSecondary.withAlpha(150), size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.outfit(
                fontSize: 11, fontWeight: FontWeight.w700, color: primary);
          }
          return GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: textSecondary.withAlpha(150));
        }),
      ),

      // ─── Navigation Rail ───────────────────────────────────────────────
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        selectedIconTheme: const IconThemeData(color: primary, size: 22),
        unselectedIconTheme:
            IconThemeData(color: textSecondary.withAlpha(150), size: 22),
        indicatorColor: primary.withAlpha(20),
        selectedLabelTextStyle: GoogleFonts.outfit(
            fontSize: 11, fontWeight: FontWeight.w700, color: primary),
        unselectedLabelTextStyle: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textSecondary.withAlpha(150)),
      ),

      // ─── Card ─────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: dividerLight, width: 1),
        ),
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
      ),

      // ─── Elevated Button ───────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ),

      // ─── Chip Theme ────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: surfaceWarm,
        selectedColor: primary.withAlpha(20),
        side: const BorderSide(color: divider, width: 1),
        labelStyle: GoogleFonts.outfit(
            fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // ─── Divider ──────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 24,
      ),

      // ─── Text ─────────────────────────────────────────────────────────
      textTheme: baseText.copyWith(
        // Serif display — headings (Playfair Display)
        displayLarge: GoogleFonts.playfairDisplay(
            fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary),
        headlineMedium: GoogleFonts.playfairDisplay(
            fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary),
        headlineSmall: GoogleFonts.playfairDisplay(
            fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
        titleLarge: GoogleFonts.playfairDisplay(
            fontSize: 17, fontWeight: FontWeight.w600, color: textPrimary),
        // Sans body — content (Outfit)
        titleMedium: GoogleFonts.outfit(
            fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary),
        titleSmall: GoogleFonts.outfit(
            fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textSecondary,
            height: 1.6),
        bodyMedium: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: textSecondary,
            height: 1.55),
        bodySmall: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: textSecondary,
            height: 1.5),
        labelLarge: GoogleFonts.outfit(
            fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
        labelMedium: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondary,
            letterSpacing: 0.2),
        labelSmall: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textSecondary,
            letterSpacing: 0.3),
      ),

      // ─── Input ────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWarm,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.outfit(
            fontSize: 13, color: textSecondary.withAlpha(130)),
      ),

      // ─── SnackBar ─────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1C0A00),
        contentTextStyle: GoogleFonts.outfit(
            fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
