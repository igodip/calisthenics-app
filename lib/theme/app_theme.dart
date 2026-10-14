import 'package:flutter/material.dart';

enum AppThemeType {
  defaultTheme,
  black,
  pink,
  red,
  blue,
  yellow,
  purple,
  orange,
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
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      primaryGradient: LinearGradient.lerp(
        primaryGradient,
        other.primaryGradient,
        t,
      )!,
      surfaceTint: Color.lerp(surfaceTint, other.surfaceTint, t)!,
    );
  }
}

class AppTheme {
  AppTheme._();

  static const Color _defaultPrimary = Color(0xFF64CBA4);
  static const Color _defaultSecondary = Color(0xFF6CAFAE);
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

  static const Color _yellowPrimary = Color(0xFFF4C542);
  static const Color _yellowSecondary = Color(0xFFE0A81E);
  static const Color _yellowBackground = Color(0xFF2A2415);
  static const Color _yellowSurface = Color(0xFF352D1B);
  static const Color _yellowSurfaceVariant = Color(0xFF433823);
  static const Color _yellowTertiary = Color(0xFFFFF4CC);

  static const Color _purplePrimary = Color(0xFFAB76E8);
  static const Color _purpleSecondary = Color(0xFF8E5BC7);
  static const Color _purpleBackground = Color(0xFF21182B);
  static const Color _purpleSurface = Color(0xFF2D2239);
  static const Color _purpleSurfaceVariant = Color(0xFF392B49);
  static const Color _purpleTertiary = Color(0xFFF0E2FF);

  static const Color _orangePrimary = Color(0xFFFF9E45);
  static const Color _orangeSecondary = Color(0xFFE77922);
  static const Color _orangeBackground = Color(0xFF2B1E14);
  static const Color _orangeSurface = Color(0xFF39271A);
  static const Color _orangeSurfaceVariant = Color(0xFF493221);
  static const Color _orangeTertiary = Color(0xFFFFE8D1);

  static const Color _success = Color(0xFF91DBAD);
  static const Color _warning = Color(0xFFF4C36B);

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
      case 'yellow':
        return AppThemeType.yellow;
      case 'purple':
        return AppThemeType.purple;
      case 'orange':
        return AppThemeType.orange;
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
      AppThemeType.yellow => 'yellow',
      AppThemeType.purple => 'purple',
      AppThemeType.orange => 'orange',
      AppThemeType.defaultTheme => 'default',
    };
  }

  static Color previewColorFor(AppThemeType type) {
    return switch (type) {
      AppThemeType.black => _blackPrimary,
      AppThemeType.pink => _pinkPrimary,
      AppThemeType.red => _redPrimary,
      AppThemeType.blue => _bluePrimary,
      AppThemeType.yellow => _yellowPrimary,
      AppThemeType.purple => _purplePrimary,
      AppThemeType.orange => _orangePrimary,
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
      AppThemeType.yellow => _buildTheme(
        primary: _yellowPrimary,
        secondary: _yellowSecondary,
        background: _yellowBackground,
        surface: _yellowSurface,
        surfaceVariant: _yellowSurfaceVariant,
        tertiary: _yellowTertiary,
        surfaceTint: _yellowTertiary.withValues(alpha: 0.2),
      ),
      AppThemeType.purple => _buildTheme(
        primary: _purplePrimary,
        secondary: _purpleSecondary,
        background: _purpleBackground,
        surface: _purpleSurface,
        surfaceVariant: _purpleSurfaceVariant,
        tertiary: _purpleTertiary,
        surfaceTint: _purpleTertiary.withValues(alpha: 0.2),
      ),
      AppThemeType.orange => _buildTheme(
        primary: _orangePrimary,
        secondary: _orangeSecondary,
        background: _orangeBackground,
        surface: _orangeSurface,
        surfaceVariant: _orangeSurfaceVariant,
        tertiary: _orangeTertiary,
        surfaceTint: _orangeTertiary.withValues(alpha: 0.2),
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
    final canvas = Color.lerp(const Color(0xFF0E1419), background, 0.12)!;
    final panel = Color.lerp(const Color(0xFF192128), surface, 0.12)!;
    final raised = Color.lerp(const Color(0xFF242E36), surfaceVariant, 0.12)!;
    final accent = Color.lerp(primary, Colors.white, 0.28)!;
    final secondaryAccent = Color.lerp(secondary, Colors.white, 0.3)!;
    final onAccent = accent.computeLuminance() > 0.179
        ? const Color(0xFF102019)
        : Colors.white;
    final onSecondaryAccent = secondaryAccent.computeLuminance() > 0.179
        ? const Color(0xFF102019)
        : Colors.white;
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
          surface: panel,
        ).copyWith(
          primary: accent,
          secondary: secondaryAccent,
          tertiary: tertiary,
          surfaceContainerLowest: canvas,
          surfaceContainerLow: panel,
          surfaceContainer: Color.lerp(panel, raised, 0.45),
          surfaceContainerHigh: raised,
          surfaceContainerHighest: Color.lerp(raised, Colors.white, 0.04),
          primaryContainer: Color.lerp(panel, accent, 0.16),
          onPrimaryContainer: accent,
          secondaryContainer: Color.lerp(panel, secondaryAccent, 0.16),
          onSecondaryContainer: secondaryAccent,
          onPrimary: onAccent,
          onSecondary: onSecondaryAccent,
          onTertiary: Colors.black,
          onError: const Color(0xFF34100F),
          onSurface: const Color(0xFFF1F5F6),
          onSurfaceVariant: const Color(0xFFB0BEC7),
          error: _error,
          surfaceTint: Colors.transparent,
          outline: const Color(0xFF62717B),
          outlineVariant: const Color(0xFF34424C),
          shadow: Colors.black,
        );

    final appColors = AppColors(
      success: _success,
      successContainer: _success.withValues(alpha: 0.2),
      warning: _warning,
      warningContainer: _warning.withValues(alpha: 0.2),
      primaryGradient: LinearGradient(
        colors: [
          Color.lerp(panel, accent, 0.24)!,
          Color.lerp(canvas, secondaryAccent, 0.15)!,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      surfaceTint: surfaceTint,
    );

    final baseText = ThemeData.dark(useMaterial3: true).textTheme;
    final textTheme = baseText
        .copyWith(
          headlineLarge: baseText.headlineLarge?.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.1,
          ),
          headlineMedium: baseText.headlineMedium?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
          ),
          headlineSmall: baseText.headlineSmall?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
          titleLarge: baseText.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
          titleMedium: baseText.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
          bodyLarge: baseText.bodyLarge?.copyWith(fontSize: 16, height: 1.45),
          bodyMedium: baseText.bodyMedium?.copyWith(fontSize: 14, height: 1.45),
          labelLarge: baseText.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        )
        .apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: canvas,
      textTheme: textTheme,
      shadowColor: Colors.black,
      appBarTheme: AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: panel,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
        elevation: 0,
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
          backgroundColor: accent,
          foregroundColor: onAccent,
          elevation: 0,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: onAccent,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outlineVariant),
          backgroundColor: Colors.transparent,
          minimumSize: const Size(48, 48),
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: canvas.withValues(alpha: 0.6),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accent, width: 1.6),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIconColor: Colors.white70,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Color.lerp(surfaceVariant, Colors.black, 0.35),
        behavior: SnackBarBehavior.floating,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: const DividerThemeData(color: Colors.white12, thickness: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: raised,
        borderRadius: BorderRadius.circular(20),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: canvas,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        selectedColor: accent,
        selectedTileColor: colorScheme.primaryContainer,
        iconColor: colorScheme.onSurfaceVariant,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: raised,
        selectedColor: colorScheme.primaryContainer,
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: const StadiumBorder(),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(color: accent),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: panel,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: panel,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: raised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      iconTheme: const IconThemeData(color: Colors.white70),
      extensions: <ThemeExtension<dynamic>>[appColors],
    );
  }
}
