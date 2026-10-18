import 'package:calisync/components/user_id_section.dart';
import 'package:calisync/l10n/app_localizations.dart';
import 'package:calisync/theme/app_theme.dart';
import 'package:calisync/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import '../components/account_deletion_section.dart';
import '../components/privacy_policy_link.dart';

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
      (AppThemeType.yellow, l10n.themeYellowLabel),
      (AppThemeType.purple, l10n.themePurpleLabel),
      (AppThemeType.orange, l10n.themeOrangeLabel),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountSettingsTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ListView(
            children: [
              Text(
                l10n.settingsThemeTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 500 ? 4 : 2;
                      final width =
                          (constraints.maxWidth - 12 * (columns - 1)) / columns;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final option in themeOptions)
                            SizedBox(
                              width: width,
                              child: Semantics(
                                selected: controller.themeType == option.$1,
                                button: true,
                                child: Material(
                                  color: controller.themeType == option.$1
                                      ? theme.colorScheme.primaryContainer
                                      : theme.scaffoldBackgroundColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    side: BorderSide(
                                      color: controller.themeType == option.$1
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.outlineVariant,
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    onTap: () => controller.setTheme(option.$1),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundColor:
                                                AppTheme.previewColorFor(
                                                  option.$1,
                                                ),
                                            child:
                                                controller.themeType ==
                                                    option.$1
                                                ? Icon(
                                                    Icons.check_rounded,
                                                    color:
                                                        AppTheme.previewColorFor(
                                                              option.$1,
                                                            ).computeLuminance() >
                                                            0.179
                                                        ? Colors.black
                                                        : Colors.white,
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            option.$2,
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.labelLarge,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.privacySettingsDescription),
                      const PrivacyPolicyLink(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const AccountDeletionSection(),
              const SizedBox(height: 16),
              const UserIdSection(),
            ],
          ),
        ),
      ),
    );
  }
}
