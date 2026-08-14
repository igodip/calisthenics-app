import 'package:flutter/material.dart';

import '../components/trainer_trainee_card.dart';
import '../components/trainer_responsive_list.dart';
import '../trainer_models.dart';
import '../../l10n/app_localizations.dart';

class TrainerTraineesPage extends StatefulWidget {
  const TrainerTraineesPage({
    super.key,
    required this.trainees,
    required this.onOpen,
    required this.onRefresh,
  });
  final List<TrainerTrainee> trainees;
  final ValueChanged<TrainerTrainee> onOpen;
  final Future<void> Function() onRefresh;

  @override
  State<TrainerTraineesPage> createState() => _TrainerTraineesPageState();
}

class _TrainerTraineesPageState extends State<TrainerTraineesPage> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final visible = widget.trainees
        .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return TrainerResponsiveList(
      onRefresh: widget.onRefresh,
      children: [
        TextField(
          onChanged: (value) => setState(() => query = value),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            labelText: l10n.trainerSearchTrainees,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.trainerAssignedCount(visible.length),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        if (visible.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.trainerNoMatchingTrainees),
            ),
          ),
        for (final trainee in visible)
          TrainerTraineeCard(
            trainee: trainee,
            onOpen: () => widget.onOpen(trainee),
          ),
      ],
    );
  }
}
