import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    required this.primaryGradient,
    required this.surfaceTint,
  });

  final Color success;
  final Color successContainer;
  final Color warning;
  final Color warningContainer;
  final LinearGradient primaryGradient;
  final Color surfaceTint;

  static const AppColors dark = AppColors(
    success: Color(0xFF6C9C48),
    successContainer: Color(0x336C9C48),
    warning: Color(0xFFFFA726),
    warningContainer: Color(0x33FFA726),
    primaryGradient: LinearGradient(
      colors: [Color(0xFF759858), Color(0xFF5A7D3E)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    surfaceTint: Color(0x26EDE8DF),
  );

  @override
  AppColors copyWith({
    Color? success,
    Color? successContainer,
    Color? warning,
    Color? warningContainer,
    LinearGradient? primaryGradient,
    Color? surfaceTint,
  }) {
    return AppColors(
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      primaryGradient: primaryGradient ?? this.primaryGradient,
      surfaceTint: surfaceTint ?? this.surfaceTint,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      primaryGradient: LinearGradient.lerp(primaryGradient, other.primaryGradient, t)!,
      surfaceTint: Color.lerp(surfaceTint, other.surfaceTint, t)!,
    );
  }
}

class AppTheme {
  AppTheme._();

  static const Color _primary = Color(0xFF759858);
  static const Color _secondary = Color(0xFF6C9C48);
  static const Color _background = Color(0xFF332F2C);
  static const Color _surface = Color(0xFF3D3732);
  static const Color _surfaceVariant = Color(0xFF47403A);
  static const Color _tertiary = Color(0xFFEDE8DF);
  static const Color _error = Color(0xFFFF5C5C);

  static final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: _primary,
    brightness: Brightness.dark,
    surface: _surface,
  ).copyWith(
    secondary: _secondary,
    tertiary: _tertiary,
    primaryContainer: _surfaceVariant,
    secondaryContainer: _secondary.withValues(alpha: 0.2),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onTertiary: Colors.black,
    onError: Colors.white,
    onSurface: Colors.white,
    onSurfaceVariant: Colors.white70,
    error: _error,
    surfaceTint: const Color(0x26EDE8DF),
    outline: Colors.white24,
    outlineVariant: Colors.white12,
    shadow: Colors.black,
  );

  static ThemeData theme = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _background,
    shadowColor: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: _surface,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),
    cardTheme: CardThemeData(
      color: _surfaceVariant,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _surface,
      selectedItemColor: _primary,
      unselectedItemColor: Colors.white70,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _secondary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white30),
        backgroundColor: Colors.white10,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white70,
        textStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.04),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _primary, width: 1.6),
      ),
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIconColor: Colors.white70,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _surfaceVariant,
      behavior: SnackBarBehavior.floating,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: const DividerThemeData(color: Colors.white12, thickness: 1),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: _primary),
    iconTheme: const IconThemeData(color: Colors.white70),
    extensions: const <ThemeExtension<dynamic>>[
      AppColors.dark,
    ],
  );
}
