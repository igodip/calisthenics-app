import 'package:calisync/components/coach_tip.dart';
import 'package:calisync/components/streak_goal_card.dart';
import 'package:calisync/model/daily_streak_goal.dart';
import 'package:calisync/services/streak_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/progress_card.dart';
import '../l10n/app_localizations.dart';
import 'profile_page.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({
    super.key,
    required this.onOpenPlan,
    required this.onViewStats,
  });

  final VoidCallback onOpenPlan;
  final VoidCallback onViewStats;

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late Future<UserProfileData> _profileFuture;
  late Future<String?> _coachTip;
  late Future<bool> _latePaymentFuture;
  late Future<_AnsweredFeedback?> _lastAnsweredFeedbackFuture;
  late Future<DailyStreakGoal?> _streakGoalFuture;

  @override
  void initState() {
    super.initState();
    final client = Supabase.instance.client;
    _profileFuture = getUserData();
    _coachTip = _loadCoachTipForUser(
      Supabase.instance.client,
      client.auth.currentUser!.id,
    );
    _latePaymentFuture = _fetchIsPaymentLate();
    _lastAnsweredFeedbackFuture = _loadLastAnsweredFeedback();
    _streakGoalFuture = StreakService.instance.loadGoal();
  }

  Future<String?> _loadCoachTipForUser(
    SupabaseClient client,
    String userId,
  ) async {
    final response = await client
        .from('trainee_trainers')
        .select('coach_tip')
        .eq('trainee_id', userId)
        .maybeSingle();
    if (response == null) {
      return null;
    }
    final tip = response['coach_tip'] as String?;
    return tip?.trim().isEmpty ?? true ? null : tip?.trim();
  }

  Future<_AnsweredFeedback?> _loadLastAnsweredFeedback() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      return null;
    }

    try {
      final response = await client
          .from('trainee_feedbacks')
          .select('message, answer_message, answered_at')
          .eq('trainee_id', userId)
          .not('answered_at', 'is', null)
          .order('answered_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (response == null) {
        return null;
      }

      final answerMessage = (response['answer_message'] as String?)?.trim();
      final answeredAt = DateTime.tryParse(
        response['answered_at'] as String? ?? '',
      );
      if (answerMessage == null ||
          answerMessage.isEmpty ||
          answeredAt == null) {
        return null;
      }

      return _AnsweredFeedback(
        traineeMessage: (response['message'] as String? ?? '').trim(),
        trainerAnswer: answerMessage,
        answeredAt: answeredAt,
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> _fetchIsPaymentLate() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      return false;
    }

    final paymentResponse = await client
        .from('trainee_monthly_payments')
        .select('paid, month_start')
        .eq('trainee_id', userId)
        .order('month_start', ascending: false)
        .limit(1)
        .maybeSingle();

    if (paymentResponse == null) return false;

    final paid = paymentResponse['paid'] as bool? ?? true;
    final monthStartStr = paymentResponse['month_start'] as String?;
    if (monthStartStr == null) return false;

    final monthStart = DateTime.parse(monthStartStr);
    final now = DateTime.now();

    final isCurrentMonth =
        monthStart.year == now.year && monthStart.month == now.month;

    if (!isCurrentMonth) return true;

    return !paid;
  }

  Future<void> _refreshStreakGoal() async {
    setState(() {
      _streakGoalFuture = StreakService.instance.loadGoal();
    });
    await _streakGoalFuture;
  }

  Future<void> _showGoalDialog([DailyStreakGoal? existing]) async {
    final shouldRefresh = await showDialog<bool>(
      context: context,
      builder: (context) {
        return _GoalDialog(existing: existing);
      },
    );

    if (shouldRefresh == true) {
      await _refreshStreakGoal();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existing == null
                ? 'Daily streak created and reminder scheduled.'
                : 'Daily streak updated.',
          ),
        ),
      );
    }
  }

  Future<void> _showAddProgressDialog(DailyStreakGoal goal) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return _AddProgressDialog(goal: goal);
      },
    );

    if (result == null || result <= 0) {
      return;
    }

    final updated = await StreakService.instance.addProgress(result);
    await _refreshStreakGoal();
    if (!mounted || updated == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updated.completedToday(DateTime.now())
              ? 'Target done for today. The streak is safe.'
              : '${updated.remainingToday(DateTime.now())} left for today.',
        ),
      ),
    );
  }

  Future<void> _deleteGoal() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete streak goal?'),
          content: const Text(
            'This removes the current daily goal and cancels its reminder.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await StreakService.instance.deleteGoal();
    await _refreshStreakGoal();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Daily streak removed.')));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<UserProfileData>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final displayName = data?.displayName(l10n) ?? l10n.profileFallbackName;
        final initials = data?.initials(l10n) ?? '';
        final avatarUrl = data?.profile?.profileImageUrl?.trim();
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          children: [
            _HomeHeader(
              displayName: displayName,
              initials: initials,
              imageUrl: (avatarUrl == null || avatarUrl.isEmpty)
                  ? null
                  : avatarUrl,
            ),
            const SizedBox(height: 16),
            FutureBuilder<bool>(
              future: _latePaymentFuture,
              builder: (context, paymentSnap) {
                if (paymentSnap.connectionState != ConnectionState.done) {
                  return const SizedBox.shrink();
                }
                if (paymentSnap.hasError || paymentSnap.data != true) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
                    _LatePaymentCard(
                      title: l10n.profilePlanExpired,
                      description: l10n.homeLatePaymentDescription,
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
            const ProgressCard(),
            const SizedBox(height: 16),
            FutureBuilder<DailyStreakGoal?>(
              future: _streakGoalFuture,
              builder: (context, streakSnap) {
                final goal = streakSnap.data;
                return Column(
                  children: [
                    StreakGoalCard(
                      goal: goal,
                      onCreateGoal: () => _showGoalDialog(),
                      onEditGoal: goal == null
                          ? () => _showGoalDialog()
                          : () => _showGoalDialog(goal),
                      onDeleteGoal: _deleteGoal,
                      onAddProgress: goal == null
                          ? () => _showGoalDialog()
                          : () => _showAddProgressDialog(goal),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
            _ActionButtons(
              onOpenPlan: widget.onOpenPlan,
              onViewStats: widget.onViewStats,
            ),
            const SizedBox(height: 16),
            FutureBuilder<_AnsweredFeedback?>(
              future: _lastAnsweredFeedbackFuture,
              builder: (context, answeredSnap) {
                if (answeredSnap.connectionState != ConnectionState.done) {
                  return const SizedBox.shrink();
                }
                final feedback = answeredSnap.data;
                if (answeredSnap.hasError || feedback == null) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
                    _LastAnsweredFeedbackCard(feedback: feedback),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
            FutureBuilder<String?>(
              future: _coachTip,
              builder: (context, tipSnap) {
                if (tipSnap.connectionState != ConnectionState.done) {
                  // optional: show placeholder while loading
                  return const SizedBox.shrink();
                }
                if (tipSnap.hasError) {
                  // optional: hide on error (or show a small error widget)
                  return const SizedBox.shrink();
                }
                return CoachTipSection(tip: tipSnap.data);
              },
            ),
          ],
        );
      },
    );
  }
}

class _GoalDialog extends StatefulWidget {
  const _GoalDialog({this.existing});

  final DailyStreakGoal? existing;

  @override
  State<_GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<_GoalDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _targetController;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title ?? '');
    _targetController = TextEditingController(
      text: widget.existing?.targetCount.toString() ?? '10',
    );
    _selectedTime = TimeOfDay(
      hour: widget.existing?.reminderHour ?? 20,
      minute: widget.existing?.reminderMinute ?? 0,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _selectedTime = picked;
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final targetCount = int.tryParse(_targetController.text.trim());
    if (title.isEmpty || targetCount == null || targetCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Set a goal name and a target above zero.'),
        ),
      );
      return;
    }

    await StreakService.instance.saveGoal(
      title: title,
      targetCount: targetCount,
      reminderHour: _selectedTime.hour,
      reminderMinute: _selectedTime.minute,
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existing == null ? 'Create daily streak' : 'Edit daily streak',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Goal',
              hintText: 'Push-ups, squats, planks...',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _targetController,
            decoration: const InputDecoration(
              labelText: 'Daily target',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          Text(
            'Reminder time',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickReminderTime,
            icon: const Icon(Icons.notifications_active_outlined),
            label: Text(_selectedTime.format(context)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(widget.existing == null ? 'Save goal' : 'Update goal'),
        ),
      ],
    );
  }
}

class _AddProgressDialog extends StatefulWidget {
  const _AddProgressDialog({required this.goal});

  final DailyStreakGoal goal;

  @override
  State<_AddProgressDialog> createState() => _AddProgressDialogState();
}

class _AddProgressDialogState extends State<_AddProgressDialog> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(int.tryParse(_amountController.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Log ${widget.goal.title}'),
      content: TextField(
        controller: _amountController,
        decoration: const InputDecoration(
          labelText: 'How much did you do?',
        ),
        keyboardType: TextInputType.number,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        for (final quickAdd in const [1, 5, 10])
          TextButton(
            onPressed: () => Navigator.of(context).pop(quickAdd),
            child: Text('+${quickAdd.toString()}'),
          ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.displayName,
    required this.initials,
    required this.imageUrl,
  });

  final String displayName;
  final String initials;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.homeGreeting(displayName),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _AvatarChip(initials: initials, imageUrl: imageUrl),
      ],
    );
  }
}

class _AvatarChip extends StatelessWidget {
  const _AvatarChip({required this.initials, required this.imageUrl});

  final String initials;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarUrl = imageUrl?.trim();
    final avatarText = initials.isEmpty ? null : initials;
    return CircleAvatar(
      radius: 18,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: CircleAvatar(
        radius: 16,
        backgroundColor: theme.colorScheme.surface,
        backgroundImage: avatarUrl == null || avatarUrl.isEmpty
            ? null
            : NetworkImage(avatarUrl),
        child: avatarUrl == null || avatarUrl.isEmpty
            ? (avatarText == null
                  ? Icon(
                      Icons.person,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 18,
                    )
                  : Text(
                      avatarText,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ))
            : null,
      ),
    );
  }
}

class _AnsweredFeedback {
  const _AnsweredFeedback({
    required this.traineeMessage,
    required this.trainerAnswer,
    required this.answeredAt,
  });

  final String traineeMessage;
  final String trainerAnswer;
  final DateTime? answeredAt;
}

class _LastAnsweredFeedbackCard extends StatelessWidget {
  const _LastAnsweredFeedbackCard({required this.feedback});

  final _AnsweredFeedback feedback;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final answeredLabel = feedback.answeredAt == null
        ? null
        : '${l10n.traineeFeedbackAnsweredAtHome} ${MaterialLocalizations.of(context).formatShortDate(feedback.answeredAt!)}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.traineeFeedbackLastAnsweredTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            if (feedback.traineeMessage.isNotEmpty) ...[
              Text(
                l10n.traineeFeedbackYourMessage,
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              Text(feedback.traineeMessage),
              const SizedBox(height: 10),
            ],
            Text(
              l10n.traineeFeedbackTrainerAnswer,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: Text(feedback.trainerAnswer),
            ),
            if (answeredLabel != null) ...[
              const SizedBox(height: 10),
              Text(
                answeredLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onOpenPlan;
  final VoidCallback onViewStats;
  const _ActionButtons({required this.onOpenPlan, required this.onViewStats});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: onOpenPlan,
            child: Text(l10n.trainingStartWorkout),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: onViewStats,
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.45)),
              backgroundColor: colorScheme.primary.withValues(alpha: 0.08),
            ),
            child: Text(l10n.homeViewStats),
          ),
        ),
      ],
    );
  }
}

class _LatePaymentCard extends StatelessWidget {
  const _LatePaymentCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.assignment_late_outlined,
              color: theme.colorScheme.error,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
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
    );
  }
}
