import 'package:flutter/material.dart';

/// Shared visual language for the public entry screens only.
abstract final class AuthVisuals {
  static const background = Color(0xFF10191C);
  static const mint = Color(0xFF8CD9BF);
  static const muted = Color(0xFFB9C7CC);
  static const horizontalPadding = 24.0;

  static ThemeData theme(BuildContext context) {
    final base = Theme.of(context);
    final scheme = ColorScheme.fromSeed(
      seedColor: mint,
      brightness: Brightness.dark,
    ).copyWith(primary: mint, onPrimary: background, surface: background);
    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: base.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: mint,
          foregroundColor: background,
          minimumSize: const Size(double.infinity, 56),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: mint),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1B272C),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF415158)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: mint, width: 2),
        ),
      ),
    );
  }
}

class AuthBrand extends StatelessWidget {
  const AuthBrand({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final height in [14.0, 22.0, 30.0])
              Container(
                width: 5,
                height: height,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: AuthVisuals.mint,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(width: 8),
      Flexible(
        child: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );
}

class AuthArtwork extends StatelessWidget {
  const AuthArtwork({
    super.key,
    required this.asset,
    required this.height,
    this.fit = BoxFit.contain,
  });
  final String asset;
  final double height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            asset,
            fit: fit,
            alignment: Alignment.center,
            errorBuilder: (_, _, _) =>
                const ColoredBox(color: AuthVisuals.background),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  AuthVisuals.background,
                ],
                stops: [0, 0.72, 1],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
