import 'package:calisync/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_localizations.dart';
import '../model/max_test.dart';

final supabase = Supabase.instance.client;

class MaxTestsPage extends StatefulWidget {
  const MaxTestsPage({
    super.key,
    required this.userId,
    required this.displayName,
  });

  final String userId;
  final String displayName;

  @override
  State<MaxTestsPage> createState() => _MaxTestsPageState();
}

class _MaxTestsPageState extends State<MaxTestsPage> {
  Future<List<MaxTest>>? _maxTestsFuture;

  @override
  void initState() {
    super.initState();
    _refreshMaxTests();
  }

  void _refreshMaxTests() {
    setState(() {
      _maxTestsFuture = _loadMaxTests(widget.userId);
    });
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

  Future<void> _showAddMaxTest() async {
    final l10n = AppLocalizations.of(context)!;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _MaxTestBottomSheet(userId: widget.userId),
    );
    if (saved == true && mounted) {
      _refreshMaxTests();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.profileMaxTestsSaveSuccess)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileMaxTestsTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.cardColor.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.06),
                  offset: const Offset(0, 12),
                  blurRadius: 24,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.displayName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _refreshMaxTests,
                          tooltip: l10n.profileMaxTestsRefresh,
                          icon: const Icon(Icons.refresh),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonalIcon(
                          onPressed: _showAddMaxTest,
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
                    const SizedBox(height: 16),
                    Expanded(
                      child: FutureBuilder<List<MaxTest>>(
                        future: _maxTestsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            final errorText = snapshot.error.toString();
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  l10n.profileMaxTestsError(errorText),
                                  style: theme.textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }

                          final tests = snapshot.data ?? const [];
                          if (tests.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.emoji_events_outlined),
                                    const SizedBox(width: 12),
                                    Flexible(
                                      child: Text(
                                        l10n.profileMaxTestsEmpty,
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          final groupedTests = <String, List<MaxTest>>{};
                          for (final test in tests) {
                            final key = test.exercise.trim();
                            groupedTests.putIfAbsent(key, () => []).add(test);
                          }

                          final bestByExercise = <String, double>{};
                          for (final entry in groupedTests.entries) {
                            final best = entry.value
                                .map((test) => test.value)
                                .reduce((a, b) => a > b ? a : b);
                            bestByExercise[entry.key] = best;
                          }

                          return ListView.separated(
                            itemCount: groupedTests.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final entry = groupedTests.entries.elementAt(index);
                              final exercise = entry.key;
                              final groupTests = entry.value;

                              return _ExerciseGroupCard(
                                exercise: exercise,
                                tests: groupTests,
                                bestValue: bestByExercise[exercise] ?? 0,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseGroupCard extends StatelessWidget {
  const _ExerciseGroupCard({
    required this.exercise,
    required this.tests,
    required this.bestValue,
  });

  final String exercise;
  final List<MaxTest> tests;
  final double bestValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            for (final test in tests)
              _MaxTestTile(
                test: test,
                isBest: test.value == bestValue,
              ),
            if (tests.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${l10n.profileMaxTestsBestLabel}: '
                  '${bestValue.toStringAsFixed(bestValue.truncateToDouble() == bestValue ? 0 : 1)} '
                  '${tests.first.unit}'.trim(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
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
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor:
            isBest ? appColors?.success ?? Colors.green : Colors.transparent,
        foregroundColor:
            isBest ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
        child: Icon(isBest ? Icons.military_tech : Icons.timeline),
      ),
      title: Text(
        '${test.value.toStringAsFixed(test.value.truncateToDouble() == test.value ? 0 : 1)} '
        '${test.unit}'.trim(),
      ),
      subtitle: Text(l10n.profileMaxTestsDateLabel(dateText)),
      trailing: isBest
          ? Container(
              decoration: BoxDecoration(
                color: (appColors?.success ?? theme.colorScheme.secondary)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                l10n.profileMaxTestsBestLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: appColors?.success ?? theme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
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
