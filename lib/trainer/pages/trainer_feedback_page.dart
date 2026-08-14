import 'package:flutter/material.dart';

import '../components/trainer_feedback_card.dart';
import '../components/trainer_responsive_list.dart';
import '../trainer_models.dart';
import '../../l10n/app_localizations.dart';

enum TrainerFeedbackFilter { all, unread, answered }

class TrainerFeedbackPage extends StatefulWidget {
  const TrainerFeedbackPage({
    super.key,
    required this.feedback,
    required this.onToggleRead,
    required this.onAnswer,
    required this.onDelete,
    required this.onRefresh,
  });
  final List<TrainerFeedback> feedback;
  final Future<void> Function(TrainerFeedback item, bool value) onToggleRead;
  final Future<void> Function(TrainerFeedback item, String answer) onAnswer;
  final Future<void> Function(TrainerFeedback item) onDelete;
  final Future<void> Function() onRefresh;

  @override
  State<TrainerFeedbackPage> createState() => _TrainerFeedbackPageState();
}

class _TrainerFeedbackPageState extends State<TrainerFeedbackPage> {
  TrainerFeedbackFilter filter = TrainerFeedbackFilter.unread;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final visible = widget.feedback
        .where(
          (item) => switch (filter) {
            TrainerFeedbackFilter.all => true,
            TrainerFeedbackFilter.unread => !item.isRead,
            TrainerFeedbackFilter.answered => item.isAnswered,
          },
        )
        .toList();
    return TrainerResponsiveList(
      onRefresh: widget.onRefresh,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in TrainerFeedbackFilter.values)
              ChoiceChip(
                label: Text(switch (option) {
                  TrainerFeedbackFilter.all => l10n.trainerFilterAll,
                  TrainerFeedbackFilter.unread => l10n.trainerFilterUnread,
                  TrainerFeedbackFilter.answered => l10n.trainerFilterAnswered,
                }),
                selected: filter == option,
                onSelected: (_) => setState(() => filter = option),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (visible.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.trainerNoFeedbackInView),
            ),
          ),
        for (final item in visible)
          TrainerFeedbackCard(
            key: ValueKey('${item.id}-${item.readAt}-${item.answeredAt}'),
            feedback: item,
            onToggleRead: (value) => widget.onToggleRead(item, value),
            onAnswer: (answer) {
              if (answer.isEmpty) {
                throw ArgumentError(l10n.trainerAnswerRequired);
              }
              return widget.onAnswer(item, answer);
            },
            onDelete: () => widget.onDelete(item),
          ),
      ],
    );
  }
}
