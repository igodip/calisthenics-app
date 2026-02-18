import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_localizations.dart';

class TraineeFeedbackPage extends StatefulWidget {
  const TraineeFeedbackPage({super.key});

  @override
  State<TraineeFeedbackPage> createState() => _TraineeFeedbackPageState();
}

class _TraineeFeedbackPageState extends State<TraineeFeedbackPage> {
  final _feedbackController = TextEditingController();
  int? _selectedFeeling;
  bool _isSubmitting = false;
  bool _isLoadingFeedbacks = false;
  String? _feedbacksError;
  List<_FeedbackEntry> _feedbacks = [];
  bool _didLoadFeedbacks = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadFeedbacks) return;
    _didLoadFeedbacks = true;
    _loadFeedbacks();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.traineeFeedbackSubtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _FeedbackFieldCard(
              label: l10n.traineeFeedbackQuestionLabel,
              hintText: l10n.traineeFeedbackQuestionHint,
              controller: _feedbackController,
              minLines: 4,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _isSubmitting ? null : _submitFeedback,
              icon: const Icon(Icons.send),
              label: Text(l10n.traineeFeedbackSubmit),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.traineeFeedbackAnsweredTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _isLoadingFeedbacks ? null : _loadFeedbacks,
                  icon: const Icon(Icons.refresh),
                  tooltip: l10n.refresh,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoadingFeedbacks)
              const Center(child: CircularProgressIndicator())
            else if (_feedbacksError != null)
              Text(
                _feedbacksError!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              )
            else if (_feedbacks.isEmpty)
              Text(
                l10n.traineeFeedbackAnsweredEmpty,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              ..._feedbacks.map(
                (feedback) => _FeedbackCard(feedback: feedback),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitFeedback() async {
    final l10n = AppLocalizations.of(context)!;
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.unauthenticated)),
      );
      return;
    }

    final feedback = _feedbackController.text.trim();
    if (feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.missingFieldsError)),
      );
      return;
    }
    if (_selectedFeeling == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.traineeFeedbackFeelingRequired)),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await client.from('trainee_feedbacks').insert({
        'trainee_id': userId,
        'message': feedback,
        'feeling': _selectedFeeling,
      });
      if (!mounted) return;
      _feedbackController.clear();
      setState(() {
        _selectedFeeling = null;
      });
      await _loadFeedbacks();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.traineeFeedbackSubmitted)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.unexpectedError('$error'))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _loadFeedbacks() async {
    final l10n = AppLocalizations.of(context)!;
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      setState(() {
        _feedbacksError = l10n.unauthenticated;
        _feedbacks = [];
      });
      return;
    }

    setState(() {
      _isLoadingFeedbacks = true;
      _feedbacksError = null;
    });

    try {
      final response = await client
          .from('trainee_feedbacks')
          .select('id, message, feeling, created_at, read_at, answer_message, answered_at')
          .eq('trainee_id', userId)
          .order('created_at', ascending: false);
      final entries = (response as List<dynamic>).map((row) {
        return _FeedbackEntry(
          id: row['id'] as String,
          message: row['message'] as String? ?? '',
          feeling: row['feeling'] as int?,
          createdAt: DateTime.parse(row['created_at'] as String),
          readAt: row['read_at'] == null
              ? null
              : DateTime.parse(row['read_at'] as String),
          answerMessage: (row['answer_message'] as String?)?.trim(),
          answeredAt: row['answered_at'] == null
              ? null
              : DateTime.parse(row['answered_at'] as String),
        );
      }).where((entry) => entry.answeredAt != null).toList();
      if (!mounted) return;
      setState(() {
        _feedbacks = entries;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _feedbacksError = l10n.traineeFeedbackLoadFailed;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFeedbacks = false;
        });
      }
    }
  }


}

class _FeedbackFieldCard extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final int minLines;

  const _FeedbackFieldCard({
    required this.label,
    required this.hintText,
    required this.controller,
    this.minLines = 3,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              minLines: minLines,
              maxLines: minLines + 2,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: hintText,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackEntry {
  final String id;
  final String message;
  final int? feeling;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? answerMessage;
  final DateTime? answeredAt;

  const _FeedbackEntry({
    required this.id,
    required this.message,
    required this.feeling,
    required this.createdAt,
    required this.readAt,
    required this.answerMessage,
    required this.answeredAt,
  });
}

class _FeedbackCard extends StatelessWidget {
  final _FeedbackEntry feedback;

  const _FeedbackCard({
    required this.feedback,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final sentText = DateFormat.yMMMd(l10n.localeName).format(feedback.createdAt);
    final answeredText = feedback.answeredAt == null
        ? null
        : DateFormat.yMMMd(l10n.localeName).add_Hm().format(feedback.answeredAt!);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              feedback.message,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Chip(
                  label: Text(l10n.traineeFeedbackAnsweredChip),
                  backgroundColor: theme.colorScheme.primaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${l10n.traineeFeedbackSentAt} $sentText',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            if (answeredText != null) ...[
              const SizedBox(height: 8),
              Text(
                '${l10n.traineeFeedbackAnsweredAt} $answeredText',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if ((feedback.answerMessage ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                l10n.traineeFeedbackTrainerAnswer,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(feedback.answerMessage!, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}
