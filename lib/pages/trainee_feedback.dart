import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class TraineeFeedbackPage extends StatefulWidget {
  const TraineeFeedbackPage({super.key});

  @override
  State<TraineeFeedbackPage> createState() => _TraineeFeedbackPageState();
}

class _TraineeFeedbackPageState extends State<TraineeFeedbackPage> {
  final _highlightsController = TextEditingController();
  final _challengesController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _highlightsController.dispose();
    _challengesController.dispose();
    _notesController.dispose();
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
              label: l10n.traineeFeedbackHighlightsLabel,
              hintText: l10n.traineeFeedbackHighlightsHint,
              controller: _highlightsController,
            ),
            const SizedBox(height: 12),
            _FeedbackFieldCard(
              label: l10n.traineeFeedbackChallengesLabel,
              hintText: l10n.traineeFeedbackChallengesHint,
              controller: _challengesController,
            ),
            const SizedBox(height: 12),
            _FeedbackFieldCard(
              label: l10n.traineeFeedbackNotesLabel,
              hintText: l10n.traineeFeedbackNotesHint,
              controller: _notesController,
              minLines: 4,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                _highlightsController.clear();
                _challengesController.clear();
                _notesController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.traineeFeedbackSubmitted)),
                );
              },
              icon: const Icon(Icons.send),
              label: Text(l10n.traineeFeedbackSubmit),
            ),
          ],
        ),
      ),
    );
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
