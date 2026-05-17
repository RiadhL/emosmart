import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Brand colours ─────────────────────────────────────────────────────────
  static const Color brandPurple      = Color(0xFF5B4FCF);
  static const Color brandPurpleLight = Color(0xFF7C6FF7);
  static const Color brandLightPurple = Color(0xFFEAE9FF);
  static const Color coral            = Color(0xFFE8604C);
  static const Color coralLight       = Color(0xFFFDECEA);
  static const Color amber            = Color(0xFFE8A030);
  static const Color amberLight       = Color(0xFFFDF3E3);
  static const Color green            = Color(0xFF3DAB7B);
  static const Color greenLight       = Color(0xFFE4F5ED);
  static const Color pink             = Color(0xFFD4538A);
  static const Color pinkLight        = Color(0xFFFFE5F0);
  static const Color background       = Color(0xFFF8F7FF);
  static const Color textPrimary      = Color(0xFF1A1A2E);
  static const Color textSecondary    = Color(0xFF6B6B8A);
  static const Color border           = Color(0xFFEEEEEE);
  static const Color inputBg          = Color(0xFFF5F5FA);

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7C6FF7), Color(0xFF5B4FCF)],
  );
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA78BFA), Color(0xFF7C6FF7)],
  );
  static const LinearGradient coralGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B6B), Color(0xFFE8604C)],
  );
  static const LinearGradient amberGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB347), Color(0xFFE8A030)],
  );
  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF56CFB2), Color(0xFF3DAB7B)],
  );
  static const LinearGradient pinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B9D), Color(0xFFD4538A)],
  );

  // ── Legacy aliases ─────────────────────────────────────────────────────────
  static const Color primary         = brandPurple;
  static const Color secondary       = Color(0xFFE8A030);
  static const Color error           = coral;
  static const Color happyColor      = Color(0xFFFFD700);
  static const Color sadColor        = Color(0xFF64B5F6);
  static const Color angryColor      = coral;
  static const Color surprisedColor  = brandPurple;
  static const Color fearColor       = Color(0xFF78909C);

  // ── Radii ─────────────────────────────────────────────────────────────────
  static const double cardRadius   = 20.0;
  static const double buttonRadius = 18.0;

  // ── Card shadow ───────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF5B4FCF).withOpacity(0.12),
      blurRadius: 30,
      offset: const Offset(0, 10),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: const Color(0xFF5B4FCF).withOpacity(0.4),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // ── Theme ─────────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brandPurple,
        primary: brandPurple,
        surface: background,
        error: coral,
        brightness: Brightness.light,
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(const TextTheme(
        headlineLarge:  TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: textPrimary),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textPrimary),
        titleLarge:     TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
        titleMedium:    TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge:      TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: textSecondary),
        bodyMedium:     TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary),
        bodySmall:      TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: textSecondary),
      )),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandPurple,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          elevation: 0,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brandPurple,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: Color(0xFFA78BFA), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.85),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.8), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.8), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: brandPurple, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: coral),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: coral, width: 1.5),
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: textSecondary,
        ),
      ),
    );
  }

  static Color emotionColor(String id) {
    switch (id) {
      case 'happy':        return const Color(0xFFFFB300);
      case 'sad':          return const Color(0xFF5C9CE6);
      case 'angry':        return coral;
      case 'fear':         return const Color(0xFF78909C);
      case 'disgust':      return const Color(0xFF66BB6A);
      case 'surprised':    return brandPurple;
      case 'frustrated':   return coral;
      case 'worried':      return amber;
      case 'calm':         return green;
      case 'bored':        return const Color(0xFF9E9E9E);
      case 'tired':        return const Color(0xFF90A4AE);
      case 'confused':     return const Color(0xFFAB47BC);
      case 'guilty':       return const Color(0xFF8D6E63);
      case 'nervous':      return const Color(0xFFFF8F00);
      case 'suspicious':   return const Color(0xFF546E7A);
      case 'disappointed': return const Color(0xFF7986CB);
      case 'jealous':      return const Color(0xFF26A69A);
      case 'ashamed':      return pink;
      case 'lonely':       return const Color(0xFF5C9CE6);
      default:             return const Color(0xFF9E9E9E);
    }
  }
}
