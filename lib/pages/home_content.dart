import 'package:calisync/components/cards/selection_card.dart';
import 'package:calisync/model/workout_day.dart';
import 'package:calisync/model/workout_plan.dart';
import 'package:calisync/pages/emom_tracker.dart';
import 'package:calisync/pages/exercise_tracker.dart';
import 'package:calisync/pages/training.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_localizations.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late Future<_HomeData> _homeDataFuture;

  @override
  void initState() {
    super.initState();
    _homeDataFuture = _loadHomeData();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final extraTools = [
      SelectionCard(
        title: l10n.exerciseTrackerTitle,
        icon: Icons.checklist,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ExerciseTrackerPage(),
            ),
          );
        },
      ),
      SelectionCard(
        title: l10n.emomTrackerTitle,
        subtitle: l10n.emomTrackerSubtitle,
        icon: Icons.timer,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EmomTrackerPage(),
            ),
          );
        },
      ),
    ];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<_HomeData>(
          future: _homeDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 32),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 32),
                  Icon(
                    Icons.error_outline,
                    size: 56,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.homeLoadErrorTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: FilledButton.icon(
                      onPressed: () {
                        setState(() {
                          _homeDataFuture = _loadHomeData();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry),
                    ),
                  ),
                ],
              );
            }

            final homeData = snapshot.data ?? const _HomeData.empty();
            final days = homeData.days;
            final plans = homeData.plans;
            final planOverview = _WorkoutPlanOverview(
              plans: plans,
              onRefresh: _refresh,
            );
            if (days.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 32),
                  Icon(
                    Icons.fitness_center,
                    size: 56,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.homeEmptyTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.homeEmptyDescription,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  planOverview,
                  const SizedBox(height: 24),
                  ...extraTools,
                ],
              );
            }

            final planGroups = _buildPlanGroups(days, l10n);
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                planOverview,
                const SizedBox(height: 16),
                ...planGroups
                    .asMap()
                    .entries
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _WorkoutPlanSection(
                          plan: entry.value,
                          isLatest: entry.key == 0,
                          onOpenDay: _openDay,
                        ),
                      ),
                    ),
                const SizedBox(height: 8),
                ...extraTools,
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _homeDataFuture = _loadHomeData();
    });
    await _homeDataFuture;
  }

  Future<_HomeData> _loadHomeData() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception(AppLocalizations.of(context)!.unauthenticated);
    }

    final results = await Future.wait([
      _loadWorkoutPlans(client, userId),
      _loadWorkoutDays(client, userId),
    ]);

    return _HomeData(
      plans: results[0] as List<WorkoutPlan>,
      days: results[1] as List<WorkoutDay>,
    );
  }

  Future<List<WorkoutPlan>> _loadWorkoutPlans(
    SupabaseClient client,
    String userId,
  ) async {
    final response = await client
        .from('workout_plans')
        .select()
        .eq('trainee_id', userId)
        .order('starts_on', ascending: false)
        .order('created_at', ascending: false);

    final data = (response as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    return data
        .map(WorkoutPlan.fromJson)
        .toList()
      ..sort((a, b) {
        final aDate = a.startsOn ?? a.createdAt;
        final bDate = b.startsOn ?? b.createdAt;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });
  }

  Future<List<WorkoutDay>> _loadWorkoutDays(
    SupabaseClient client,
    String userId,
  ) async {
    final response = await client
        .from('days')
        .select(
            '*, day_exercises ( id, position, notes, completed, trainee_notes, exercises ( id, name ) )')
        .eq('trainee_id', userId)
        .order('week', ascending: true)
        .order('day_code', ascending: true)
        .order('position', referencedTable: 'day_exercises', ascending: true);

    final data = (response as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    DateTime? _parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    return data.map((row) {
      final dayExercises =
          (row['day_exercises'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

      final createdAt = _parseDate(row['created_at']);
      final planStartedAt = _parseDate(
        row['plan_started_at'] ?? row['plan_start'] ?? row['starts_on'],
      );
      final planId = row['plan_id'] as String? ??
          row['workout_plan_id'] as String? ??
          row['program_id'] as String?;
      final planName =
          row['plan_name'] as String? ?? row['workout_plan_name'] as String?;

      final exercises = dayExercises.map((exercise) {
        final exerciseDetails =
            (exercise['exercises'] as Map<String, dynamic>?) ?? {};
        return WorkoutExercise(
          id: exercise['id'] as String?,
          name: exerciseDetails['name'] as String?,
          position: (exercise['position'] as num?)?.toInt(),
          notes: exercise['notes'] as String?,
          traineeNotes: exercise['trainee_notes'] as String?,
          isCompleted: exercise['completed'] as bool? ?? false,
        );
      }).toList();

      return WorkoutDay(
        id: row['id'] as String?,
        week: (row['week'] as num?)?.toInt() ?? 0,
        dayCode: (row['day_code'] as String? ?? '').trim(),
        title: row['title'] as String?,
        notes: row['notes'] as String?,
        isCompleted: row['completed'] as bool? ?? false,
        planId: planId,
        planName: planName ,
        planStartedAt: planStartedAt,
        createdAt: createdAt,
        exercises: exercises,
      );
    }).toList();
  }

  List<_WorkoutPlanGroup> _buildPlanGroups(
    List<WorkoutDay> days,
    AppLocalizations l10n,
  ) {
    String planKey(WorkoutDay day) {
      if (day.planId != null && day.planId!.isNotEmpty) return day.planId!;
      if (day.planName != null && day.planName!.isNotEmpty) return day.planName!;
      if (day.planStartedAt != null) return 'start-${day.planStartedAt!.toIso8601String()}';
      if (day.createdAt != null) return 'created-${day.createdAt!.toIso8601String()}';
      return 'plan';
    }

    final Map<String, List<WorkoutDay>> grouped = {};
    for (final day in days) {
      grouped.putIfAbsent(planKey(day), () => []).add(day);
    }

    DateTime? earliestDate(Iterable<WorkoutDay> entries) {
      return entries
          .map((day) => day.planStartedAt ?? day.createdAt)
          .whereType<DateTime>()
          .fold<DateTime?>(null, (previous, element) {
        if (previous == null) return element;
        return element.isBefore(previous) ? element : previous;
      });
    }

    DateTime? latestDate(Iterable<WorkoutDay> entries) {
      return entries
          .map((day) => day.planStartedAt ?? day.createdAt)
          .whereType<DateTime>()
          .fold<DateTime?>(null, (previous, element) {
        if (previous == null) return element;
        return element.isAfter(previous) ? element : previous;
      });
    }

    final plans = grouped.entries.map((entry) {
      final planDays = [...entry.value]
        ..sort((a, b) {
          if (a.isCompleted != b.isCompleted) {
            return a.isCompleted ? 1 : -1;
          }
          if (a.week != b.week) return a.week.compareTo(b.week);
          return a.dayCode.compareTo(b.dayCode);
        });

      final first = planDays.first;
      final planTitle = first.planName?.trim().isNotEmpty == true
          ? first.planName!.trim()
          : l10n.homePlanDefaultTitle;

      return _WorkoutPlanGroup(
        id: entry.key,
        title: planTitle,
        startedAt: earliestDate(planDays),
        latestDate: latestDate(planDays),
        days: planDays,
      );
    }).toList();

    plans.sort((a, b) {
      final aDate = a.latestDate;
      final bDate = b.latestDate;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });

    return plans;
  }

  Future<void> _openDay(WorkoutDay day) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Training(day: day),
      ),
    ).then((updated) {
      if (updated == true) {
        _refresh();
      }
    });
  }
}

class _HomeData {
  final List<WorkoutPlan> plans;
  final List<WorkoutDay> days;

  const _HomeData({
    required this.plans,
    required this.days,
  });

  const _HomeData.empty()
      : plans = const [],
        days = const [];
}

class _WorkoutPlanOverview extends StatelessWidget {
  final List<WorkoutPlan> plans;
  final Future<void> Function() onRefresh;

  const _WorkoutPlanOverview({
    required this.plans,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd(l10n.localeName);

    final planCards = plans.map(
      (plan) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _WorkoutPlanCard(
          plan: plan,
          dateFormat: dateFormat,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.homePlansSectionTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.homePlansSectionSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRefresh,
              tooltip: l10n.retry,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (plans.isEmpty)
          Card(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.7),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.assignment,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.homePlansEmptyTitle,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.homePlansEmptyDescription,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...planCards,
      ],
    );
  }
}

class _WorkoutPlanCard extends StatelessWidget {
  final WorkoutPlan plan;
  final DateFormat dateFormat;

  const _WorkoutPlanCard({
    required this.plan,
    required this.dateFormat,
  });

  String _statusLabel(AppLocalizations l10n) {
    final normalized = plan.status?.trim().toLowerCase();
    switch (normalized) {
      case 'active':
        return l10n.profilePlanActive;
      case 'expired':
        return l10n.profilePlanExpired;
      case 'archived':
        return l10n.homePlanStatusArchived;
      case 'draft':
        return l10n.homePlanStatusDraft;
      case 'upcoming':
        return l10n.homePlanStatusUpcoming;
      default:
        return normalized != null && normalized.isNotEmpty
            ? normalized[0].toUpperCase() + normalized.substring(1)
            : l10n.homePlanStatusUnknown;
    }
  }

  Color _statusColor(ThemeData theme) {
    final normalized = plan.status?.trim().toLowerCase();
    switch (normalized) {
      case 'active':
        return theme.colorScheme.primary;
      case 'expired':
      case 'archived':
        return theme.colorScheme.error;
      case 'upcoming':
        return theme.colorScheme.tertiary;
      default:
        return theme.colorScheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final title = plan.name.isNotEmpty
        ? plan.name
        : l10n.homePlanDefaultTitle;
    final dateRange = plan.dateRangeLabel(dateFormat);
    final subtitleParts = <String>[];
    if (dateRange != null) {
      subtitleParts.add(dateRange);
    }
    if ((plan.notes ?? '').trim().isNotEmpty) {
      subtitleParts.add((plan.notes ?? '').trim());
    }
    return SelectionCard(
      title: title,
      subtitle: subtitleParts.isEmpty ? null : subtitleParts.join(' • '),
      icon: Icons.assignment,
      trailing: Chip(
        label: Text(_statusLabel(l10n)),
        backgroundColor: _statusColor(theme).withOpacity(0.15),
        labelStyle: TextStyle(
          color: _statusColor(theme),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _WorkoutPlanGroup {
  final String id;
  final String title;
  final DateTime? startedAt;
  final DateTime? latestDate;
  final List<WorkoutDay> days;

  const _WorkoutPlanGroup({
    required this.id,
    required this.title,
    required this.days,
    this.startedAt,
    this.latestDate,
  });
}

class _WorkoutPlanSection extends StatelessWidget {
  final _WorkoutPlanGroup plan;
  final bool isLatest;
  final ValueChanged<WorkoutDay> onOpenDay;

  const _WorkoutPlanSection({
    required this.plan,
    required this.isLatest,
    required this.onOpenDay,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final dateFormat = DateFormat.yMMMMd(l10n.localeName);
    final startedLabel = plan.startedAt != null
        ? l10n.homePlanStartedLabel(dateFormat.format(plan.startedAt!))
        : null;

    return Card(
      color: isLatest ? theme.colorScheme.primaryContainer.withOpacity(0.25) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isLatest
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: 1.25,
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: isLatest,
        tilePadding: const EdgeInsets.all(16),
        trailing: isLatest
            ? Chip(
                label: Text(l10n.homePlanLatestLabel),
                backgroundColor: theme.colorScheme.primary,
                labelStyle: TextStyle(color: theme.colorScheme.onPrimary),
              )
            : null,
        title: Text(
          plan.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: startedLabel != null
            ? Text(
                startedLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          ...plan.days.map(
            (day) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _WorkoutDayTile(
                day: day,
                onTap: () => onOpenDay(day),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutDayTile extends StatelessWidget {
  final WorkoutDay day;
  final VoidCallback onTap;

  const _WorkoutDayTile({
    required this.day,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isCompleted = day.isCompleted;

    return SelectionCard(
      title: day.formattedTitle(l10n),
      icon: Icons.calendar_today,
      iconColor: isCompleted
          ? theme.colorScheme.secondary
          : theme.colorScheme.primary,
      tileColor: isCompleted ? theme.colorScheme.surfaceVariant : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCompleted)
            Icon(Icons.check_circle,
                color: theme.colorScheme.secondary),
          if (isCompleted)
            const SizedBox(width: 6),
          const Icon(Icons.arrow_forward_ios),
        ],
      ),
      onTap: onTap,
    );
  }
}
