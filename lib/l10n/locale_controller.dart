import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  LocaleController({
    required SharedPreferences preferences,
    Locale? initialLocale,
  })  : _preferences = preferences,
        _locale = initialLocale;

  static const String storageKey = 'selected_locale';

  final SharedPreferences _preferences;
  Locale? _locale;

  Locale? get locale => _locale;

  Future<void> setLocale(Locale? locale) async {
    if (_locale?.languageCode == locale?.languageCode) return;
    _locale = locale;
    notifyListeners();
    if (locale == null) {
      await _preferences.remove(storageKey);
    } else {
      await _preferences.setString(storageKey, locale.languageCode);
    }
  }
}

class LocaleControllerScope extends InheritedNotifier<LocaleController> {
  const LocaleControllerScope({
    super.key,
    required LocaleController controller,
    required super.child,
  }) : super(notifier: controller);

  static LocaleController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LocaleControllerScope>();
    assert(scope != null, 'LocaleControllerScope not found in widget tree.');
    return scope!.notifier!;
  }
}
