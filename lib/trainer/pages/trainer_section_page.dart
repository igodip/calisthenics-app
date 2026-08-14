import 'package:flutter/material.dart';

import '../trainer_models.dart';
import '../trainer_repository.dart';
import 'trainer_dashboard_page.dart';
import 'trainer_feedback_page.dart';
import 'trainer_payments_page.dart';
import 'trainer_program_page.dart';
import 'trainer_trainees_page.dart';
import '../../l10n/app_localizations.dart';

enum TrainerSection { dashboard, trainees, feedback, payments }

class TrainerSectionPage extends StatefulWidget {
  const TrainerSectionPage({super.key, required this.section});

  final TrainerSection section;

  @override
  State<TrainerSectionPage> createState() => _TrainerSectionPageState();
}

class _TrainerSectionPageState extends State<TrainerSectionPage> {
  final _repository = TrainerRepository();
  bool _loading = true;
  Object? _error;
  List<TrainerTrainee> _trainees = const [];
  List<TrainerFeedback> _feedback = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final trainees = await _repository.loadTrainees();
      final feedback = await _repository.loadFeedback(trainees);
      if (mounted) {
        setState(() {
          _trainees = trainees;
          _feedback = feedback;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$error')));
  }

  Future<void> _openTrainee(TrainerTrainee trainee) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TrainerProgramPage(
          trainee: trainee,
          allTrainees: _trainees,
          repository: _repository,
          onTraineeChanged: (updated) {
            setState(() {
              _trainees = _trainees
                  .map((item) => item.id == updated.id ? updated : item)
                  .toList();
            });
          },
        ),
      ),
    );
    await _load();
  }

  Future<void> _toggleRead(TrainerFeedback item, bool value) async {
    try {
      await _repository.setFeedbackRead(item.id, value);
      setState(() {
        _feedback = _feedback.map((entry) {
          return entry.id == item.id
              ? entry.copyWith(
                  readAt: value ? DateTime.now() : null,
                  clearReadAt: !value,
                )
              : entry;
        }).toList();
      });
    } catch (error) {
      _showError(error);
      rethrow;
    }
  }

  Future<void> _answer(TrainerFeedback item, String answer) async {
    try {
      await _repository.answerFeedback(item.id, answer);
      setState(() {
        _feedback = _feedback.map((entry) {
          return entry.id == item.id
              ? entry.copyWith(answer: answer, answeredAt: DateTime.now())
              : entry;
        }).toList();
      });
    } catch (error) {
      _showError(error);
      rethrow;
    }
  }

  Future<void> _deleteFeedback(TrainerFeedback item) async {
    final previousFeedback = _feedback;
    setState(() {
      _feedback = _feedback.where((entry) => entry.id != item.id).toList();
    });
    try {
      await _repository.deleteFeedback(item.id);
    } catch (error) {
      if (mounted) setState(() => _feedback = previousFeedback);
      _showError(error);
      rethrow;
    }
  }

  Future<void> _savePayment(
    TrainerTrainee trainee,
    bool paid,
    double? amount,
  ) async {
    try {
      await _repository.savePayment(trainee.id, paid: paid, amount: amount);
      setState(() {
        _trainees = _trainees.map((entry) {
          return entry.id == trainee.id
              ? entry.copyWith(paid: paid, paymentAmount: amount)
              : entry;
        }).toList();
      });
    } catch (error) {
      _showError(error);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading && _trainees.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _trainees.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.trainerLoadToolsError('$_error'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton(onPressed: _load, child: Text(l10n.trainerRetry)),
            ],
          ),
        ),
      );
    }

    return switch (widget.section) {
      TrainerSection.dashboard => TrainerDashboardPage(
        trainees: _trainees,
        feedback: _feedback,
        onOpenTrainee: _openTrainee,
        onRefresh: _load,
      ),
      TrainerSection.trainees => TrainerTraineesPage(
        trainees: _trainees,
        onOpen: _openTrainee,
        onRefresh: _load,
      ),
      TrainerSection.feedback => TrainerFeedbackPage(
        feedback: _feedback,
        onToggleRead: _toggleRead,
        onAnswer: _answer,
        onDelete: _deleteFeedback,
        onRefresh: _load,
      ),
      TrainerSection.payments => TrainerPaymentsPage(
        trainees: _trainees,
        onSave: _savePayment,
        onRefresh: _load,
      ),
    };
  }
}
