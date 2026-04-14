import 'package:flutter/material.dart';

// ──────────────────────────────────────────
// Custom theme extension for semantic colours
// ──────────────────────────────────────────

@immutable
class PuantajColors extends ThemeExtension<PuantajColors> {
  final Color worked;
  final Color workedText;
  final Color unworked;
  final Color unworkedBorder;
  final Color subtext;
  final Color cardBg;
  final Color background;
  final Color separator;
  final Color statCard;
  final Color noteIndicator;

  const PuantajColors({
    required this.worked,
    required this.workedText,
    required this.unworked,
    required this.unworkedBorder,
    required this.subtext,
    required this.cardBg,
    required this.background,
    required this.separator,
    required this.statCard,
    required this.noteIndicator,
  });

  const PuantajColors.light()
      : worked = const Color(0xFF4CAF7D),
        workedText = const Color(0xFFFFFFFF),
        unworked = const Color(0xFFEBF0F7),
        unworkedBorder = const Color(0xFFCDD7E8),
        subtext = const Color(0xFF7A8FA6),
        cardBg = const Color(0xFFFFFFFF),
        background = const Color(0xFFF0F4F8),
        separator = const Color(0xFFE4ECF5),
        statCard = const Color(0xFFF7FAFD),
        noteIndicator = const Color(0xFFFFB74D);

  const PuantajColors.dark()
      : worked = const Color(0xFF3D8B62),
        workedText = const Color(0xFFE8F5EE),
        unworked = const Color(0xFF272D3C),
        unworkedBorder = const Color(0xFF3A4356),
        subtext = const Color(0xFF8896A5),
        cardBg = const Color(0xFF252932),
        background = const Color(0xFF1A1D24),
        separator = const Color(0xFF2C3240),
        statCard = const Color(0xFF1E2430),
        noteIndicator = const Color(0xFFFFB74D);

  @override
  PuantajColors copyWith({
    Color? worked,
    Color? workedText,
    Color? unworked,
    Color? unworkedBorder,
    Color? subtext,
    Color? cardBg,
    Color? background,
    Color? separator,
    Color? statCard,
    Color? noteIndicator,
  }) =>
      PuantajColors(
        worked: worked ?? this.worked,
        workedText: workedText ?? this.workedText,
        unworked: unworked ?? this.unworked,
        unworkedBorder: unworkedBorder ?? this.unworkedBorder,
        subtext: subtext ?? this.subtext,
        cardBg: cardBg ?? this.cardBg,
        background: background ?? this.background,
        separator: separator ?? this.separator,
        statCard: statCard ?? this.statCard,
        noteIndicator: noteIndicator ?? this.noteIndicator,
      );

  @override
  PuantajColors lerp(PuantajColors? other, double t) {
    if (other == null) return this;
    return PuantajColors(
      worked: Color.lerp(worked, other.worked, t)!,
      workedText: Color.lerp(workedText, other.workedText, t)!,
      unworked: Color.lerp(unworked, other.unworked, t)!,
      unworkedBorder: Color.lerp(unworkedBorder, other.unworkedBorder, t)!,
      subtext: Color.lerp(subtext, other.subtext, t)!,
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
      background: Color.lerp(background, other.background, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
      statCard: Color.lerp(statCard, other.statCard, t)!,
      noteIndicator: Color.lerp(noteIndicator, other.noteIndicator, t)!,
    );
  }
}

// ──────────────────────────────────────────
// App themes
// ──────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3A7BD5),
          brightness: Brightness.light,
        ).copyWith(
          surface: const Color(0xFFFFFFFF),
          onSurface: const Color(0xFF1E2D3D),
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFFFF),
          foregroundColor: Color(0xFF1E2D3D),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: Color(0xFF1E2D3D),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
          iconTheme: IconThemeData(color: Color(0xFF556070)),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFFFFFFF),
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF3A7BD5),
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF0F4F8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCDD7E8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCDD7E8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF3A7BD5), width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        extensions: const [PuantajColors.light()],
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B9BD5),
          brightness: Brightness.dark,
        ).copyWith(
          surface: const Color(0xFF252932),
          onSurface: const Color(0xFFE2E8F0),
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1D24),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF252932),
          foregroundColor: Color(0xFFE2E8F0),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: Color(0xFFE2E8F0),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
          iconTheme: IconThemeData(color: Color(0xFF8896A5)),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF252932),
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF5B9BD5),
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E2430),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3A4356)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3A4356)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF5B9BD5), width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        extensions: const [PuantajColors.dark()],
      );
}
