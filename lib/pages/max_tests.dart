import 'package:calisync/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_localizations.dart';
import '../model/max_test.dart';
import 'max_tests_history.dart';

final supabase = Supabase.instance.client;

class MaxTestsPage extends StatelessWidget {
  const MaxTestsPage({
    super.key,
    required this.userId,
    required this.displayName,
  });

  final String userId;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileMaxTestsTitle),
      ),
      body: MaxTestsContent(
        userId: userId,
        displayName: displayName,
      ),
    );
  }
}

class MaxTestsContent extends StatefulWidget {
  const MaxTestsContent({
    super.key,
    required this.userId,
    required this.displayName,
  });

  final String userId;
  final String displayName;

  @override
  State<MaxTestsContent> createState() => _MaxTestsContentState();
}

class _MaxTestsContentState extends State<MaxTestsContent> {
  Future<List<MaxTest>>? _maxTestsFuture;
  _MaxTestPeriod _selectedPeriod = _MaxTestPeriod.all;

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

  void _openHistoryPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MaxTestsHistoryPage(
          userId: widget.userId,
          displayName: widget.displayName,
        ),
      ),
    );
  }

  DateTime? _periodStartDate(DateTime now) {
    switch (_selectedPeriod) {
      case _MaxTestPeriod.month:
        return now.subtract(const Duration(days: 30));
      case _MaxTestPeriod.halfYear:
        return now.subtract(const Duration(days: 182));
      case _MaxTestPeriod.year:
        return now.subtract(const Duration(days: 365));
      case _MaxTestPeriod.all:
        return null;
    }
  }

  String _periodLabel(AppLocalizations l10n, _MaxTestPeriod period) {
    switch (period) {
      case _MaxTestPeriod.month:
        return l10n.profileMaxTestsPeriodMonth;
      case _MaxTestPeriod.halfYear:
        return l10n.profileMaxTestsPeriodHalfYear;
      case _MaxTestPeriod.year:
        return l10n.profileMaxTestsPeriodYear;
      case _MaxTestPeriod.all:
        return l10n.profileMaxTestsPeriodAll;
    }
  }

  List<MaxTest> _buildProgression(List<MaxTest> tests) {
    final sorted = [...tests]
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    final progression = <MaxTest>[];
    double? currentBest;
    for (final test in sorted) {
      if (currentBest == null || test.value > currentBest) {
        progression.add(test);
        currentBest = test.value;
      }
    }
    return progression;
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
    final now = DateTime.now();
    final periodStart = _periodStartDate(now);

    return Scaffold(
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
                        IconButton(
                          onPressed: _openHistoryPage,
                          tooltip: l10n.profileMaxTestsHistoryAction,
                          icon: const Icon(Icons.timeline_outlined),
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
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          l10n.profileMaxTestsPeriodLabel,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<_MaxTestPeriod>(
                          value: _selectedPeriod,
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _selectedPeriod = value);
                          },
                          items: _MaxTestPeriod.values
                              .map(
                                (period) => DropdownMenuItem<_MaxTestPeriod>(
                                  value: period,
                                  child: Text(_periodLabel(l10n, period)),
                                ),
                              )
                              .toList(),
                        ),
                      ],
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

                          final filteredTests =
                              periodStart == null
                                  ? tests
                                  : tests
                                      .where(
                                        (test) => !test.recordedAt.isBefore(
                                          periodStart,
                                        ),
                                      )
                                      .toList();

                          if (filteredTests.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  l10n.profileMaxTestsEmptyPeriod(
                                    _periodLabel(l10n, _selectedPeriod),
                                  ),
                                  style: theme.textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }

                          final groupedTests = <String, List<MaxTest>>{};
                          final displayNames = <String, String>{};
                          for (final test in filteredTests) {
                            final displayName = test.exercise.trim();
                            final key = displayName.toLowerCase();
                            groupedTests.putIfAbsent(key, () => []).add(test);
                            displayNames.putIfAbsent(key, () => displayName);
                          }

                          return ListView.separated(
                            itemCount: groupedTests.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final entry = groupedTests.entries.elementAt(index);
                              final exerciseKey = entry.key;
                              final groupTests = entry.value;
                              final isAllPeriod = _selectedPeriod == _MaxTestPeriod.all;
                              final displayTests = isAllPeriod
                                  ? _buildProgression(groupTests)
                                  : [
                                      groupTests.reduce(
                                        (a, b) => a.value >= b.value ? a : b,
                                      ),
                                    ];
                              final bestValue =
                                  displayTests.isEmpty
                                      ? 0
                                      : displayTests
                                          .map((test) => test.value)
                                          .reduce((a, b) => a > b ? a : b);
                              final exercise =
                                  displayNames[exerciseKey] ??
                                  groupTests.first.exercise.trim();

                              return _ExerciseGroupCard(
                                exercise: exercise,
                                tests: displayTests,
                                bestValue: bestValue,
                                summaryLabel: isAllPeriod
                                    ? l10n.profileMaxTestsBestLabel
                                    : l10n.profileMaxTestsBestPeriodLabel,
                                badgeLabel: isAllPeriod
                                    ? l10n.profileMaxTestsBestLabel
                                    : l10n.profileMaxTestsBestPeriodLabel,
                                enableToggle: isAllPeriod,
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

class _ExerciseGroupCard extends StatefulWidget {
  const _ExerciseGroupCard({
    required this.exercise,
    required this.tests,
    required this.bestValue,
    required this.summaryLabel,
    required this.badgeLabel,
    required this.enableToggle,
  });

  final String exercise;
  final List<MaxTest> tests;
  final double bestValue;
  final String summaryLabel;
  final String badgeLabel;
  final bool enableToggle;

  @override
  State<_ExerciseGroupCard> createState() => _ExerciseGroupCardState();
}

class _ExerciseGroupCardState extends State<_ExerciseGroupCard> {
  static const int _collapsedCount = 3;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final tests = widget.tests;
    final showToggle = widget.enableToggle && tests.length > _collapsedCount;
    final visibleTests =
        _isExpanded ? tests : tests.take(_collapsedCount).toList();

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
              widget.exercise,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            for (final test in visibleTests)
              _MaxTestTile(
                test: test,
                isBest: test.value == widget.bestValue,
                badgeLabel: widget.badgeLabel,
              ),
            if (showToggle)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  child: Text(
                    _isExpanded
                        ? l10n.profileMaxTestsShowLess
                        : l10n.profileMaxTestsShowMore,
                  ),
                ),
              ),
            if (tests.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${widget.summaryLabel}: '
                  '${widget.bestValue.toStringAsFixed(widget.bestValue.truncateToDouble() == widget.bestValue ? 0 : 1)} '
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
  const _MaxTestTile({
    required this.test,
    required this.isBest,
    required this.badgeLabel,
  });

  final MaxTest test;
  final bool isBest;
  final String badgeLabel;

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
                badgeLabel,
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

enum _MaxTestPeriod { month, halfYear, year, all }

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
