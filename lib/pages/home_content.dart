import 'package:calisync/model/workout_day.dart';
import 'package:calisync/pages/workout_plan_page.dart';
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
  late Future<List<WorkoutDay>> _daysFuture;

  @override
  void initState() {
    super.initState();
    _daysFuture = _loadWorkoutDays();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<WorkoutDay>>(
          future: _daysFuture,
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
                          _daysFuture = _loadWorkoutDays();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry),
                    ),
                  ),
                ],
              );
            }

            final days = snapshot.data ?? const <WorkoutDay>[];
            final workoutDates = _workoutDatesForMonth(days, DateTime.now());
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _WorkoutCalendarSection(
                  workoutDates: workoutDates,
                ),
                const SizedBox(height: 24),
                _WorkoutPlanLinkSection(
                  onOpenPlan: _openWorkoutPlan,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _daysFuture = _loadWorkoutDays();
    });
    await _daysFuture;
  }

  Future<List<WorkoutDay>> _loadWorkoutDays() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception(AppLocalizations.of(context)!.unauthenticated);
    }

    final response = await client
        .from('days')
        .select('week, day_code, plan_started_at, plan_start, starts_on, created_at')
        .eq('trainee_id', userId)
        .order('week', ascending: true)
        .order('day_code', ascending: true);

    final data = (response as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    DateTime? parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    return data.map((row) {
      final createdAt = parseDate(row['created_at']);
      final planStartedAt = parseDate(
        row['plan_started_at'] ?? row['plan_start'] ?? row['starts_on'],
      );

      return WorkoutDay(
        id: null,
        week: (row['week'] as num?)?.toInt() ?? 0,
        dayCode: (row['day_code'] as String? ?? '').trim(),
        title: null,
        notes: null,
        isCompleted: false,
        planId: null,
        planName: null,
        planStartedAt: planStartedAt,
        createdAt: createdAt,
        exercises: const [],
      );
    }).toList();
  }

  Future<void> _openWorkoutPlan() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const WorkoutPlanPage()),
    );
  }

  Set<DateTime> _workoutDatesForMonth(
    List<WorkoutDay> days,
    DateTime month,
  ) {
    final dates = <DateTime>{};
    for (final day in days) {
      final computed = _resolveWorkoutDate(day);
      if (computed == null) continue;
      if (computed.year == month.year && computed.month == month.month) {
        dates.add(_normalizeDate(computed));
      }
    }
    return dates;
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime? _resolveWorkoutDate(WorkoutDay day) {
    final planStart = day.planStartedAt;
    final createdAt = day.createdAt;
    final weekOffset = day.week > 0 ? day.week - 1 : 0;
    final dayOffset = _dayOffsetFromCode(day.dayCode);

    if (planStart != null && dayOffset != null) {
      final normalizedStart = _normalizeDate(planStart);
      return normalizedStart.add(
        Duration(days: (weekOffset * 7) + dayOffset),
      );
    }

    if (planStart != null) {
      final normalizedStart = _normalizeDate(planStart);
      return normalizedStart.add(Duration(days: weekOffset * 7));
    }

    if (createdAt != null) {
      return _normalizeDate(createdAt);
    }

    return null;
  }

  int? _dayOffsetFromCode(String code) {
    final normalized = code.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    final numeric = int.tryParse(normalized);
    if (numeric != null && numeric > 0) {
      return numeric - 1;
    }

    final letter = normalized.length == 1 ? normalized.codeUnitAt(0) : null;
    if (letter != null && letter >= 97 && letter <= 103) {
      return letter - 97;
    }

    const weekdayMap = {
      'mon': 0,
      'monday': 0,
      'lun': 0,
      'lunedi': 0,
      'lunedì': 0,
      'tue': 1,
      'tues': 1,
      'tuesday': 1,
      'mar': 1,
      'martedi': 1,
      'martedì': 1,
      'wed': 2,
      'wednesday': 2,
      'mer': 2,
      'mercoledi': 2,
      'mercoledì': 2,
      'thu': 3,
      'thur': 3,
      'thurs': 3,
      'thursday': 3,
      'gio': 3,
      'giovedi': 3,
      'giovedì': 3,
      'fri': 4,
      'friday': 4,
      'ven': 4,
      'venerdi': 4,
      'venerdì': 4,
      'sat': 5,
      'saturday': 5,
      'sab': 5,
      'sabato': 5,
      'sun': 6,
      'sunday': 6,
      'dom': 6,
      'domenica': 6,
    };

    return weekdayMap[normalized];
  }
}

class _WorkoutCalendarSection extends StatelessWidget {
  final Set<DateTime> workoutDates;

  const _WorkoutCalendarSection({
    required this.workoutDates,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final now = DateTime.now();
    final monthLabel = DateFormat.yMMMM(l10n.localeName).format(now);
    final weekdayLabels = _weekdayLabels(l10n.localeName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeCalendarTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.homeCalendarSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          monthLabel,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekdayLabels
              .map(
                (label) => Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        _CalendarGrid(
          month: now,
          workoutDates: workoutDates,
        ),
      ],
    );
  }

  List<String> _weekdayLabels(String locale) {
    final start = DateTime(2020, 1, 6);
    final formatter = DateFormat.E(locale);
    return List.generate(7, (index) {
      return formatter.format(start.add(Duration(days: index)));
    });
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime month;
  final Set<DateTime> workoutDates;

  const _CalendarGrid({
    required this.month,
    required this.workoutDates,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final year = month.year;
    final monthNumber = month.month;
    final firstDay = DateTime(year, monthNumber, 1);
    final daysInMonth = DateTime(year, monthNumber + 1, 0).day;
    final leadingEmpty = firstDay.weekday - 1;
    final totalCells = leadingEmpty + daysInMonth;
    final today = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.1,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        if (index < leadingEmpty) {
          return const SizedBox.shrink();
        }

        final dayNumber = index - leadingEmpty + 1;
        final date = DateTime(year, monthNumber, dayNumber);
        final normalized = DateTime(date.year, date.month, date.day);
        final isWorkoutDay = workoutDates.contains(normalized);
        final isToday = normalized.year == today.year &&
            normalized.month == today.month &&
            normalized.day == today.day;

        final backgroundColor = isWorkoutDay
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);
        final textColor = isWorkoutDay
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurface;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: isToday
                ? Border.all(
                    color: theme.colorScheme.primary,
                    width: 1.5,
                  )
                : null,
          ),
          child: Center(
            child: Text(
              '$dayNumber',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WorkoutPlanLinkSection extends StatelessWidget {
  final VoidCallback onOpenPlan;

  const _WorkoutPlanLinkSection({
    required this.onOpenPlan,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: Icon(
          Icons.fitness_center,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          l10n.homeWorkoutPlanTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          l10n.homeWorkoutPlanSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onOpenPlan,
      ),
    );
  }
}
