import 'package:calisync/components/section_card.dart';
import 'package:calisync/model/daily_streak_goal.dart';
import 'package:calisync/services/streak_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StreakHistoryPage extends StatefulWidget {
  const StreakHistoryPage({super.key});

  @override
  State<StreakHistoryPage> createState() => _StreakHistoryPageState();
}

class _StreakHistoryPageState extends State<StreakHistoryPage> {
  late Future<DailyStreakGoal?> _goalFuture;
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    _goalFuture = StreakService.instance.loadGoal();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  Future<void> _refresh() async {
    setState(() {
      _goalFuture = StreakService.instance.loadGoal();
    });
    await _goalFuture;
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final monthFormatter = DateFormat.yMMMM(locale);
    final fullDateFormatter = DateFormat.yMMMd(locale);

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<DailyStreakGoal?>(
          future: _goalFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final goal = snapshot.data;
            if (goal == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Create a daily streak first to unlock the calendar.',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final streakEntries = _currentStreakEntries(goal);
            final totalDuringStreak = streakEntries.fold<int>(
              0,
              (sum, entry) => sum + entry.totalCount,
            );
            final streakStartedAt = streakEntries.isEmpty
                ? null
                : streakEntries.first.date;
            final monthEntries = {
              for (final entry in goal.entries) _dateKey(entry.date): entry,
            };

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                children: [
                  SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current streak summary',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${goal.targetCount} ${goal.title} every day',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryTile(
                                label: 'Active streak',
                                value: '${goal.currentStreak} days',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SummaryTile(
                                label: 'Total ${goal.title}',
                                value: totalDuringStreak.toString(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryTile(
                                label: 'Tracked days',
                                value: streakEntries.length.toString(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SummaryTile(
                                label: 'Started',
                                value: streakStartedAt == null
                                    ? '-'
                                    : fullDateFormatter.format(streakStartedAt),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                monthFormatter.format(_visibleMonth),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _changeMonth(-1),
                              icon: const Icon(Icons.chevron_left),
                            ),
                            IconButton(
                              onPressed: () => _changeMonth(1),
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const _WeekdayHeader(),
                        const SizedBox(height: 8),
                        _CalendarGrid(
                          month: _visibleMonth,
                          entriesByDateKey: monthEntries,
                          targetCount: goal.targetCount,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Green days hit the target. Amber days were logged but did not complete the goal.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
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

  List<DailyStreakEntry> _currentStreakEntries(DailyStreakGoal goal) {
    if (goal.currentStreak <= 0 || goal.lastCompletionDate == null) {
      return const [];
    }

    final entriesByDate = {
      for (final entry in goal.entries) _dateKey(entry.date): entry,
    };
    final results = <DailyStreakEntry>[];
    var cursor = DailyStreakGoal.startOfDay(goal.lastCompletionDate!);

    for (var index = 0; index < goal.currentStreak; index++) {
      final entry = entriesByDate[_dateKey(cursor)];
      if (entry == null || !entry.completedTarget) {
        break;
      }
      results.add(entry);
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return results.reversed.toList();
  }

  String _dateKey(DateTime date) {
    final normalized = DailyStreakGoal.startOfDay(date);
    return '${normalized.year}-${normalized.month}-${normalized.day}';
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      children: labels
          .map(
            (label) => Expanded(
              child: Center(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.month,
    required this.entriesByDateKey,
    required this.targetCount,
  });

  final DateTime month;
  final Map<String, DailyStreakEntry> entriesByDateKey;
  final int targetCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.colorScheme;
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstDay = DateTime(month.year, month.month, 1);
    final leadingEmptyDays = (firstDay.weekday + 6) % 7;
    final tiles = <Widget>[];

    for (var index = 0; index < leadingEmptyDays; index++) {
      tiles.add(const SizedBox.shrink());
    }

    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final entry = entriesByDateKey[_dateKey(date)];
      final isToday = DateUtils.isSameDay(date, DateTime.now());
      final hasEntry = entry != null;
      final completedTarget = entry?.completedTarget ?? false;

      tiles.add(
        Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          decoration: BoxDecoration(
            color: !hasEntry
                ? theme.colorScheme.surface.withValues(alpha: 0.18)
                : completedTarget
                ? const Color(0x336C9C48)
                : const Color(0x33FFA726),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isToday
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
              width: isToday ? 1.4 : 1,
            ),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$day',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (hasEntry)
                    Text(
                      '${entry.totalCount}/$targetCount',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: completedTarget
                            ? const Color(0xFF6C9C48)
                            : const Color(0xFFFFA726),
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    )
                  else
                    Icon(
                      Icons.remove,
                      size: 12,
                      color: appColors.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      crossAxisSpacing: 0,
      mainAxisSpacing: 0,
      childAspectRatio: 0.9,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: tiles,
    );
  }

  String _dateKey(DateTime date) {
    final normalized = DailyStreakGoal.startOfDay(date);
    return '${normalized.year}-${normalized.month}-${normalized.day}';
  }
}
