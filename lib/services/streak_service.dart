import 'dart:convert';
import 'dart:math' as math;

import 'package:calisync/model/daily_streak_goal.dart';
import 'package:calisync/services/streak_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StreakService {
  StreakService._();

  static final StreakService instance = StreakService._();

  static const String _storageKey = 'daily_streak_goal_v1';

  Future<DailyStreakGoal?> loadGoal() async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getString(_storageKey);
    if (stored == null || stored.trim().isEmpty) {
      await StreakNotificationService.instance.syncReminder(null);
      return null;
    }

    try {
      final json = jsonDecode(stored) as Map<String, dynamic>;
      final normalized = _normalizeGoal(DailyStreakGoal.fromJson(json));
      await _persistGoal(normalized);
      await StreakNotificationService.instance.syncReminder(normalized);
      return normalized;
    } catch (_) {
      await preferences.remove(_storageKey);
      await StreakNotificationService.instance.syncReminder(null);
      return null;
    }
  }

  Future<DailyStreakGoal> saveGoal({
    required String title,
    required int targetCount,
    required int reminderHour,
    required int reminderMinute,
  }) async {
    final existing = await _readStoredGoal();
    final shouldCarryToday =
        existing != null &&
        existing.title.toLowerCase() == title.trim().toLowerCase() &&
        existing.targetCount == targetCount;

    final goal = _normalizeGoal(
      DailyStreakGoal(
        title: title.trim(),
        targetCount: targetCount,
        reminderHour: reminderHour,
        reminderMinute: reminderMinute,
        currentStreak: existing?.currentStreak ?? 0,
        bestStreak: existing?.bestStreak ?? 0,
        todayProgress: shouldCarryToday ? existing.todayProgress : 0,
        entries: shouldCarryToday ? existing.entries : const [],
        lastProgressDate: shouldCarryToday ? existing.lastProgressDate : null,
        lastCompletionDate: shouldCarryToday
            ? existing.lastCompletionDate
            : existing?.lastCompletionDate,
      ),
    );

    await StreakNotificationService.instance.requestPermissions();
    await _persistGoal(goal);
    await StreakNotificationService.instance.syncReminder(goal);
    return goal;
  }

  Future<DailyStreakGoal?> addProgress(int amount) async {
    if (amount <= 0) {
      return loadGoal();
    }

    final existing = await _readStoredGoal();
    if (existing == null) {
      return null;
    }

    final goal = _normalizeGoal(existing);
    final today = _startOfDay(DateTime.now());
    final existingEntry = goal.entryForDate(today);
    final baseProgress =
        existingEntry?.totalCount ??
        (goal.isActiveToday(today) ? goal.todayProgress : 0);
    final updatedProgress = baseProgress + amount;
    final updatedEntries = List<DailyStreakEntry>.from(goal.entries);
    final updatedEntry = DailyStreakEntry(
      date: today,
      totalCount: updatedProgress,
      completedTarget: updatedProgress >= goal.targetCount,
    );
    final existingEntryIndex = updatedEntries.indexWhere(
      (entry) => _startOfDay(entry.date) == today,
    );
    if (existingEntryIndex == -1) {
      updatedEntries.add(updatedEntry);
    } else {
      updatedEntries[existingEntryIndex] = updatedEntry;
    }

    var updatedGoal = goal.copyWith(
      todayProgress: updatedProgress,
      entries: updatedEntries,
      lastProgressDate: today,
    );

    if (!goal.completedToday(today) && updatedProgress >= goal.targetCount) {
      final yesterday = today.subtract(const Duration(days: 1));
      final extendingStreak =
          goal.lastCompletionDate != null &&
          _startOfDay(goal.lastCompletionDate!) == yesterday;
      final nextStreak = extendingStreak ? goal.currentStreak + 1 : 1;
      updatedGoal = updatedGoal.copyWith(
        currentStreak: nextStreak,
        bestStreak: math.max(goal.bestStreak, nextStreak),
        lastCompletionDate: today,
      );
    }

    await _persistGoal(updatedGoal);
    await StreakNotificationService.instance.syncReminder(updatedGoal);
    return updatedGoal;
  }

  Future<void> deleteGoal() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
    await StreakNotificationService.instance.syncReminder(null);
  }

  Future<DailyStreakGoal?> _readStoredGoal() async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getString(_storageKey);
    if (stored == null || stored.trim().isEmpty) {
      return null;
    }
    try {
      final json = jsonDecode(stored) as Map<String, dynamic>;
      return DailyStreakGoal.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> _persistGoal(DailyStreakGoal goal) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, jsonEncode(goal.toJson()));
  }

  DailyStreakGoal _normalizeGoal(DailyStreakGoal goal) {
    final now = DateTime.now();
    final today = _startOfDay(now);
    var normalized = goal;

    if (normalized.lastProgressDate != null &&
        _startOfDay(normalized.lastProgressDate!).isBefore(today) &&
        normalized.todayProgress != 0) {
      normalized = normalized.copyWith(
        todayProgress: 0,
        clearLastProgressDate: true,
      );
    }

    if (normalized.lastCompletionDate != null) {
      final lastCompletionDay = _startOfDay(normalized.lastCompletionDate!);
      if (today.difference(lastCompletionDay).inDays > 1 &&
          normalized.currentStreak != 0) {
        normalized = normalized.copyWith(currentStreak: 0);
      }
    }

    return normalized;
  }

  DateTime _startOfDay(DateTime value) {
    return DailyStreakGoal.startOfDay(value);
  }
}
