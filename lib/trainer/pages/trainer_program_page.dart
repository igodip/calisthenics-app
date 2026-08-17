import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

import '../components/trainer_feedback_card.dart';
import '../components/trainer_responsive_list.dart';
import '../trainer_models.dart';
import '../trainer_repository.dart';
import '../pdf/trainer_pdf_import.dart';
import '../../l10n/app_localizations.dart';

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

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
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

  void _message(Object message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text('$message')));

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trainee.name),
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(text: l10n.trainerOverviewTab),
            Tab(text: l10n.trainerPlanTab),
            Tab(text: l10n.trainerHistoryTab),
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
              children: [_overview(), _plan(), _history()],
            ),
    );
  }

  Widget _overview() {
    final calendarDays = _showAllCalendarDays
        ? _data!.days
        : _data!.days.take(5);
    final hiddenDays = _data!.days.length - 5;
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
          for (final day in calendarDays) _dayCard(day),
          if (_data!.days.length > 5)
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

  Widget _plan() => TrainerResponsiveList(
    onRefresh: _load,
    children: [
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          FilledButton.icon(
            onPressed: _showCreatePlan,
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context)!.trainerCreateWorkoutPlan),
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
      if (_data!.plans.isEmpty)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(AppLocalizations.of(context)!.trainerNoPlans),
          ),
        ),
      for (final plan in _data!.plans)
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.event_note),
            title: Text(
              '${plan['title'] ?? AppLocalizations.of(context)!.trainerWorkoutPlanFallback}',
            ),
            subtitle: Text(
              '${_planStatusLabel(plan['status'])}${plan['starts_on'] == null ? '' : ' · ${plan['starts_on']}'}\n${plan['notes'] ?? ''}',
            ),
            isThreeLine: plan['notes'] != null,
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _deletePlan(plan),
            ),
          ),
        ),
      _sectionTitle(AppLocalizations.of(context)!.trainerWorkoutDays),
      for (final day in _data!.days) _dayCard(day),
    ],
  );

  Widget _history() => TrainerResponsiveList(
    onRefresh: _load,
    children: [
      _sectionTitle(AppLocalizations.of(context)!.trainerMaxTests),
      if (_data!.maxTests.isEmpty)
        Text(AppLocalizations.of(context)!.trainerNoMaxTests)
      else
        for (final test in _data!.maxTests)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.emoji_events),
              title: Text('${test['exercise']}'),
              subtitle: Text('${test['recorded_at'] ?? ''}'),
              trailing: Text('${test['value']} ${test['unit']}'),
            ),
          ),
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
                '${log['recorded_at'] ?? ''}${log['notes'] == null ? '' : ' · ${log['notes']}'}',
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
              title: Text('${payment['month_start']}'),
              subtitle: Text(
                payment['paid'] == true
                    ? AppLocalizations.of(context)!.trainerPaid
                    : AppLocalizations.of(context)!.trainerOverdue,
              ),
              trailing: Text(
                payment['amount'] == null ? '—' : '€${payment['amount']}',
              ),
            ),
          ),
    ],
  );

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

  String _planStatusLabel(Object? value) {
    final l10n = AppLocalizations.of(context)!;
    return switch ('$value'.toLowerCase()) {
      'inactive' => l10n.trainerPlanStatusInactive,
      'upcoming' => l10n.trainerPlanStatusUpcoming,
      'draft' => l10n.trainerPlanStatusDraft,
      'archived' => l10n.trainerPlanStatusArchived,
      _ => l10n.trainerPlanStatusActive,
    };
  }

  Widget _dayCard(Map<String, dynamic> day) {
    final exercises = trainerRelationRows(day['day_exercises']);
    final done = exercises.where((item) => item['completed'] == true).length;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(child: Text('${day['week'] ?? '—'}')),
        title: Text(
          '${day['title'] ?? day['day_code'] ?? AppLocalizations.of(context)!.trainerTrainingDayFallback}',
        ),
        subtitle: Text(
          AppLocalizations.of(
            context,
          )!.trainerExercisesCompleted(done, exercises.length),
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
    final traineeNotes = '${exercise['trainee_notes'] ?? ''}'.trim();
    final exerciseFeedback = '${exercise['exercise_feedback'] ?? ''}'.trim();
    return [
      result,
      if (traineeNotes.isNotEmpty) l10n.trainerTraineeNote(traineeNotes),
      if (exerciseFeedback.isNotEmpty)
        l10n.trainerTraineeExerciseFeedback(exerciseFeedback),
    ].join('\n');
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
    final path = file.path;
    final bytes = file.bytes;
    if (path == null && bytes == null) {
      _message(l10n.trainerPdfPathUnavailable);
      return;
    }

    setState(() => _importingPdf = true);
    try {
      final importer = const TrainerPdfImportService();
      final imported = bytes != null
          ? await importer.readBytes(bytes, file.name)
          : await importer.read(path!, file.name);
      if (!mounted) return;
      final confirmed = await _showPdfPreview(imported);
      if (confirmed == null || !mounted) return;
      await widget.repository.createImportedPlan(widget.trainee.id, confirmed);
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
                            day.week,
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
