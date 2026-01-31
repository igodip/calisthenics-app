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
                    l10n.traineeFeedbackSharedTitle,
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
                l10n.traineeFeedbackEmpty,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              ..._feedbacks.map(
                (feedback) => _FeedbackCard(
                  feedback: feedback,
                  onDelete: () => _confirmDeleteFeedback(feedback),
                ),
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

    setState(() {
      _isSubmitting = true;
    });

    try {
      await client.from('trainee_feedbacks').insert({
        'trainee_id': userId,
        'message': feedback,
      });
      if (!mounted) return;
      _feedbackController.clear();
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
          .select('id, message, created_at, read_at')
          .eq('trainee_id', userId)
          .order('created_at', ascending: false);
      final entries = (response as List<dynamic>).map((row) {
        return _FeedbackEntry(
          id: row['id'] as String,
          message: row['message'] as String? ?? '',
          createdAt: DateTime.parse(row['created_at'] as String),
          readAt: row['read_at'] == null
              ? null
              : DateTime.parse(row['read_at'] as String),
        );
      }).toList();
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

  Future<void> _confirmDeleteFeedback(_FeedbackEntry feedback) async {
    final l10n = AppLocalizations.of(context)!;
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.traineeFeedbackDeleteConfirmTitle),
            content: Text(l10n.traineeFeedbackDeleteConfirmBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.traineeFeedbackDelete),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) return;
    await _deleteFeedback(feedback);
  }

  Future<void> _deleteFeedback(_FeedbackEntry feedback) async {
    final l10n = AppLocalizations.of(context)!;
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.unauthenticated)),
      );
      return;
    }

    try {
      await client
          .from('trainee_feedbacks')
          .delete()
          .eq('id', feedback.id)
          .eq('trainee_id', userId);
      if (!mounted) return;
      setState(() {
        _feedbacks = _feedbacks.where((item) => item.id != feedback.id).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.traineeFeedbackDeleteSuccess)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.unexpectedError('$error'))),
      );
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
  final DateTime createdAt;
  final DateTime? readAt;

  const _FeedbackEntry({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.readAt,
  });
}

class _FeedbackCard extends StatelessWidget {
  final _FeedbackEntry feedback;
  final VoidCallback onDelete;

  const _FeedbackCard({
    required this.feedback,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dateText = DateFormat.yMMMd(l10n.localeName).format(feedback.createdAt);
    final isRead = feedback.readAt != null;

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
                  label: Text(
                    isRead ? l10n.traineeFeedbackRead : l10n.traineeFeedbackUnread,
                  ),
                  backgroundColor: isRead
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.secondaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    dateText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: l10n.traineeFeedbackDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
