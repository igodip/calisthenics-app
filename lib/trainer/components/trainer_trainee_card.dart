import 'package:flutter/material.dart';

import '../trainer_models.dart';
import '../../l10n/app_localizations.dart';

class TrainerTraineeCard extends StatelessWidget {
  const TrainerTraineeCard({
    super.key,
    required this.trainee,
    required this.onOpen,
  });

  final TrainerTrainee trainee;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final identity = Row(
                    children: [
                      CircleAvatar(
                        child: Text(trainee.name.substring(0, 1).toUpperCase()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trainee.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              trainee.id,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                  final status = Chip(
                    avatar: Icon(
                      trainee.paid ? Icons.check_circle : Icons.lock_clock,
                      size: 16,
                    ),
                    label: Text(
                      trainee.paid
                          ? l10n.trainerStatusActive
                          : l10n.trainerOverdue,
                    ),
                    backgroundColor: trainee.paid
                        ? colors.primaryContainer
                        : colors.errorContainer,
                  );
                  if (constraints.maxWidth < 360) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [identity, const SizedBox(height: 8), status],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: identity),
                      status,
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 12,
                runSpacing: 4,
                children: [
                  Text(l10n.trainerPlanProgress),
                  Text(
                    '${trainee.progress}% · ${trainee.completedExercises}/${trainee.totalExercises}',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: trainee.totalExercises == 0
                    ? 0
                    : trainee.completedExercises / trainee.totalExercises,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(l10n.trainerOpenProgram),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
