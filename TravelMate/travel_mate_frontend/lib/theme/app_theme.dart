import 'package:flutter/material.dart';

class TravelMateColors {
  static const tealDark = Color(0xFF00897B);
  static const teal = Color(0xFF00B89C);
  static const tealLight = Color(0xFF4DD0C4);
  static const tealPale = Color(0xFFB2DFDB);
  static const amber = Color(0xFFFFA726);
  static const amberLight = Color(0xFFFFCC02);
  static const gradStart = Color(0xFF00C9A7);
  static const gradEnd = Color(0xFF00796B);

  static const lBackground = Color(0xFFF0FAF8);
  static const lSurface = Color(0xFFFFFFFF);
  static const lCard = Color(0xFFFFFFFF);
  static const lBorder = Color(0xFFB2DFDB);
  static const lText = Color(0xFF1A3C38);
  static const lTextSub = Color(0xFF4A7B74);
  static const lDivider = Color(0xFFE0F2F1);

  static const dBackground = Color.fromARGB(255, 4, 12, 11);
  static const dSurface = Color.fromARGB(255, 9, 25, 23);
  static const dCard = Color(0xFF143530);
  static const dBorder = Color(0xFF1E4D47);
  static const dText = Color(0xFFE8F5F3);
  static const dTextSub = Color(0xFF7DBFB8);
  static const dDivider = Color(0xFF1A3F3A);

  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const error = Color(0xFFEF5350);
  static const success = Color(0xFF26A69A);
}

class TravelMateTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final isLight = b == Brightness.light;
    final bg =
        isLight ? TravelMateColors.lBackground : TravelMateColors.dBackground;
    final surface =
        isLight ? TravelMateColors.lSurface : TravelMateColors.dSurface;
    final card = isLight ? TravelMateColors.lCard : TravelMateColors.dCard;
    final text = isLight ? TravelMateColors.lText : TravelMateColors.dText;
    final textSub =
        isLight ? TravelMateColors.lTextSub : TravelMateColors.dTextSub;
    final border =
        isLight ? TravelMateColors.lBorder : TravelMateColors.dBorder;

    return ThemeData(
      brightness: b,
      useMaterial3: true,
      fontFamily: 'Georgia',
      scaffoldBackgroundColor: bg,
      primaryColor: TravelMateColors.teal,
      colorScheme: ColorScheme(
        brightness: b,
        primary: TravelMateColors.teal,
        onPrimary: TravelMateColors.white,
        secondary: TravelMateColors.amber,
        onSecondary: TravelMateColors.black,
        error: TravelMateColors.error,
        onError: TravelMateColors.white,
        surface: surface,
        onSurface: text,
        outline: border,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: TravelMateColors.amber),
        titleTextStyle: TextStyle(
          color: text,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          fontFamily: 'Georgia',
        ),
        foregroundColor: text,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TravelMateColors.amber,
          foregroundColor: TravelMateColors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            fontFamily: 'Georgia',
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: TravelMateColors.teal,
          side: const BorderSide(color: TravelMateColors.teal, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight
            ? TravelMateColors.tealPale.withOpacity(0.15)
            : TravelMateColors.dBorder.withOpacity(0.4),
        hintStyle: TextStyle(color: textSub),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: TravelMateColors.teal, width: 2),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: TravelMateColors.teal,
        inactiveTrackColor: border,
        thumbColor: TravelMateColors.teal,
        overlayColor: TravelMateColors.teal.withOpacity(0.15),
        trackHeight: 3,
      ),
      textTheme: TextTheme(
        displayLarge:
            TextStyle(color: text, fontWeight: FontWeight.w900, fontSize: 40),
        displayMedium:
            TextStyle(color: text, fontWeight: FontWeight.w800, fontSize: 32),
        headlineMedium:
            TextStyle(color: text, fontWeight: FontWeight.w800, fontSize: 24),
        titleLarge:
            TextStyle(color: text, fontWeight: FontWeight.w700, fontSize: 18),
        bodyLarge: TextStyle(color: text, fontSize: 16),
        bodyMedium: TextStyle(color: textSub, fontSize: 14),
        labelSmall:
            TextStyle(color: textSub, fontSize: 11, letterSpacing: 1.5),
      ),
    );
  }
}

extension TravelMateContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get wBg =>
      isDark ? TravelMateColors.dBackground : TravelMateColors.lBackground;
  Color get wCard =>
      isDark ? TravelMateColors.dCard : TravelMateColors.lCard;
  Color get wText =>
      isDark ? TravelMateColors.dText : TravelMateColors.lText;
  Color get wTextSub =>
      isDark ? TravelMateColors.dTextSub : TravelMateColors.lTextSub;
  Color get wBorder =>
      isDark ? TravelMateColors.dBorder : TravelMateColors.lBorder;
  Color get wDivider =>
      isDark ? TravelMateColors.dDivider : TravelMateColors.lDivider;
  Color get wSurface =>
      isDark ? TravelMateColors.dSurface : TravelMateColors.lSurface;
}

class TravelMateGradients {
  static const brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [TravelMateColors.gradStart, TravelMateColors.gradEnd],
  );
  static const brandV = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [TravelMateColors.gradStart, TravelMateColors.gradEnd],
  );
}