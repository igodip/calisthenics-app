import 'package:calisync/l10n/app_localizations.dart';
import 'package:calisync/pages/settings_page.dart';
import 'package:calisync/theme/app_theme.dart';
import 'package:calisync/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

double contrast(Color a, Color b) {
  final first = a.computeLuminance();
  final second = b.computeLuminance();
  return (first > second ? first + 0.05 : second + 0.05) /
      (first > second ? second + 0.05 : first + 0.05);
}

void main() {
  test('all palettes keep readable text and accent buttons', () {
    for (final palette in AppThemeType.values) {
      final theme = AppTheme.themeFor(palette);
      final colors = theme.colorScheme;
      expect(
        contrast(colors.onSurface, colors.surface),
        greaterThanOrEqualTo(4.5),
        reason: palette.name,
      );
      expect(
        contrast(colors.onSurfaceVariant, colors.surfaceContainerHighest),
        greaterThanOrEqualTo(4.5),
        reason: palette.name,
      );
      expect(
        contrast(colors.onPrimary, colors.primary),
        greaterThanOrEqualTo(4.5),
        reason: palette.name,
      );
      expect(
        contrast(colors.onSecondary, colors.secondary),
        greaterThanOrEqualTo(4.5),
        reason: palette.name,
      );
      expect(
        contrast(colors.onError, colors.error),
        greaterThanOrEqualTo(4.5),
        reason: palette.name,
      );
      expect(
        AppTheme.themeTypeFromStorage(AppTheme.storageValueFor(palette)),
        palette,
      );
    }
  });

  testWidgets(
    'theme swatches fit a narrow phone and preserve saved selection',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final controller = ThemeController(
        preferences: preferences,
        initialTheme: AppThemeType.defaultTheme,
      );
      addTearDown(controller.dispose);
      await tester.binding.setSurfaceSize(const Size(320, 740));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ThemeControllerScope(
          controller: controller,
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) => MaterialApp(
              theme: controller.theme,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(1.3)),
                child: child!,
              ),
              home: const SettingsPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Purple'));
      await tester.tap(find.text('Purple'));
      await tester.pumpAndSettle();
      expect(controller.themeType, AppThemeType.purple);
      expect(preferences.getString(ThemeController.storageKey), 'purple');
      expect(tester.takeException(), isNull);
    },
  );
}
