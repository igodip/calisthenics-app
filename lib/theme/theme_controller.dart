import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

class ThemeController extends ChangeNotifier {
  ThemeController({
    required SharedPreferences preferences,
    required AppThemeType initialTheme,
  })  : _preferences = preferences,
        _themeType = initialTheme;

  static const String storageKey = 'selected_theme';

  final SharedPreferences _preferences;
  AppThemeType _themeType;

  AppThemeType get themeType => _themeType;

  ThemeData get theme => AppTheme.themeFor(_themeType);

  Future<void> setTheme(AppThemeType type) async {
    if (_themeType == type) return;
    _themeType = type;
    notifyListeners();
    await _preferences.setString(storageKey, AppTheme.storageValueFor(type));
  }
}

class ThemeControllerScope extends InheritedNotifier<ThemeController> {
  const ThemeControllerScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeControllerScope>();
    assert(scope != null, 'ThemeControllerScope not found in widget tree.');
    return scope!.notifier!;
  }
}
