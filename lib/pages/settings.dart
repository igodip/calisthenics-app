import 'package:calisync/l10n/app_localizations.dart';
import 'package:calisync/theme/app_theme.dart';
import 'package:calisync/theme/theme_controller.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final controller = ThemeControllerScope.of(context);

    final themeOptions = [
      (AppThemeType.defaultTheme, l10n.themeDefaultLabel),
      (AppThemeType.black, l10n.themeBlackLabel),
      (AppThemeType.pink, l10n.themePinkLabel),
      (AppThemeType.red, l10n.themeRedLabel),
      (AppThemeType.blue, l10n.themeBlueLabel),
    ];

    return Scaffold(
        appBar: AppBar(
          title: Text(l10n.settingsThemeTitle),
        ),
        body: SafeArea(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settingsThemeTitle,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: RadioGroup<AppThemeType>(
              groupValue: controller.themeType,
              onChanged: (value) {
                if (value != null) controller.setTheme(value);
              },
              child: Column(
                children: [
                  for (final option in themeOptions)
                    RadioListTile<AppThemeType>(
                      value: option.$1,
                      title: Text(option.$2),
                      secondary: CircleAvatar(
                        radius: 12,
                        backgroundColor: AppTheme.previewColorFor(option.$1),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    )
    )
    );
  }
}
