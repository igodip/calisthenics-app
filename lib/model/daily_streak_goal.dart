class DailyStreakEntry {
  const DailyStreakEntry({
    required this.date,
    required this.totalCount,
    required this.completedTarget,
  });

  final DateTime date;
  final int totalCount;
  final bool completedTarget;

  DailyStreakEntry copyWith({
    DateTime? date,
    int? totalCount,
    bool? completedTarget,
  }) {
    return DailyStreakEntry(
      date: date ?? this.date,
      totalCount: totalCount ?? this.totalCount,
      completedTarget: completedTarget ?? this.completedTarget,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'total_count': totalCount,
      'completed_target': completedTarget,
    };
  }

  factory DailyStreakEntry.fromJson(Map<String, dynamic> json) {
    return DailyStreakEntry(
      date: DailyStreakGoal.startOfDay(
        DateTime.tryParse(json['date'] as String? ?? '')?.toLocal() ??
            DateTime.now(),
      ),
      totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
      completedTarget: json['completed_target'] as bool? ?? false,
    );
  }
}

class DailyStreakGoal {
  const DailyStreakGoal({
    required this.title,
    required this.targetCount,
    required this.reminderHour,
    required this.reminderMinute,
    required this.currentStreak,
    required this.bestStreak,
    required this.todayProgress,
    this.entries = const [],
    this.lastProgressDate,
    this.lastCompletionDate,
  });

  final String title;
  final int targetCount;
  final int reminderHour;
  final int reminderMinute;
  final int currentStreak;
  final int bestStreak;
  final int todayProgress;
  final List<DailyStreakEntry> entries;
  final DateTime? lastProgressDate;
  final DateTime? lastCompletionDate;

  DailyStreakGoal copyWith({
    String? title,
    int? targetCount,
    int? reminderHour,
    int? reminderMinute,
    int? currentStreak,
    int? bestStreak,
    int? todayProgress,
    List<DailyStreakEntry>? entries,
    DateTime? lastProgressDate,
    bool clearLastProgressDate = false,
    DateTime? lastCompletionDate,
    bool clearLastCompletionDate = false,
  }) {
    return DailyStreakGoal(
      title: title ?? this.title,
      targetCount: targetCount ?? this.targetCount,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      todayProgress: todayProgress ?? this.todayProgress,
      entries: entries ?? this.entries,
      lastProgressDate: clearLastProgressDate
          ? null
          : lastProgressDate ?? this.lastProgressDate,
      lastCompletionDate: clearLastCompletionDate
          ? null
          : lastCompletionDate ?? this.lastCompletionDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'target_count': targetCount,
      'reminder_hour': reminderHour,
      'reminder_minute': reminderMinute,
      'current_streak': currentStreak,
      'best_streak': bestStreak,
      'today_progress': todayProgress,
      'entries': entries.map((entry) => entry.toJson()).toList(),
      'last_progress_date': lastProgressDate?.toIso8601String(),
      'last_completion_date': lastCompletionDate?.toIso8601String(),
    };
  }

  factory DailyStreakGoal.fromJson(Map<String, dynamic> json) {
    return DailyStreakGoal(
      title: (json['title'] as String? ?? '').trim(),
      targetCount: (json['target_count'] as num?)?.toInt() ?? 1,
      reminderHour: (json['reminder_hour'] as num?)?.toInt() ?? 20,
      reminderMinute: (json['reminder_minute'] as num?)?.toInt() ?? 0,
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
      bestStreak: (json['best_streak'] as num?)?.toInt() ?? 0,
      todayProgress: (json['today_progress'] as num?)?.toInt() ?? 0,
      entries: ((json['entries'] as List<dynamic>?) ?? const [])
          .whereType<Map>()
          .map(
            (entry) => DailyStreakEntry.fromJson(entry.cast<String, dynamic>()),
          )
          .toList(),
      lastProgressDate: _parseDate(json['last_progress_date']),
      lastCompletionDate: _parseDate(json['last_completion_date']),
    );
  }

  int remainingToday(DateTime now) {
    if (!isActiveToday(now)) {
      return targetCount;
    }
    final remaining = targetCount - todayProgress;
    return remaining < 0 ? 0 : remaining;
  }

  bool completedToday(DateTime now) {
    final today = startOfDay(now);
    return lastCompletionDate != null &&
        startOfDay(lastCompletionDate!) == today &&
        todayProgress >= targetCount;
  }

  bool isActiveToday(DateTime now) {
    final today = startOfDay(now);
    return lastProgressDate != null && startOfDay(lastProgressDate!) == today;
  }

  DailyStreakEntry? entryForDate(DateTime date) {
    final normalizedDate = startOfDay(date);
    for (final entry in entries) {
      if (startOfDay(entry.date) == normalizedDate) {
        return entry;
      }
    }
    return null;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value)?.toLocal();
    }
    return null;
  }

  static DateTime startOfDay(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
