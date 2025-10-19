import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const _prefDailyReminder = 'settings_dailyReminder';
  static const _prefReminderMinutes = 'settings_reminderMinutes';
  static const _prefSoundEffects = 'settings_soundEffects';
  static const _prefHapticFeedback = 'settings_hapticFeedback';
  static const _prefUnitSystem = 'settings_unitSystem';
  static const _prefRestTimer = 'settings_restTimer';
  static const _appVersion = '1.0.0';

  SharedPreferences? _prefs;
  bool _loading = true;

  bool _dailyReminder = false;
  TimeOfDay? _reminderTime;
  bool _soundEffects = true;
  bool _hapticFeedback = true;
  String _unitSystem = 'metric';
  int _restTimerSeconds = 90;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final reminderMinutes = prefs.getInt(_prefReminderMinutes);
    if (!mounted) {
      return;
    }

    setState(() {
      _prefs = prefs;
      _dailyReminder = prefs.getBool(_prefDailyReminder) ?? false;
      _soundEffects = prefs.getBool(_prefSoundEffects) ?? true;
      _hapticFeedback = prefs.getBool(_prefHapticFeedback) ?? true;
      _unitSystem = prefs.getString(_prefUnitSystem) ?? 'metric';
      _restTimerSeconds = prefs.getInt(_prefRestTimer) ?? 90;
      _reminderTime = reminderMinutes != null
          ? TimeOfDay(
              hour: reminderMinutes ~/ 60,
              minute: reminderMinutes % 60,
            )
          : null;
      _loading = false;
    });
  }

  Future<void> _toggleDailyReminder(bool value) async {
    setState(() {
      _dailyReminder = value;
      if (!value) {
        _reminderTime = null;
      }
    });

    final prefs = _prefs;
    if (prefs == null) return;

    await prefs.setBool(_prefDailyReminder, value);
    if (!value) {
      await prefs.remove(_prefReminderMinutes);
    }
  }

  Future<void> _pickReminderTime() async {
    final initialTime = _reminderTime ?? const TimeOfDay(hour: 7, minute: 0);
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked == null) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _reminderTime = picked;
      _dailyReminder = true;
    });

    final prefs = _prefs;
    if (prefs == null) return;

    await prefs.setBool(_prefDailyReminder, true);
    await prefs.setInt(
      _prefReminderMinutes,
      picked.hour * 60 + picked.minute,
    );
  }

  Future<void> _toggleSoundEffects(bool value) async {
    setState(() => _soundEffects = value);
    await _prefs?.setBool(_prefSoundEffects, value);
  }

  Future<void> _toggleHaptics(bool value) async {
    setState(() => _hapticFeedback = value);
    await _prefs?.setBool(_prefHapticFeedback, value);
  }

  Future<void> _changeUnitSystem(String? value) async {
    if (value == null) return;
    setState(() => _unitSystem = value);
    await _prefs?.setString(_prefUnitSystem, value);
  }

  Future<void> _changeRestTimer(int? value) async {
    if (value == null) return;
    setState(() => _restTimerSeconds = value);
    await _prefs?.setInt(_prefRestTimer, value);
  }

  String _formatReminderSubtitle(AppLocalizations l10n) {
    if (!_dailyReminder) {
      return l10n.settingsDailyReminderDescription;
    }
    if (_reminderTime == null) {
      return l10n.settingsReminderNotSet;
    }
    final formatted = MaterialLocalizations.of(context).formatTimeOfDay(
      _reminderTime!,
      alwaysUse24HourFormat:
          MediaQuery.of(context).alwaysUse24HourFormat,
    );
    return '${l10n.settingsReminderTime}: $formatted';
  }

  String _restTimerLabel(AppLocalizations l10n, int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0 && remainingSeconds == 0) {
      return l10n.settingsRestTimerMinutes(minutes);
    }
    if (minutes > 0 && remainingSeconds > 0) {
      return l10n.settingsRestTimerMinutesSeconds(minutes, remainingSeconds);
    }
    return l10n.settingsRestTimerSeconds(seconds);
  }

  Future<void> _clearCache() async {
    final l10n = AppLocalizations.of(context)!;
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settingsClearCacheSuccess)),
    );
  }

  Future<void> _exportData() async {
    final l10n = AppLocalizations.of(context)!;
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settingsExportDataSuccess)),
    );
  }

  Future<void> _contactCoach() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final message = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.settingsContactCoach),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: l10n.settingsContactCoachHint,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text.trim());
              },
              child: Text(l10n.settingsSendMessage),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (message == null || message.isEmpty) {
      return;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settingsContactCoachSuccess)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionHeader(title: l10n.settingsGeneralSection),
        _SettingsCard(
          children: [
            SwitchListTile.adaptive(
              value: _dailyReminder,
              onChanged: _toggleDailyReminder,
              title: Text(l10n.settingsDailyReminder),
              subtitle: Text(_formatReminderSubtitle(l10n)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            if (_dailyReminder) ...[
              const Divider(height: 0),
              ListTile(
                onTap: _pickReminderTime,
                title: Text(l10n.settingsReminderTime),
                subtitle: Text(
                  _reminderTime == null
                      ? l10n.settingsReminderNotSet
                      : MaterialLocalizations.of(context).formatTimeOfDay(
                          _reminderTime!,
                          alwaysUse24HourFormat:
                              MediaQuery.of(context).alwaysUse24HourFormat,
                        ),
                ),
                trailing: const Icon(Icons.schedule),
              ),
            ],
            const Divider(height: 0),
            SwitchListTile.adaptive(
              value: _soundEffects,
              onChanged: _toggleSoundEffects,
              title: Text(l10n.settingsSoundEffects),
              subtitle: Text(l10n.settingsSoundEffectsDescription),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            const Divider(height: 0),
            SwitchListTile.adaptive(
              value: _hapticFeedback,
              onChanged: _toggleHaptics,
              title: Text(l10n.settingsHapticFeedback),
              subtitle: Text(l10n.settingsHapticFeedbackDescription),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SectionHeader(title: l10n.settingsTrainingSection),
        _SettingsCard(
          children: [
            ListTile(
              title: Text(l10n.settingsUnitSystem),
              subtitle: Text(
                _unitSystem == 'metric'
                    ? l10n.settingsUnitsMetric
                    : l10n.settingsUnitsImperial,
              ),
              trailing: DropdownButton<String>(
                value: _unitSystem,
                dropdownColor: theme.cardColor,
                onChanged: _changeUnitSystem,
                underline: const SizedBox.shrink(),
                items: [
                  DropdownMenuItem(
                    value: 'metric',
                    child: Text(l10n.settingsUnitsMetric),
                  ),
                  DropdownMenuItem(
                    value: 'imperial',
                    child: Text(l10n.settingsUnitsImperial),
                  ),
                ],
              ),
            ),
            const Divider(height: 0),
            ListTile(
              title: Text(l10n.settingsRestTimer),
              subtitle: Text(l10n.settingsRestTimerDescription),
              trailing: DropdownButton<int>(
                value: _restTimerSeconds,
                dropdownColor: theme.cardColor,
                onChanged: _changeRestTimer,
                underline: const SizedBox.shrink(),
                items: const [60, 90, 120, 180]
                    .map(
                      (seconds) => DropdownMenuItem(
                        value: seconds,
                        child: Text(_restTimerLabel(l10n, seconds)),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SectionHeader(title: l10n.settingsDataSection),
        _SettingsCard(
          children: [
            ListTile(
              onTap: _clearCache,
              title: Text(l10n.settingsClearCache),
              subtitle: Text(l10n.settingsClearCacheDescription),
              trailing: const Icon(Icons.delete_outline),
            ),
            const Divider(height: 0),
            ListTile(
              onTap: _exportData,
              title: Text(l10n.settingsExportData),
              subtitle: Text(l10n.settingsExportDataDescription),
              trailing: const Icon(Icons.file_download_outlined),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SectionHeader(title: l10n.settingsSupportSection),
        _SettingsCard(
          children: [
            ListTile(
              onTap: _contactCoach,
              title: Text(l10n.settingsContactCoach),
              subtitle: Text(l10n.settingsContactCoachDescription),
              trailing: const Icon(Icons.message_outlined),
            ),
            const Divider(height: 0),
            ListTile(
              title: Text(l10n.settingsAppVersion),
              subtitle: Text(l10n.settingsAppVersionValue(_appVersion)),
              leading: const Icon(Icons.info_outline),
            ),
          ],
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(children: children),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

