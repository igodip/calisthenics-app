import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../trainer_models.dart';
import '../../l10n/app_localizations.dart';

class TrainerFeedbackCard extends StatefulWidget {
  const TrainerFeedbackCard({
    super.key,
    required this.feedback,
    required this.onToggleRead,
    required this.onAnswer,
    required this.onDelete,
  });

  final TrainerFeedback feedback;
  final Future<void> Function(bool value) onToggleRead;
  final Future<void> Function(String answer) onAnswer;
  final Future<void> Function() onDelete;

  @override
  State<TrainerFeedbackCard> createState() => _TrainerFeedbackCardState();
}

class _TrainerFeedbackCardState extends State<TrainerFeedbackCard> {
  final _answer = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _saving = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.trainerDeleteFeedbackTitle),
            content: Text(
              l10n.trainerDeleteFeedbackMessage(widget.feedback.traineeName),
            ),
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
        ) ??
        false;
    if (confirmed && mounted) await _run(widget.onDelete);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.feedback;
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 4,
              children: [
                Text(
                  item.traineeName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: Text(
                        item.isRead
                            ? l10n.trainerStatusRead
                            : l10n.trainerStatusUnread,
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.trainerDeleteFeedback,
                      onPressed: _saving ? null : _confirmDelete,
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ],
            ),
            if (item.createdAt != null)
              Text(
                DateFormat.yMMMd().add_Hm().format(item.createdAt!.toLocal()),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 12),
            Text(item.message),
            if (item.isAnswered) ...[
              const Divider(height: 28),
              Text(
                l10n.trainerYourAnswer,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              Text(item.answer),
            ] else ...[
              const SizedBox(height: 12),
              TextField(
                controller: _answer,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(labelText: l10n.trainerReplyHint),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: _saving
                      ? null
                      : () => _run(() => widget.onAnswer(_answer.text.trim())),
                  icon: const Icon(Icons.send),
                  label: Text(l10n.trainerSendAnswer),
                ),
              ),
            ],
            TextButton(
              onPressed: _saving
                  ? null
                  : () => _run(() => widget.onToggleRead(!item.isRead)),
              child: Text(
                item.isRead ? l10n.trainerMarkUnread : l10n.trainerMarkRead,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
