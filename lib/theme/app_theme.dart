import 'package:flutter/material.dart';

enum AppThemeType {
  defaultTheme,
  black,
  pink,
  red,
  blue,
}

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

  static const Color _defaultPrimary = Color(0xFF759858);
  static const Color _defaultSecondary = Color(0xFF6C9C48);
  static const Color _defaultBackground = Color(0xFF332F2C);
  static const Color _defaultSurface = Color(0xFF3D3732);
  static const Color _defaultSurfaceVariant = Color(0xFF47403A);
  static const Color _defaultTertiary = Color(0xFFEDE8DF);
  static const Color _error = Color(0xFFFF5C5C);

  static const Color _blackPrimary = Color(0xFFB0BEC5);
  static const Color _blackSecondary = Color(0xFF78909C);
  static const Color _blackBackground = Color(0xFF0B0B0B);
  static const Color _blackSurface = Color(0xFF151515);
  static const Color _blackSurfaceVariant = Color(0xFF1E1E1E);
  static const Color _blackTertiary = Color(0xFFE0E0E0);

  static const Color _pinkPrimary = Color(0xFFF06292);
  static const Color _pinkSecondary = Color(0xFFEC407A);
  static const Color _pinkBackground = Color(0xFF2B1A21);
  static const Color _pinkSurface = Color(0xFF3A2430);
  static const Color _pinkSurfaceVariant = Color(0xFF432A37);
  static const Color _pinkTertiary = Color(0xFFFCE4EC);

  static const Color _redPrimary = Color(0xFFE53935);
  static const Color _redSecondary = Color(0xFFD32F2F);
  static const Color _redBackground = Color(0xFF2B1919);
  static const Color _redSurface = Color(0xFF3A2323);
  static const Color _redSurfaceVariant = Color(0xFF442828);
  static const Color _redTertiary = Color(0xFFFFEBEE);

  static const Color _bluePrimary = Color(0xFF42A5F5);
  static const Color _blueSecondary = Color(0xFF1E88E5);
  static const Color _blueBackground = Color(0xFF18212B);
  static const Color _blueSurface = Color(0xFF22303D);
  static const Color _blueSurfaceVariant = Color(0xFF293949);
  static const Color _blueTertiary = Color(0xFFE3F2FD);

  static const Color _success = Color(0xFF6C9C48);
  static const Color _warning = Color(0xFFFFA726);

  static AppThemeType themeTypeFromStorage(String? value) {
    switch (value) {
      case 'black':
        return AppThemeType.black;
      case 'pink':
        return AppThemeType.pink;
      case 'red':
        return AppThemeType.red;
      case 'blue':
        return AppThemeType.blue;
      case 'default':
      default:
        return AppThemeType.defaultTheme;
    }
  }

  static String storageValueFor(AppThemeType type) {
    return switch (type) {
      AppThemeType.black => 'black',
      AppThemeType.pink => 'pink',
      AppThemeType.red => 'red',
      AppThemeType.blue => 'blue',
      AppThemeType.defaultTheme => 'default',
    };
  }

  static Color previewColorFor(AppThemeType type) {
    return switch (type) {
      AppThemeType.black => _blackPrimary,
      AppThemeType.pink => _pinkPrimary,
      AppThemeType.red => _redPrimary,
      AppThemeType.blue => _bluePrimary,
      AppThemeType.defaultTheme => _defaultPrimary,
    };
  }

  static ThemeData themeFor(AppThemeType type) {
    return switch (type) {
      AppThemeType.black => _buildTheme(
          primary: _blackPrimary,
          secondary: _blackSecondary,
          background: _blackBackground,
          surface: _blackSurface,
          surfaceVariant: _blackSurfaceVariant,
          tertiary: _blackTertiary,
          surfaceTint: _blackTertiary.withValues(alpha: 0.2),
        ),
      AppThemeType.pink => _buildTheme(
          primary: _pinkPrimary,
          secondary: _pinkSecondary,
          background: _pinkBackground,
          surface: _pinkSurface,
          surfaceVariant: _pinkSurfaceVariant,
          tertiary: _pinkTertiary,
          surfaceTint: _pinkTertiary.withValues(alpha: 0.2),
        ),
      AppThemeType.red => _buildTheme(
          primary: _redPrimary,
          secondary: _redSecondary,
          background: _redBackground,
          surface: _redSurface,
          surfaceVariant: _redSurfaceVariant,
          tertiary: _redTertiary,
          surfaceTint: _redTertiary.withValues(alpha: 0.2),
        ),
      AppThemeType.blue => _buildTheme(
          primary: _bluePrimary,
          secondary: _blueSecondary,
          background: _blueBackground,
          surface: _blueSurface,
          surfaceVariant: _blueSurfaceVariant,
          tertiary: _blueTertiary,
          surfaceTint: _blueTertiary.withValues(alpha: 0.2),
        ),
      AppThemeType.defaultTheme => _buildTheme(
          primary: _defaultPrimary,
          secondary: _defaultSecondary,
          background: _defaultBackground,
          surface: _defaultSurface,
          surfaceVariant: _defaultSurfaceVariant,
          tertiary: _defaultTertiary,
          surfaceTint: const Color(0x26EDE8DF),
        ),
    };
  }

  static ThemeData theme = themeFor(AppThemeType.defaultTheme);

  static ThemeData _buildTheme({
    required Color primary,
    required Color secondary,
    required Color background,
    required Color surface,
    required Color surfaceVariant,
    required Color tertiary,
    required Color surfaceTint,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      surface: surface,
    ).copyWith(
      secondary: secondary,
      tertiary: tertiary,
      primaryContainer: surfaceVariant,
      secondaryContainer: secondary.withValues(alpha: 0.2),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.black,
      onError: Colors.white,
      onSurface: Colors.white,
      onSurfaceVariant: Colors.white70,
      error: _error,
      surfaceTint: surfaceTint,
      outline: Colors.white24,
      outlineVariant: Colors.white12,
      shadow: Colors.black,
    );

    final appColors = AppColors(
      success: _success,
      successContainer: _success.withValues(alpha: 0.2),
      warning: _warning,
      warningContainer: _warning.withValues(alpha: 0.2),
      primaryGradient: LinearGradient(
        colors: [primary, secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      surfaceTint: surfaceTint,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      shadowColor: Colors.black,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
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
        color: surfaceVariant,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: Colors.white70,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: secondary,
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
          borderSide: BorderSide(color: primary, width: 1.6),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIconColor: Colors.white70,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceVariant,
        behavior: SnackBarBehavior.floating,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: const DividerThemeData(color: Colors.white12, thickness: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
      iconTheme: const IconThemeData(color: Colors.white70),
      extensions: <ThemeExtension<dynamic>>[
        appColors,
      ],
    );
  }
}
