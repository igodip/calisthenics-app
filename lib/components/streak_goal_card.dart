import 'package:calisync/components/section_card.dart';
import 'package:calisync/model/daily_streak_goal.dart';
import 'package:flutter/material.dart';

class StreakGoalCard extends StatelessWidget {
  const StreakGoalCard({
    super.key,
    required this.goal,
    required this.onCreateGoal,
    required this.onEditGoal,
    required this.onDeleteGoal,
    required this.onAddProgress,
  });

  final DailyStreakGoal? goal;
  final VoidCallback onCreateGoal;
  final VoidCallback onEditGoal;
  final VoidCallback onDeleteGoal;
  final VoidCallback onAddProgress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (goal == null) {
      return SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_fire_department_outlined,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Daily streak',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Set one daily target first, then the app can remind you before you lose the streak.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onCreateGoal,
              icon: const Icon(Icons.add),
              label: const Text('Create streak goal'),
            ),
          ],
        ),
      );
    }

    final now = DateTime.now();
    final completedToday = goal!.completedToday(now);
    final lastSevenDays = List<DateTime>.generate(
      7,
      (index) =>
          DailyStreakGoal.startOfDay(now.subtract(Duration(days: 6 - index))),
    );
    final completedDays = lastSevenDays
        .where((day) => goal!.entryForDate(day)?.completedTarget ?? false)
        .length;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily streak',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${goal!.targetCount} ${goal!.title} daily',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEditGoal();
                  } else if (value == 'delete') {
                    onDeleteGoal();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit goal')),
                  PopupMenuItem(value: 'delete', child: Text('Delete goal')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 320;
              final iconSize = compact ? 18.0 : 24.0;
              final todayIconSize = compact ? 22.0 : 28.0;
              final daySpacing = compact ? 2.0 : 4.0;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: lastSevenDays.map((day) {
                  final completed =
                      goal!.entryForDate(day)?.completedTarget ?? false;
                  final isToday = DateUtils.isSameDay(day, now);
                  return Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        children: [
                          Icon(
                            completed
                                ? Icons.local_fire_department
                                : Icons.local_fire_department_outlined,
                            color: completed
                                ? const Color(0xFFFF7A1A)
                                : colorScheme.outline,
                            size: isToday ? todayIconSize : iconSize,
                          ),
                          SizedBox(height: daySpacing),
                          Text(
                            _weekdayLabel(day.weekday),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isToday
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                              fontWeight:
                                  isToday ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            '$completedDays/7 flames lit this week${completedToday ? " · today done" : ""}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onAddProgress,
                  icon: const Icon(Icons.add_task),
                  label: Text(completedToday ? 'Add progress' : 'Log today'),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: onEditGoal,
                icon: const Icon(Icons.schedule),
                label: const Text('Edit'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'M';
      case DateTime.tuesday:
        return 'T';
      case DateTime.wednesday:
        return 'W';
      case DateTime.thursday:
        return 'T';
      case DateTime.friday:
        return 'F';
      case DateTime.saturday:
        return 'S';
      case DateTime.sunday:
        return 'S';
      default:
        return '';
    }
  }
}
