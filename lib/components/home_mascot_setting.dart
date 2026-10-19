import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';

enum AthleteAuraStyle { dragonBall, naruto }

/// Device-local preference shared by Settings and the Home animation.
abstract final class HomeMascotSettings {
  static const storageKey = 'home_mascot_enabled';
  static const auraStorageKey = 'home_mascot_aura_style';
  static final enabled = ValueNotifier<bool>(false);
  static final auraStyle = ValueNotifier<AthleteAuraStyle>(
    AthleteAuraStyle.dragonBall,
  );

  static Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    auraStyle.value = preferences.getString(auraStorageKey) == 'naruto'
        ? AthleteAuraStyle.naruto
        : AthleteAuraStyle.dragonBall;
    enabled.value = preferences.getBool(storageKey) ?? false;
  }

  static Future<void> setEnabled(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(storageKey, value);
    enabled.value = value;
  }

  static Future<void> setAuraStyle(AthleteAuraStyle value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(auraStorageKey, value.name);
    auraStyle.value = value;
  }
}

class HomeMascotSetting extends StatefulWidget {
  const HomeMascotSetting({super.key});

  @override
  State<HomeMascotSetting> createState() => _HomeMascotSettingState();
}

class _HomeMascotSettingState extends State<HomeMascotSetting> {
  @override
  void initState() {
    super.initState();
    unawaited(HomeMascotSettings.load());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ValueListenableBuilder<bool>(
      valueListenable: HomeMascotSettings.enabled,
      builder: (context, enabled, _) => SwitchListTile.adaptive(
        key: const ValueKey('home-mascot-setting'),
        title: Text(l10n.homeMascotTitle),
        subtitle: Text(l10n.homeMascotDescription),
        value: enabled,
        onChanged: (value) => unawaited(HomeMascotSettings.setEnabled(value)),
      ),
    );
  }
}
