// lib/profile.dart
import 'package:calisync/model/trainee.dart';
import 'package:calisync/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_localizations.dart';
import '../model/max_test.dart';
import 'login.dart';

final supabase = Supabase.instance.client;

class UserProfileData {
  const UserProfileData({
    required this.userId,
    required this.email,
    required this.username,
    required this.isActive,
    required this.isPayed,
    this.profile,
  });

  final String userId;
  final String email;
  final String username;
  final bool isActive;
  final bool isPayed;
  final Trainee? profile;

  String displayName(AppLocalizations l10n) {
    final fullName = profile?.name?.trim();
    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    }
    if (username.trim().isNotEmpty) {
      return username;
    }
    if (email.trim().isNotEmpty) {
      return email.split('@').first;
    }
    return l10n.profileFallbackName;
  }

  String initials(AppLocalizations l10n) {
    final name = displayName(l10n);
    final nameParts = name.trim().split(RegExp(r'\s+'));
    if (nameParts.length == 1) {
      return nameParts.first.characters.take(2).toString().toUpperCase();
    }
    return nameParts.take(2).map((part) => part.characters.first).join().toUpperCase();
  }
}

Future<UserProfileData> getUserData() async {
  final user = supabase.auth.currentUser;
  if (user == null) {
    throw Exception('Utente non autenticato');
  }

  final profileResponse = await supabase
      .from('trainees')
      .select(
          'id, name, paid, weight')
      .eq('id', user.id)
      .limit(1)
      .maybeSingle();

  if (profileResponse == null) {
    throw Exception('user-not-found');
  }

  final profile = Trainee.fromMap(profileResponse);
  final name = profile.name ??
      (user.email != null ? user.email!.split('@').first : '');

  return UserProfileData(
    userId: user.id,
    email: user.email ?? '',
    username: name,
    isActive: true,
    isPayed: profile.paid ?? false,
    profile: profile,
  );
}

Future<void> logout(BuildContext context) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context)!;
  try {
    await supabase.auth.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  } catch (e) {
    scaffoldMessenger.showSnackBar(
      SnackBar(content: Text(l10n.logoutError('$e'))),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<UserProfileData> _profileFuture;
  Future<List<MaxTest>>? _maxTestsFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = getUserData();
  }

  void _refreshProfile() {
    setState(() {
      _profileFuture = getUserData();
      _maxTestsFuture = null;
    });
  }

  void _refreshMaxTests(String userId) {
    setState(() {
      _maxTestsFuture = _loadMaxTests(userId);
    });
  }

  Future<void> _showEditProfile(UserProfileData data) async {
    final l10n = AppLocalizations.of(context)!;
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _EditProfileBottomSheet(data: data),
    );
    if (updated == true && mounted) {
      _refreshProfile();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.profileEditSuccess)));
    }
  }

  Future<List<MaxTest>> _loadMaxTests(String userId) async {
    final response = await supabase
        .from('max_tests')
        .select('id, exercise, value, unit, recorded_at')
        .eq('trainee_id', userId)
        .order('recorded_at', ascending: false);

    final items = (response as List?)?.cast<Map<String, dynamic>>() ?? [];
    return items.map(MaxTest.fromMap).toList();
  }

  Future<void> _showAddMaxTest(String userId) async {
    final l10n = AppLocalizations.of(context)!;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _MaxTestBottomSheet(userId: userId),
    );
    if (saved == true && mounted) {
      _refreshMaxTests(userId);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.profileMaxTestsSaveSuccess)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<UserProfileData>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              final rawError = snapshot.error.toString();
              final errorText =
                  rawError.contains('user-not-found') ? l10n.userNotFound : rawError;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        l10n.profileLoadError,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        errorText,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = snapshot.data;
            if (data == null) {
              return Center(child: Text(l10n.profileNoData));
            }

            _maxTestsFuture ??= _loadMaxTests(data.userId);
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;
            final appColors = theme.extension<AppColors>()!;
            final statusChipTextStyle =
                theme.textTheme.labelMedium?.copyWith(color: colorScheme.onPrimary);
            final displayName = data.displayName(l10n);
            final emailText = data.email.isEmpty ? l10n.profileEmailUnavailable : data.email;
            final weight = data.profile?.weight;
            final weightText = weight != null
                ? l10n.profileWeightValue(weight.toStringAsFixed(1))
                : l10n.profileNotSet;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    displayName,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    emailText,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: Icon(
                          data.isActive ? Icons.check_circle : Icons.pause_circle_filled,
                          color: colorScheme.onPrimary,
                        ),
                        label: Text(
                          data.isActive ? l10n.profileStatusActive : l10n.profileStatusInactive,
                          style: statusChipTextStyle,
                        ),
                        backgroundColor:
                            data.isActive ? appColors.success : colorScheme.outlineVariant,
                      ),
                      Chip(
                        avatar: Icon(
                          data.isPayed ? Icons.workspace_premium : Icons.lock_clock,
                          color: colorScheme.onPrimary,
                        ),
                        label: Text(
                          data.isPayed ? l10n.profilePlanActive : l10n.profilePlanExpired,
                          style: statusChipTextStyle,
                        ),
                        backgroundColor:
                            data.isPayed ? colorScheme.secondary : appColors.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.badge_outlined),
                          title: Text(l10n.profileUsername),
                          subtitle: Text(data.username.isEmpty ? '-' : data.username),
                        ),
                        const Divider(height: 0),
                        ListTile(
                          leading: const Icon(Icons.monitor_weight_outlined),
                          title: Text(l10n.profileWeight),
                          subtitle: Text(weightText),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _MaxTestSection(
                    maxTestsFuture: _maxTestsFuture!,
                    onAddTest: () => _showAddMaxTest(data.userId),
                    onRefresh: () => _refreshMaxTests(data.userId),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: Text(l10n.profileEdit),
                      subtitle: Text(l10n.profileEditSubtitle),
                      onTap: () => _showEditProfile(data),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => logout(context),
                      icon: const Icon(Icons.logout),
                      label: Text(l10n.logout),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EditProfileBottomSheet extends StatefulWidget {
  const _EditProfileBottomSheet({required this.data});

  final UserProfileData data;

  @override
  State<_EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<_EditProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _weightController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.data.profile?.name ?? '');
    final weight = widget.data.profile?.weight;
    _weightController = TextEditingController(text: weight != null ? '$weight' : '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final fullName = _fullNameController.text.trim();
    final weightText = _weightController.text.trim().replaceAll(',', '.');
    final weightValue = weightText.isEmpty ? null : double.tryParse(weightText);
    final updates = <String, dynamic>{
      'name': fullName.isEmpty ? null : fullName,
      'weight': weightValue,
    };

    try {
      await supabase.from('trainees').update(updates).eq('id', widget.data.userId);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileEditError(error.toString()))),
      );
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: bottomInset + 24,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.profileEditTitle,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: l10n.profileEditFullNameLabel,
                    hintText: l10n.profileEditFullNameHint,
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.profileEditFullNameHint;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _weightController,
                  decoration: InputDecoration(
                    labelText: l10n.profileEditWeightLabel,
                    hintText: l10n.profileEditWeightHint,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true, signed: false),
                  validator: (value) {
                    final text = value?.trim();
                    if (text == null || text.isEmpty) {
                      return null;
                    }
                    final parsed = double.tryParse(text.replaceAll(',', '.'));
                    if (parsed == null || parsed <= 0) {
                      return l10n.profileEditWeightInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () {
                                Navigator.of(context).pop(false);
                              },
                        child: Text(l10n.profileEditCancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : Text(l10n.profileEditSave),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MaxTestSection extends StatelessWidget {
  const _MaxTestSection({
    required this.maxTestsFuture,
    required this.onAddTest,
    required this.onRefresh,
  });

  final Future<List<MaxTest>> maxTestsFuture;
  final VoidCallback onAddTest;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.profileMaxTestsTitle,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: onRefresh,
                  tooltip: l10n.profileMaxTestsRefresh,
                  icon: const Icon(Icons.refresh),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: onAddTest,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.profileMaxTestsAdd),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.profileMaxTestsDescription,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<MaxTest>>(
              future: maxTestsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  final errorText = snapshot.error.toString();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      l10n.profileMaxTestsError(errorText),
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                }

                final tests = snapshot.data ?? const [];
                if (tests.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.emoji_events_outlined),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.profileMaxTestsEmpty,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final bestByExercise = <String, double>{};
                for (final test in tests) {
                  final currentBest = bestByExercise[test.exercise];
                  if (currentBest == null || test.value > currentBest) {
                    bestByExercise[test.exercise] = test.value;
                  }
                }

                return Column(
                  children: [
                    for (final test in tests)
                      _MaxTestTile(
                        test: test,
                        isBest:
                            bestByExercise[test.exercise] == test.value,
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MaxTestTile extends StatelessWidget {
  const _MaxTestTile({required this.test, required this.isBest});

  final MaxTest test;
  final bool isBest;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>();
    final dateText = DateFormat.yMMMd().format(test.recordedAt);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor:
            isBest ? appColors?.success ?? Colors.green : Colors.transparent,
        foregroundColor:
            isBest ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
        child: Icon(isBest ? Icons.military_tech : Icons.timeline),
      ),
      title: Text(test.exercise),
      subtitle: Text(
        '${test.value.toStringAsFixed(test.value.truncateToDouble() == test.value ? 0 : 1)} ${test.unit}'.trim(),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.profileMaxTestsDateLabel(dateText),
            style: theme.textTheme.bodySmall,
          ),
          if (isBest)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: (appColors?.success ?? theme.colorScheme.secondary)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  l10n.profileMaxTestsBestLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: appColors?.success ?? theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MaxTestBottomSheet extends StatefulWidget {
  const _MaxTestBottomSheet({required this.userId});

  final String userId;

  @override
  State<_MaxTestBottomSheet> createState() => _MaxTestBottomSheetState();
}

class _MaxTestBottomSheetState extends State<_MaxTestBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _exerciseController = TextEditingController();
  final _valueController = TextEditingController();
  final _unitController = TextEditingController(text: 'reps');
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _exerciseController.dispose();
    _valueController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: bottomInset + 24,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.profileMaxTestsAdd,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _exerciseController,
                  decoration: InputDecoration(
                    labelText: l10n.profileMaxTestsExerciseLabel,
                    hintText: l10n.profileMaxTestsExerciseHint,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.profileMaxTestsExerciseHint;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _valueController,
                  decoration: InputDecoration(
                    labelText: l10n.profileMaxTestsValueLabel,
                    hintText: l10n.profileMaxTestsValueHint,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    final parsed =
                        double.tryParse(value?.trim().replaceAll(',', '.') ?? '');
                    if (parsed == null || parsed <= 0) {
                      return l10n.profileMaxTestsValueHint;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _unitController,
                  decoration: InputDecoration(
                    labelText: l10n.profileMaxTestsUnitLabel,
                    hintText: l10n.profileMaxTestsUnitHint,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _isSaving ? null : _pickDate,
                  icon: const Icon(Icons.event),
                  label: Text(
                    l10n.profileMaxTestsDateLabel(
                      DateFormat.yMMMd().format(_selectedDate),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            _isSaving ? null : () => Navigator.of(context).pop(false),
                        child: Text(l10n.profileMaxTestsCancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isSaving ? null : _submit,
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(l10n.profileMaxTestsSave),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final l10n = AppLocalizations.of(context)!;

    final exercise = _exerciseController.text.trim();
    final value = double.parse(_valueController.text.trim().replaceAll(',', '.'));
    final unit = _unitController.text.trim().isEmpty
        ? l10n.profileMaxTestsDefaultUnit
        : _unitController.text.trim();

    final payload = {
      'trainee_id': widget.userId,
      'exercise': exercise,
      'value': value,
      'unit': unit,
      'recorded_at': _selectedDate.toIso8601String(),
    };

    try {
      await supabase.from('max_tests').insert(payload);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileMaxTestsSaveError(error.toString()))),
      );
      setState(() => _isSaving = false);
    }
  }
}
