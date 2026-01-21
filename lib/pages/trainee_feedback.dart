import 'package:flutter/material.dart';
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
      appBar: AppBar(
        title: Text(l10n.traineeFeedbackTitle),
      ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.traineeFeedbackSubmitted)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.unexpectedError('$error'))),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
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
