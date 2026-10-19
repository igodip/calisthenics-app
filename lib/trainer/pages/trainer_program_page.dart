import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

import '../components/trainer_feedback_card.dart';
import '../components/trainer_responsive_list.dart';
import '../trainer_models.dart';
import '../trainer_repository.dart';
import '../pdf/trainer_pdf_import.dart';
import '../pdf/trainer_pdf_storage.dart';
import '../../l10n/app_localizations.dart';
import '../../data/exercise_guides.dart';
import '../../model/exercise_guide.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_date_format.dart';

typedef _MaxTestDraft = ({
  String? exerciseId,
  String exercise,
  double value,
  String unit,
  DateTime recordedAt,
  String notes,
});

enum _MaxTestAction { editNotes, delete }

typedef _TrainerPlanDays = ({
  Map<String, dynamic>? plan,
  List<Map<String, dynamic>> days,
});

class TrainerProgramPage extends StatefulWidget {
  const TrainerProgramPage({
    super.key,
    required this.trainee,
    required this.allTrainees,
    required this.repository,
    required this.onTraineeChanged,
  });
  final TrainerTrainee trainee;
  final List<TrainerTrainee> allTrainees;
  final TrainerRepository repository;
  final ValueChanged<TrainerTrainee> onTraineeChanged;

  @override
  State<TrainerProgramPage> createState() => _TrainerProgramPageState();
}

class _TrainerProgramPageState extends State<TrainerProgramPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late final TextEditingController _tip;
  late final TextEditingController _notes;
  TrainerProgramData? _data;
  Object? _error;
  bool _loading = true;
  bool _saving = false;
  bool _importingPdf = false;
  bool _showAllCalendarDays = false;
  Future<List<ExerciseGuide>>? _exerciseGuidesFuture;
  String? _exerciseGuidesLocale;
  List<ExerciseGuide> _exerciseGuides = const [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _tip = TextEditingController(text: widget.trainee.coachTip);
    _notes = TextEditingController(text: widget.trainee.trainerNotes);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _tip.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = AppLocalizations.of(context)!.localeName;
    if (_exerciseGuidesFuture == null || _exerciseGuidesLocale != locale) {
      _exerciseGuidesLocale = locale;
      final future = ExerciseGuides.load(locale);
      _exerciseGuidesFuture = future;
      future.then((guides) {
        if (mounted && _exerciseGuidesLocale == locale) {
          setState(() => _exerciseGuides = guides);
        }
      }).ignore();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _data = await widget.repository.loadProgram(
        widget.trainee,
        widget.allTrainees,
      );
    } catch (error) {
      _error = error;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _message(Object message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.greenAccent.shade400),
          const SizedBox(width: 12),
          Expanded(child: Text('$message')),
        ],
      ),
    ),
  );

  Future<void> _saveCoach() async {
    final savedMessage = AppLocalizations.of(context)!.trainerCoachFieldsSaved;
    setState(() => _saving = true);
    try {
      await widget.repository.saveCoachFields(
        widget.trainee.id,
        coachTip: _tip.text,
        trainerNotes: _notes.text,
      );
      widget.onTraineeChanged(
        widget.trainee.copyWith(
          coachTip: _tip.text.trim(),
          trainerNotes: _notes.text.trim(),
        ),
      );
      if (mounted) _message(savedMessage);
    } catch (e) {
      _message(e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.trainee.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color:
                Theme.of(context).appBarTheme.foregroundColor ??
                colorScheme.onSurface,
          ),
        ),
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(text: l10n.trainerOverviewTab),
            Tab(text: l10n.trainerPlanTab),
            Tab(text: l10n.trainerHistoryTab),
            Tab(text: l10n.trainerMaxTests),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.trainerLoadProgramError('$_error'),
                    textAlign: TextAlign.center,
                  ),
                  FilledButton(
                    onPressed: _load,
                    child: Text(l10n.trainerRetry),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabs,
              children: [_overview(), _plan(), _history(), _maxTests()],
            ),
    );
  }

  Widget _overview() {
    final planDays = _calendarPlanDays();
    final traineeVisiblePlanId = _traineeVisiblePlanId(planDays);
    final visibleDayCount = planDays.fold<int>(0, (count, planDays) {
      final weeks = _calendarWeeks(planDays.days);
      final visibleWeeks = _showAllCalendarDays
          ? weeks
          : weeks.take(2).toList();
      return count +
          visibleWeeks.fold<int>(
            0,
            (weekCount, week) => weekCount + week.value.length,
          );
    });
    final hiddenDays = (_data!.days.length - visibleDayCount).clamp(0, 1 << 31);
    return TrainerResponsiveList(
      onRefresh: _load,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.trainerAthleteData,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                _row(
                  AppLocalizations.of(context)!.trainerNameLabel,
                  widget.trainee.name,
                ),
                _row(
                  AppLocalizations.of(context)!.trainerWeightLabel,
                  widget.trainee.weight == null
                      ? '—'
                      : '${widget.trainee.weight} kg',
                ),
                _row(
                  AppLocalizations.of(context)!.profileHeight,
                  widget.trainee.height == null
                      ? '—'
                      : '${widget.trainee.height} cm',
                ),
                _row(
                  AppLocalizations.of(context)!.trainerPaymentLabel,
                  widget.trainee.paid
                      ? AppLocalizations.of(context)!.trainerOnTime
                      : AppLocalizations.of(context)!.trainerOverdue,
                ),
                _row(
                  AppLocalizations.of(context)!.trainerProgressLabel,
                  '${widget.trainee.progress}%',
                ),
                const Divider(height: 28),
                TextField(
                  controller: _tip,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.trainerCoachTip,
                    hintText: AppLocalizations.of(context)!.trainerCoachTipHint,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notes,
                  minLines: 2,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    )!.trainerPrivateNotes,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _saveCoach,
                    icon: const Icon(Icons.save),
                    label: Text(AppLocalizations.of(context)!.trainerSave),
                  ),
                ),
              ],
            ),
          ),
        ),
        _sectionTitle(AppLocalizations.of(context)!.trainerTrainingCalendar),
        if (_data!.days.isEmpty)
          Text(AppLocalizations.of(context)!.trainerNoScheduledDays)
        else ...[
          for (final planGroup in planDays)
            _planCalendarCard(
              planGroup,
              editable: false,
              weekLimit: _showAllCalendarDays ? null : 2,
              isTraineeVisible:
                  '${planGroup.plan?['id']}' == traineeVisiblePlanId,
            ),
          if (hiddenDays > 0)
            Align(
              alignment: Alignment.center,
              child: TextButton.icon(
                key: const ValueKey('trainer-calendar-show-more'),
                onPressed: () => setState(
                  () => _showAllCalendarDays = !_showAllCalendarDays,
                ),
                icon: Icon(
                  _showAllCalendarDays ? Icons.expand_less : Icons.expand_more,
                ),
                label: Text(
                  _showAllCalendarDays
                      ? AppLocalizations.of(context)!.trainerShowLessDays
                      : AppLocalizations.of(
                          context,
                        )!.trainerShowMoreDays(hiddenDays),
                ),
              ),
            ),
        ],
        _sectionTitle(AppLocalizations.of(context)!.trainerFeedbackTitle),
        if (_data!.feedback.isEmpty)
          Text(AppLocalizations.of(context)!.trainerNoFeedbackYet)
        else
          for (final item in _data!.feedback.take(3))
            TrainerFeedbackCard(
              feedback: item,
              onToggleRead: (value) async {
                await widget.repository.setFeedbackRead(item.id, value);
                await _load();
              },
              onAnswer: (answer) async {
                await widget.repository.answerFeedback(item.id, answer);
                await _load();
              },
              onDelete: () => _deleteFeedback(item),
            ),
      ],
    );
  }

  List<MapEntry<int, List<Map<String, dynamic>>>> _calendarWeeks(
    Iterable<Map<String, dynamic>> days,
  ) {
    final weeks = <int, List<Map<String, dynamic>>>{};
    for (final day in days) {
      final week = (day['week'] as num?)?.toInt() ?? 0;
      weeks.putIfAbsent(week, () => []).add(day);
    }
    for (final daysInWeek in weeks.values) {
      daysInWeek.sort((a, b) {
        final aCode = '${a['day_code'] ?? a['title'] ?? ''}'.toUpperCase();
        final bCode = '${b['day_code'] ?? b['title'] ?? ''}'.toUpperCase();
        return aCode.compareTo(bCode);
      });
    }
    return weeks.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
  }

  List<_TrainerPlanDays> _calendarPlanDays() {
    final groups = <_TrainerPlanDays>[];
    final assignedDays = <Map<String, dynamic>>{};
    for (final plan in _data!.plans) {
      final planId = '${plan['id']}';
      final days = _data!.days.where((day) {
        final hasPlan = trainerRelationRows(
          day['workout_plan_days'],
        ).any((link) => '${link['plan_id']}' == planId);
        if (hasPlan) assignedDays.add(day);
        return hasPlan;
      }).toList();
      groups.add((plan: plan, days: days));
    }

    final unassignedDays = _data!.days
        .where((day) => !assignedDays.contains(day))
        .toList();
    if (unassignedDays.isNotEmpty) {
      groups.add((plan: null, days: unassignedDays));
    }
    return groups;
  }

  String? _traineeVisiblePlanId(List<_TrainerPlanDays> planDays) {
    for (final planGroup in planDays) {
      final plan = planGroup.plan;
      if (planGroup.days.isNotEmpty &&
          '${plan?['status']}'.toLowerCase() == 'active') {
        return '${plan?['id']}';
      }
    }
    return null;
  }

  Widget _planCalendarCard(
    _TrainerPlanDays planGroup, {
    required bool editable,
    bool isTraineeVisible = false,
    int? weekLimit,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final plan = planGroup.plan;
    final weeks = _calendarWeeks(planGroup.days);
    final isCompleted =
        planGroup.days.isNotEmpty &&
        planGroup.days.every((day) => day['completed'] == true);
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>();
    final visibleWeeks = weekLimit == null
        ? weeks
        : weeks.take(weekLimit).toList();
    final title = '${plan?['title'] ?? l10n.trainerWorkoutPlanFallback}';
    final planId = plan?['id'] ?? 'unassigned';
    final startsOn = AppDateFormat.dateValue(plan?['starts_on']);
    final notes = '${plan?['notes'] ?? ''}'.trim();
    final subtitle = [
      if (startsOn.isNotEmpty) startsOn,
      if (notes.isNotEmpty) notes,
    ].join(' · ');

    return Card(
      key: ValueKey('trainer-plan-calendar-$planId'),
      margin: const EdgeInsets.only(bottom: 12),
      color: isCompleted
          ? appColors?.successContainer ?? Colors.green.shade50
          : theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCompleted
              ? appColors?.success ?? theme.colorScheme.secondary
              : theme.colorScheme.primary,
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.all(16),
        leading: const Icon(Icons.event_note),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isTraineeVisible || isCompleted)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isTraineeVisible)
                    Chip(
                      label: Text(l10n.profilePlanActive),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: theme.colorScheme.primary,
                      labelStyle: TextStyle(color: theme.colorScheme.onPrimary),
                    ),
                  if (isCompleted)
                    Chip(
                      label: Text(l10n.trainerPlanCompleted),
                      visualDensity: VisualDensity.compact,
                      backgroundColor:
                          appColors?.successContainer ??
                          theme.colorScheme.secondaryContainer,
                      labelStyle: TextStyle(
                        color:
                            appColors?.success ??
                            theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                ],
              ),
            if (editable && plan != null)
              IconButton(
                tooltip: l10n.trainerDeletePlanTitle,
                onPressed: () => _deletePlan(plan),
                icon: const Icon(Icons.delete_outline),
              ),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          if (visibleWeeks.isEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(l10n.trainerNoScheduledDays),
              ),
            ),
          for (final week in visibleWeeks) ...[
            _weekTitle(week.key, week.value),
            for (final day in week.value) _dayCard(day, editable: editable),
          ],
        ],
      ),
    );
  }

  Widget _weekTitle(int week, [Iterable<Map<String, dynamic>>? days]) {
    final l10n = AppLocalizations.of(context)!;
    final weekTitles =
        days
            ?.map((day) => day['week_title'])
            .whereType<String>()
            .map((title) => title.trim())
            .where((title) => title.isNotEmpty)
            .toList() ??
        const <String>[];
    final weekTitle = weekTitles.isEmpty ? null : weekTitles.first;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Text(
        weekTitle ??
            (week > 0 ? l10n.weekNumber(week) : l10n.defaultWorkoutTitle),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _plan() {
    final planDays = _calendarPlanDays();
    final traineeVisiblePlanId = _traineeVisiblePlanId(planDays);
    return TrainerResponsiveList(
      onRefresh: _load,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              onPressed: _showCreatePlan,
              icon: const Icon(Icons.add),
              label: Text(
                AppLocalizations.of(context)!.trainerCreateWorkoutPlan,
              ),
            ),
            OutlinedButton.icon(
              onPressed: _importingPdf ? null : _importPdf,
              icon: _importingPdf
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.picture_as_pdf_outlined),
              label: Text(
                _importingPdf
                    ? AppLocalizations.of(context)!.trainerImportingPdf
                    : AppLocalizations.of(context)!.trainerImportPdf,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_data!.plans.isEmpty && _data!.days.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(AppLocalizations.of(context)!.trainerNoPlans),
            ),
          ),
        for (final planGroup in planDays)
          _planCalendarCard(
            planGroup,
            editable: true,
            isTraineeVisible:
                '${planGroup.plan?['id']}' == traineeVisiblePlanId,
          ),
      ],
    );
  }

  Widget _maxTests() => TrainerResponsiveList(
    onRefresh: _load,
    children: [
      _sectionTitle(
        AppLocalizations.of(context)!.trainerMaxTests,
        action: IconButton.filledTonal(
          tooltip: AppLocalizations.of(context)!.trainerAddMaxTest,
          onPressed: _showAddMaxTest,
          icon: const Icon(Icons.add),
        ),
      ),
      if (_data!.maxTests.isEmpty)
        Text(AppLocalizations.of(context)!.trainerNoMaxTests)
      else
        for (final group in _maxTestDateGroups()) ...[
          _maxTestDateTitle(group.key),
          for (final test in group.value)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.emoji_events),
                title: Text(_maxTestExerciseLabel(test)),
                subtitle: Text(
                  '${test['value']} ${test['unit']}${_maxTestNotesSuffix(test)}',
                ),
                isThreeLine: _maxTestPrivateNotes(test).isNotEmpty,
                trailing: PopupMenuButton<_MaxTestAction>(
                  onSelected: (action) {
                    switch (action) {
                      case _MaxTestAction.editNotes:
                        _editMaxTestNotes(test);
                      case _MaxTestAction.delete:
                        _deleteMaxTest(test);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _MaxTestAction.editNotes,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.edit_note_outlined),
                        title: Text(
                          AppLocalizations.of(context)!.trainerEditMaxTestNotes,
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: _MaxTestAction.delete,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.delete_outline),
                        title: Text(
                          AppLocalizations.of(context)!.trainerDeleteMaxTest,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
    ],
  );

  List<MapEntry<String, List<Map<String, dynamic>>>> _maxTestDateGroups() {
    final groups = <String, List<Map<String, dynamic>>>{};
    for (final test in _data!.maxTests) {
      final recordedAt = test['recorded_at']?.toString() ?? '';
      final date = recordedAt.length >= 10
          ? recordedAt.substring(0, 10)
          : recordedAt;
      groups.putIfAbsent(date, () => []).add(test);
    }
    return groups.entries.toList()..sort((a, b) {
      final aDate = DateTime.tryParse(a.key);
      final bDate = DateTime.tryParse(b.key);
      if (aDate == null) return bDate == null ? a.key.compareTo(b.key) : 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });
  }

  Widget _maxTestDateTitle(String date) {
    final parsedDate = DateTime.tryParse(date);
    final label = parsedDate == null
        ? (date.isEmpty ? '—' : date)
        : AppDateFormat.date(parsedDate);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _history() => TrainerResponsiveList(
    onRefresh: _load,
    children: [
      _sectionTitle(AppLocalizations.of(context)!.trainerWeightHistory),
      if (_data!.weightLogs.isEmpty)
        Text(AppLocalizations.of(context)!.trainerNoWeightEntries)
      else
        for (final log in _data!.weightLogs)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.monitor_weight),
              title: Text('${log['weight']} kg'),
              subtitle: Text(
                '${AppDateFormat.dateValue(log['recorded_at'])}${log['notes'] == null ? '' : ' · ${log['notes']}'}',
              ),
            ),
          ),
      _sectionTitle(AppLocalizations.of(context)!.trainerHeightHistory),
      if (_data!.heightLogs.isEmpty)
        Text(AppLocalizations.of(context)!.trainerNoHeightEntries)
      else
        for (final log in _data!.heightLogs)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.height),
              title: Text('${log['height']} cm'),
              subtitle: Text(
                '${AppDateFormat.dateValue(log['recorded_at'])}${log['notes'] == null ? '' : ' · ${log['notes']}'}',
              ),
            ),
          ),
      _sectionTitle(AppLocalizations.of(context)!.trainerPaymentHistory),
      if (_data!.payments.isEmpty)
        Text(AppLocalizations.of(context)!.trainerNoPayments)
      else
        for (final payment in _data!.payments)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(
                payment['paid'] == true ? Icons.check_circle : Icons.schedule,
              ),
              title: Text(AppDateFormat.dateValue(payment['month_start'])),
              subtitle: Text(
                payment['paid'] == true
                    ? '${AppLocalizations.of(context)!.trainerPaid}${_paymentNotesSuffix(payment)}'
                    : '${AppLocalizations.of(context)!.trainerOverdue}${_paymentNotesSuffix(payment)}',
              ),
              trailing: Text(
                payment['amount'] == null ? '—' : '€${payment['amount']}',
              ),
            ),
          ),
    ],
  );

  String _paymentNotesSuffix(Map<String, dynamic> payment) {
    final notes = payment['notes']?.toString().trim() ?? '';
    return notes.isEmpty ? '' : '\n$notes';
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        const SizedBox(width: 12),
        Flexible(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    ),
  );

  Future<void> _showAddMaxTest() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final guides = await _exerciseGuidesFuture;
      if (!mounted) return;
      if (guides == null || guides.isEmpty) {
        _message(l10n.trainerMaxTestNoExercises);
        return;
      }
      _exerciseGuides = guides;
      final draft = await showDialog<_MaxTestDraft>(
        context: context,
        builder: (context) => _AddMaxTestDialog(guides: guides),
      );
      if (draft == null || !mounted) return;
      await widget.repository.addMaxTest(
        widget.trainee.id,
        exerciseId: draft.exerciseId,
        exercise: draft.exercise,
        value: draft.value,
        unit: draft.unit,
        recordedAt: draft.recordedAt,
        notes: draft.notes,
      );
      if (!mounted) return;
      _message(l10n.trainerMaxTestSaved);
      await _load();
    } catch (error) {
      if (mounted) _message(l10n.trainerMaxTestSaveError('$error'));
    }
  }

  String _maxTestExerciseLabel(Map<String, dynamic> test) {
    final exerciseId = test['exercise_id']?.toString();
    final raw = test['exercise']?.toString().trim() ?? '';
    for (final guide in _exerciseGuides) {
      if ((exerciseId != null && guide.databaseId == exerciseId) ||
          guide.id.toLowerCase() == raw.toLowerCase() ||
          guide.name.toLowerCase() == raw.toLowerCase()) {
        return guide.name;
      }
    }
    return raw.isEmpty
        ? AppLocalizations.of(context)!.trainerExerciseFallback
        : raw;
  }

  String _maxTestPrivateNotes(Map<String, dynamic> test) =>
      test['trainer_notes']?.toString().trim() ?? '';

  String _maxTestNotesSuffix(Map<String, dynamic> test) {
    final notes = _maxTestPrivateNotes(test);
    return notes.isEmpty
        ? ''
        : '\n${AppLocalizations.of(context)!.trainerPrivateNotes}: $notes';
  }

  Future<void> _editMaxTestNotes(Map<String, dynamic> test) async {
    final l10n = AppLocalizations.of(context)!;
    final notes = await showDialog<String>(
      context: context,
      builder: (context) =>
          _EditMaxTestNotesDialog(initialNotes: _maxTestPrivateNotes(test)),
    );
    if (notes == null || !mounted) return;
    try {
      await widget.repository.saveMaxTestTrainerNotes(test['id']!, notes);
      if (!mounted) return;
      _message(l10n.trainerMaxTestNotesUpdated);
      await _load();
    } catch (error) {
      if (mounted) _message(l10n.trainerMaxTestSaveError('$error'));
    }
  }

  Future<void> _deleteMaxTest(Map<String, dynamic> test) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.trainerDeleteMaxTestTitle),
        content: Text(l10n.trainerDeleteMaxTestMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.trainerCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.trainerDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await widget.repository.deleteMaxTest(test['id']!);
      if (!mounted) return;
      _message(l10n.trainerMaxTestDeleted);
      await _load();
    } catch (error) {
      if (mounted) _message(l10n.trainerMaxTestDeleteError('$error'));
    }
  }

  Widget _sectionTitle(String title, {Widget? action}) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (action != null) action,
      ],
    ),
  );

  Widget _dayCard(Map<String, dynamic> day, {bool editable = false}) {
    final exercises = trainerRelationRows(day['day_exercises']);
    final done = exercises.where((item) => item['completed'] == true).length;
    final isCompleted = day['completed'] == true;
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isCompleted
          ? appColors?.successContainer ?? Colors.green.shade50
          : null,
      child: ExpansionTile(
        leading: Icon(
          Icons.calendar_today,
          color: isCompleted
              ? appColors?.success ?? theme.colorScheme.secondary
              : theme.colorScheme.primary,
        ),
        title: Text(
          '${day['title'] ?? day['day_code'] ?? AppLocalizations.of(context)!.trainerTrainingDayFallback}',
        ),
        subtitle: Text(
          AppLocalizations.of(
            context,
          )!.trainerExercisesCompleted(done, exercises.length),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCompleted) ...[
              Icon(
                Icons.check_circle,
                color: appColors?.success ?? theme.colorScheme.secondary,
              ),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          for (final exercise in exercises)
            ListTile(
              leading: Icon(
                exercise['completed'] == true
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
              ),
              title: Text(
                '${exercise['exercise'] ?? AppLocalizations.of(context)!.trainerExerciseFallback}',
              ),
              subtitle: Text(_exerciseSubtitle(exercise)),
              trailing: editable
                  ? IconButton(
                      tooltip: AppLocalizations.of(
                        context,
                      )!.trainerEditExerciseTitle,
                      onPressed: () => _editExercise(day, exercise),
                      icon: const Icon(Icons.edit_outlined),
                    )
                  : null,
            ),
        ],
      ),
    );
  }

  String _exerciseSubtitle(Map<String, dynamic> exercise) {
    final l10n = AppLocalizations.of(context)!;
    final minutes = '${exercise['duration_minutes'] ?? '—'}';
    final completedReps = exercise['completed_reps'];
    final result = completedReps == null
        ? l10n.trainerMinutesDuration(minutes)
        : l10n.trainerExerciseResult(minutes, '$completedReps');
    final notes = '${exercise['notes'] ?? ''}'.trim();
    final traineeNotes = '${exercise['trainee_notes'] ?? ''}'.trim();
    final exerciseFeedback = '${exercise['exercise_feedback'] ?? ''}'.trim();
    return [
      result,
      if (notes.isNotEmpty) notes,
      if (traineeNotes.isNotEmpty) l10n.trainerTraineeNote(traineeNotes),
      if (exerciseFeedback.isNotEmpty)
        l10n.trainerTraineeExerciseFeedback(exerciseFeedback),
    ].join('\n');
  }

  Future<void> _editExercise(
    Map<String, dynamic> day,
    Map<String, dynamic> exercise,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    var name = '${exercise['exercise'] ?? ''}';
    final durationValue = exercise['duration_minutes'];
    var duration = durationValue == null ? '' : '$durationValue';
    var notes = '${exercise['notes'] ?? ''}';
    String? validationError;

    final values =
        await showDialog<({String name, int? durationMinutes, String notes})>(
          context: context,
          builder: (dialogContext) => StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
              title: Text(l10n.trainerEditExerciseTitle),
              content: SizedBox(
                width: 440,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        initialValue: name,
                        onChanged: (value) => name = value,
                        autofocus: true,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: l10n.trainerExerciseName,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: duration,
                        onChanged: (value) => duration = value,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.trainerExerciseDuration,
                          suffixText: 'min',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: notes,
                        onChanged: (value) => notes = value,
                        minLines: 2,
                        maxLines: 5,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: l10n.trainerExerciseNotes,
                        ),
                      ),
                      if (validationError != null) ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            validationError!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(l10n.trainerCancel),
                ),
                FilledButton.icon(
                  onPressed: () {
                    final trimmedName = name.trim();
                    final durationText = duration.trim();
                    final parsedDuration = durationText.isEmpty
                        ? null
                        : int.tryParse(durationText);
                    if (trimmedName.isEmpty) {
                      setDialogState(
                        () =>
                            validationError = l10n.trainerExerciseNameRequired,
                      );
                      return;
                    }
                    if (durationText.isNotEmpty &&
                        (parsedDuration == null || parsedDuration < 0)) {
                      setDialogState(
                        () => validationError =
                            l10n.trainerExerciseDurationInvalid,
                      );
                      return;
                    }
                    Navigator.pop(dialogContext, (
                      name: trimmedName,
                      durationMinutes: parsedDuration,
                      notes: notes,
                    ));
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: Text(l10n.trainerSave),
                ),
              ],
            ),
          ),
        );

    if (values == null || !mounted) return;

    final links = trainerRelationRows(day['workout_plan_days']);
    final planId = links.isEmpty ? null : links.first['plan_id'];
    try {
      await widget.repository.updateDayExercise(
        exercise['id']!,
        name: values.name,
        durationMinutes: values.durationMinutes,
        notes: values.notes,
        planId: planId,
      );
      if (!mounted) return;
      final currentData = _data;
      if (currentData != null) {
        final updatedExercise = Map<String, dynamic>.from(exercise)
          ..['exercise'] = values.name
          ..['duration_minutes'] = values.durationMinutes
          ..['notes'] = values.notes;
        final updatedDays = currentData.days.map((currentDay) {
          if (!identical(currentDay, day)) return currentDay;
          return {
            ...currentDay,
            'day_exercises': trainerRelationRows(currentDay['day_exercises'])
                .map((item) {
                  return item['id'] == exercise['id'] ? updatedExercise : item;
                })
                .toList(),
          };
        }).toList();
        setState(() {
          _data = TrainerProgramData(
            plans: currentData.plans,
            days: updatedDays,
            maxTests: currentData.maxTests,
            weightLogs: currentData.weightLogs,
            heightLogs: currentData.heightLogs,
            payments: currentData.payments,
            feedback: currentData.feedback,
          );
        });
      }
      _message(l10n.trainerExerciseUpdated);
    } catch (error) {
      if (mounted) _message(error);
    }
  }

  Future<void> _deleteFeedback(TrainerFeedback item) async {
    final previousData = _data;
    if (previousData == null) return;
    final updatedData = previousData.withoutFeedback(item.id);
    setState(() => _data = updatedData);
    try {
      await widget.repository.deleteFeedback(item.id);
    } catch (error) {
      if (mounted) {
        if (identical(_data, updatedData)) {
          setState(() => _data = previousData);
        }
        _message(error);
      }
      rethrow;
    }
  }

  Future<void> _deletePlan(Map<String, dynamic> plan) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.trainerDeletePlanTitle),
            content: Text(
              AppLocalizations.of(context)!.trainerDeletePlanMessage(
                '${plan['title'] ?? AppLocalizations.of(context)!.trainerWorkoutPlanFallback}',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppLocalizations.of(context)!.trainerCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(AppLocalizations.of(context)!.trainerDelete),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    final planId = plan['id'];
    final previousData = _data;
    if (planId == null || previousData == null) return;
    final updatedData = previousData.withoutPlan(planId);
    setState(() => _data = updatedData);
    try {
      await widget.repository.deletePlan(planId);
    } catch (e) {
      if (mounted) {
        if (identical(_data, updatedData)) {
          setState(() => _data = previousData);
        }
        _message(e);
      }
    }
  }

  Future<void> _showCreatePlan() async {
    final title = TextEditingController();
    final notes = TextEditingController();
    final save =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.trainerNewPlan),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.trainerPlanName,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notes,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.trainerNotes,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppLocalizations.of(context)!.trainerCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(AppLocalizations.of(context)!.trainerCreate),
              ),
            ],
          ),
        ) ??
        false;
    if (!save || title.text.trim().isEmpty) {
      title.dispose();
      notes.dispose();
      return;
    }
    try {
      await widget.repository.createPlan(
        widget.trainee.id,
        title: title.text.trim(),
        status: 'active',
        startsOn: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        notes: notes.text.trim(),
      );
      await _load();
    } catch (e) {
      _message(e);
    }
    title.dispose();
    notes.dispose();
  }

  Future<void> _importPdf() async {
    final l10n = AppLocalizations.of(context)!;
    final selection = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      allowMultiple: false,
      withData: true,
    );
    if (selection == null) return;
    final file = selection.files.single;
    final bytes = file.bytes;
    if (bytes == null || !isValidWorkoutPlanPdf(bytes)) {
      _message(l10n.trainerPdfFileUnavailable);
      return;
    }

    setState(() => _importingPdf = true);
    try {
      final importer = const TrainerPdfImportService();
      final imported = await importer.readBytes(bytes, file.name);
      if (!mounted) return;
      final confirmed = await _showPdfPreview(imported);
      if (confirmed == null || !mounted) return;
      await widget.repository.createImportedPlan(
        widget.trainee.id,
        confirmed,
        bytes,
      );
      if (!mounted) return;
      _message(l10n.trainerPdfImportSuccess);
      await _load();
    } catch (error) {
      debugPrint('PDF workout import failed: $error');
      if (mounted) _message(l10n.trainerPdfImportFailed);
    } finally {
      if (mounted) setState(() => _importingPdf = false);
    }
  }

  Future<TrainerPdfPlan?> _showPdfPreview(TrainerPdfPlan imported) async {
    final l10n = AppLocalizations.of(context)!;
    final name = TextEditingController(text: imported.name);
    final shouldImport =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.trainerPdfPreviewTitle),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: name,
                      decoration: InputDecoration(
                        labelText: l10n.trainerPdfPlanName,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.trainerPdfSummary(
                        imported.days.length,
                        imported.exerciseCount,
                      ),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    for (final day in imported.days)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          l10n.trainerPdfDaySummary(
                            day.weekTitle ?? l10n.weekNumber(day.week),
                            day.dayCode,
                            day.exercises.length,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.trainerCancel),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pop(dialogContext, true),
                icon: const Icon(Icons.upload_file),
                label: Text(l10n.trainerPdfConfirmImport),
              ),
            ],
          ),
        ) ??
        false;
    final planName = name.text.trim();
    name.dispose();
    if (!shouldImport || planName.isEmpty) return null;
    return TrainerPdfPlan(name: planName, days: imported.days);
  }
}

class _AddMaxTestDialog extends StatefulWidget {
  const _AddMaxTestDialog({required this.guides});

  final List<ExerciseGuide> guides;

  @override
  State<_AddMaxTestDialog> createState() => _AddMaxTestDialogState();
}

class _AddMaxTestDialogState extends State<_AddMaxTestDialog> {
  static const _units = ['kg', 'reps', 'seconds', 'minutes'];
  static const _customExerciseOption = 'custom';

  final _formKey = GlobalKey<FormState>();
  final _value = TextEditingController();
  final _notes = TextEditingController();
  final _customExercise = TextEditingController();
  Object? _selectedExercise;
  String _unit = 'reps';
  DateTime _recordedAt = DateTime.now();

  @override
  void dispose() {
    _value.dispose();
    _notes.dispose();
    _customExercise.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final customExerciseSelected = _selectedExercise == _customExerciseOption;
    final exerciseDropdown = DropdownButtonFormField<Object>(
      initialValue: _selectedExercise,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.trainerMaxTestExercise,
        border: customExerciseSelected ? InputBorder.none : null,
        contentPadding: customExerciseSelected
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
            : null,
      ),
      items: [
        for (final guide in widget.guides)
          DropdownMenuItem(
            value: guide,
            child: Text(guide.name, overflow: TextOverflow.ellipsis),
          ),
        DropdownMenuItem(
          value: _customExerciseOption,
          child: Text(l10n.trainerMaxTestOther),
        ),
      ],
      onChanged: (value) {
        if (value != null) setState(() => _selectedExercise = value);
      },
      validator: (_) => _selectedExercise == null
          ? l10n.trainerMaxTestExerciseRequired
          : null,
    );
    return AlertDialog(
      title: Text(l10n.trainerAddMaxTest),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (customExerciseSelected)
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        exerciseDropdown,
                        SizedBox(
                          height: 1,
                          child: Center(
                            child: SizedBox(
                              width: 28,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant,
                                ),
                              ),
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _customExercise,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            labelText: l10n.trainerMaxTestCustomExerciseName,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? l10n.trainerMaxTestExerciseRequired
                              : null,
                        ),
                      ],
                    ),
                  )
                else
                  exerciseDropdown,
                const SizedBox(height: 12),
                TextFormField(
                  controller: _value,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.trainerMaxTestValue,
                  ),
                  validator: (raw) {
                    final parsed = double.tryParse(
                      (raw ?? '').trim().replaceAll(',', '.'),
                    );
                    return parsed == null || !parsed.isFinite || parsed <= 0
                        ? l10n.trainerMaxTestValueInvalid
                        : null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _unit,
                  decoration: InputDecoration(
                    labelText: l10n.trainerMaxTestUnit,
                  ),
                  items: [
                    for (final unit in _units)
                      DropdownMenuItem(value: unit, child: Text(unit)),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _unit = value);
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined),
                  title: Text(l10n.trainerMaxTestDate),
                  subtitle: Text(AppDateFormat.date(_recordedAt)),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notes,
                  minLines: 2,
                  maxLines: 5,
                  maxLength: 2000,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: l10n.trainerPrivateNotes,
                    helperText: l10n.trainerMaxTestPrivateNotesHint,
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.trainerCancel),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.save_outlined),
          label: Text(l10n.trainerSave),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      locale: const Locale('it', 'IT'),
      initialDate: _recordedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    if (selected != null && mounted) setState(() => _recordedAt = selected);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final selectedExercise = _selectedExercise;
    final isCustom = selectedExercise == _customExerciseOption;
    final exercise = isCustom ? null : selectedExercise as ExerciseGuide;
    Navigator.pop(context, (
      exerciseId: exercise?.databaseId,
      exercise: isCustom ? _customExercise.text.trim() : exercise!.id,
      value: double.parse(_value.text.trim().replaceAll(',', '.')),
      unit: _unit,
      recordedAt: _recordedAt,
      notes: _notes.text,
    ));
  }
}

class _EditMaxTestNotesDialog extends StatefulWidget {
  const _EditMaxTestNotesDialog({required this.initialNotes});

  final String initialNotes;

  @override
  State<_EditMaxTestNotesDialog> createState() =>
      _EditMaxTestNotesDialogState();
}

class _EditMaxTestNotesDialogState extends State<_EditMaxTestNotesDialog> {
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    _notes = TextEditingController(text: widget.initialNotes);
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.trainerEditMaxTestNotes),
      content: TextField(
        controller: _notes,
        autofocus: true,
        minLines: 3,
        maxLines: 6,
        maxLength: 2000,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: l10n.trainerPrivateNotes,
          helperText: l10n.trainerMaxTestPrivateNotesHint,
          alignLabelWithHint: true,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.trainerCancel),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context, _notes.text),
          icon: const Icon(Icons.save_outlined),
          label: Text(l10n.trainerSave),
        ),
      ],
    );
  }
}
