import 'package:flutter/material.dart';

import '../components/trainer_metric_card.dart';
import '../components/trainer_responsive_list.dart';
import '../components/trainer_trainee_card.dart';
import '../trainer_models.dart';
import '../../l10n/app_localizations.dart';

class TrainerDashboardPage extends StatelessWidget {
  const TrainerDashboardPage({
    super.key,
    required this.trainees,
    required this.feedback,
    required this.onOpenTrainee,
    required this.onRefresh,
  });

  final List<TrainerTrainee> trainees;
  final List<TrainerFeedback> feedback;
  final ValueChanged<TrainerTrainee> onOpenTrainee;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final paid = trainees.where((item) => item.paid).length;
    final unread = feedback.where((item) => !item.isRead).length;
    return TrainerResponsiveList(
      onRefresh: onRefresh,
      children: [
        Text(
          l10n.trainerWorkspaceTitle,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.trainerWorkspaceSubtitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth >= 680
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: width,
                  child: TrainerMetricCard(
                    icon: Icons.groups,
                    label: l10n.trainerAssignedTrainees,
                    value: '${trainees.length}',
                  ),
                ),
                SizedBox(
                  width: width,
                  child: TrainerMetricCard(
                    icon: Icons.mark_email_unread,
                    label: l10n.trainerUnreadFeedback,
                    value: '$unread',
                  ),
                ),
                SizedBox(
                  width: width,
                  child: TrainerMetricCard(
                    icon: Icons.verified_user,
                    label: l10n.trainerActivePlans,
                    value: '$paid',
                  ),
                ),
                SizedBox(
                  width: width,
                  child: TrainerMetricCard(
                    icon: Icons.pending_actions,
                    label: l10n.trainerOverdue,
                    value: '${trainees.length - paid}',
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        Text(
          l10n.trainerTraineesTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        if (trainees.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.trainerNoAssignedTrainees),
            ),
          ),
        for (final trainee in trainees.take(6))
          TrainerTraineeCard(
            trainee: trainee,
            onOpen: () => onOpenTrainee(trainee),
          ),
      ],
    );
  }
}
