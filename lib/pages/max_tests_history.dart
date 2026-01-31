import 'package:calisync/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/exercise_guides.dart';
import '../l10n/app_localizations.dart';
import '../model/exercise_guide.dart';
import '../model/max_test.dart';

final supabase = Supabase.instance.client;

class MaxTestsHistoryPage extends StatefulWidget {
  const MaxTestsHistoryPage({
    super.key,
    required this.userId,
    required this.displayName,
  });

  final String userId;
  final String displayName;

  @override
  State<MaxTestsHistoryPage> createState() => _MaxTestsHistoryPageState();
}

class _MaxTestsHistoryPageState extends State<MaxTestsHistoryPage> {
  Future<List<MaxTest>>? _maxTestsFuture;
  Future<List<ExerciseGuide>>? _guidesFuture;
  String? _localeName;

  @override
  void initState() {
    super.initState();
    _refreshMaxTests();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    if (_guidesFuture == null || _localeName != l10n.localeName) {
      _localeName = l10n.localeName;
      _guidesFuture = ExerciseGuides.load(l10n.localeName);
    }
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
        .order('recorded_at', ascending: true);

    final items = (response as List?)?.cast<Map<String, dynamic>>() ?? [];
    return items.map(MaxTest.fromMap).toList();
  }

  String _resolveExerciseKey(
    String exercise,
    Map<String, ExerciseGuide> guidesById,
    Map<String, ExerciseGuide> guidesByName,
  ) {
    final trimmed = exercise.trim();
    if (guidesById.containsKey(trimmed)) {
      return trimmed;
    }
    final nameMatch = guidesByName[trimmed.toLowerCase()];
    return nameMatch?.id ?? trimmed.toLowerCase();
  }

  String _resolveExerciseLabel(
    String exercise,
    Map<String, ExerciseGuide> guidesById,
    Map<String, ExerciseGuide> guidesByName,
  ) {
    final trimmed = exercise.trim();
    final guide = guidesById[trimmed] ?? guidesByName[trimmed.toLowerCase()];
    return guide?.name ?? trimmed;
  }

  String _formatValue(MaxTest test) {
    final value = test.value;
    final formatted = value.toStringAsFixed(
      value.truncateToDouble() == value ? 0 : 1,
    );
    return '$formatted ${test.unit}'.trim();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<List<ExerciseGuide>>(
      future: _guidesFuture,
      builder: (context, snapshot) {
        final exerciseGuides =
            List<ExerciseGuide>.from(snapshot.data ?? const <ExerciseGuide>[])
              ..sort((a, b) => a.name.compareTo(b.name));
        final exerciseGuideById = {
          for (final guide in exerciseGuides) guide.id: guide,
        };
        final exerciseGuideByName = {
          for (final guide in exerciseGuides)
            guide.name.trim().toLowerCase(): guide,
        };
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.profileMaxTestsHistoryTitle),
            actions: [
              IconButton(
                onPressed: _refreshMaxTests,
                tooltip: l10n.profileMaxTestsRefresh,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.profileMaxTestsHistoryDescription,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: FutureBuilder<List<MaxTest>>(
                      future: _maxTestsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          final errorText = snapshot.error.toString();
                          return Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                l10n.profileMaxTestsHistoryError(errorText),
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }

                        final tests = snapshot.data ?? const [];
                        if (tests.isEmpty) {
                          return Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                l10n.profileMaxTestsHistoryEmpty,
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }

                        final groupedTests = <String, List<MaxTest>>{};
                        final displayNames = <String, String>{};
                        for (final test in tests) {
                          final displayName = _resolveExerciseLabel(
                            test.exercise,
                            exerciseGuideById,
                            exerciseGuideByName,
                          );
                          final unitLabel = test.unit.trim();
                          final displayLabel = unitLabel.isEmpty
                              ? displayName
                              : '$displayName ($unitLabel)';
                          final key = _resolveExerciseKey(
                            test.exercise,
                            exerciseGuideById,
                            exerciseGuideByName,
                          );
                          final groupedKey = '$key|$unitLabel';
                          groupedTests
                              .putIfAbsent(groupedKey, () => [])
                              .add(test);
                          displayNames.putIfAbsent(
                            groupedKey,
                            () => displayLabel,
                          );
                        }

                        return ListView.separated(
                          itemCount: groupedTests.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final entry = groupedTests.entries.elementAt(index);
                            final exerciseKey = entry.key;
                            final groupTests = entry.value
                              ..sort(
                                (a, b) => a.recordedAt.compareTo(b.recordedAt),
                              );
                            final exercise =
                                displayNames[exerciseKey] ??
                                groupTests.first.exercise.trim();

                            return _MaxTestHistoryCard(
                              exercise: exercise,
                              tests: groupTests,
                              formatValue: _formatValue,
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
        );
      },
    );
  }
}

class _MaxTestHistoryCard extends StatelessWidget {
  const _MaxTestHistoryCard({
    required this.exercise,
    required this.tests,
    required this.formatValue,
  });

  final String exercise;
  final List<MaxTest> tests;
  final String Function(MaxTest) formatValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
            for (var index = 0; index < tests.length; index++)
              _MaxTestHistoryTile(
                test: tests[index],
                previousTest: index > 0 ? tests[index - 1] : null,
                formatValue: formatValue,
              ),
          ],
        ),
      ),
    );
  }
}

class _MaxTestHistoryTile extends StatelessWidget {
  const _MaxTestHistoryTile({
    required this.test,
    required this.previousTest,
    required this.formatValue,
  });

  final MaxTest test;
  final MaxTest? previousTest;
  final String Function(MaxTest) formatValue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>();
    final dateText = DateFormat.yMMMd().format(test.recordedAt);
    final delta = previousTest == null ? null : test.value - previousTest!.value;
    final deltaText = delta == null
        ? l10n.profileMaxTestsHistoryFirstEntry
        : l10n.profileMaxTestsHistoryDeltaLabel(
            '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(delta.truncateToDouble() == delta ? 0 : 1)} ${test.unit}'.trim(),
          );

    final iconData = delta == null
        ? Icons.flag_outlined
        : delta > 0
            ? Icons.trending_up
            : delta < 0
                ? Icons.trending_down
                : Icons.trending_flat;
    final highlightColor = delta == null
        ? theme.colorScheme.primary
        : delta > 0
            ? appColors?.success ?? theme.colorScheme.secondary
            : delta < 0
                ? appColors?.warning ?? theme.colorScheme.error
                : theme.colorScheme.outline;

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: highlightColor.withValues(alpha: 0.15),
        foregroundColor: highlightColor,
        child: Icon(iconData),
      ),
      title: Text(formatValue(test)),
      subtitle: Text(
        '${l10n.profileMaxTestsDateLabel(dateText)} • $deltaText',
        style: theme.textTheme.bodySmall,
      ),
    );
  }
}
