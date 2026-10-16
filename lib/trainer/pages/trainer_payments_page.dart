import 'package:flutter/material.dart';

import '../trainer_models.dart';
import '../components/trainer_responsive_list.dart';
import '../../l10n/app_localizations.dart';

class TrainerPaymentsPage extends StatefulWidget {
  const TrainerPaymentsPage({
    super.key,
    required this.trainees,
    required this.onSave,
    required this.onRefresh,
  });
  final List<TrainerTrainee> trainees;
  final Future<void> Function(
    TrainerTrainee trainee,
    bool paid,
    double? amount,
    String notes,
  )
  onSave;
  final Future<void> Function() onRefresh;

  @override
  State<TrainerPaymentsPage> createState() => _TrainerPaymentsPageState();
}

class _TrainerPaymentsPageState extends State<TrainerPaymentsPage> {
  final Map<String, TextEditingController> _amounts = {};
  final Map<String, TextEditingController> _notes = {};
  final Set<String> _saving = {};
  final Map<String, String> _amountErrors = {};

  @override
  void didUpdateWidget(TrainerPaymentsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previous = {
      for (final trainee in oldWidget.trainees) trainee.id: trainee,
    };
    for (final trainee in widget.trainees) {
      final old = previous[trainee.id];
      if (old == null || _saving.contains(trainee.id)) continue;
      final newMonth = old.paymentMonth != trainee.paymentMonth;
      final amount = _amounts[trainee.id];
      if (amount != null &&
          (newMonth ||
              amount.text == (old.paymentAmount?.toStringAsFixed(2) ?? ''))) {
        amount.text = trainee.paymentAmount?.toStringAsFixed(2) ?? '';
      }
      final notes = _notes[trainee.id];
      if (notes != null &&
          (newMonth || notes.text.trim() == old.paymentNotes.trim())) {
        notes.text = trainee.paymentNotes;
      }
    }
  }

  TextEditingController _controller(TrainerTrainee trainee) =>
      _amounts.putIfAbsent(
        trainee.id,
        () => TextEditingController(
          text: trainee.paymentAmount?.toStringAsFixed(2) ?? '',
        ),
      );

  TextEditingController _notesController(TrainerTrainee trainee) =>
      _notes.putIfAbsent(
        trainee.id,
        () => TextEditingController(text: trainee.paymentNotes),
      );

  @override
  void dispose() {
    for (final controller in _amounts.values) {
      controller.dispose();
    }
    for (final controller in _notes.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save(TrainerTrainee trainee, bool paid) async {
    if (_saving.contains(trainee.id)) return;
    final text = _controller(trainee).text.trim().replaceAll(',', '.');
    final amount = text.isEmpty ? null : double.tryParse(text);
    if (text.isNotEmpty && (amount == null || !amount.isFinite || amount < 0)) {
      setState(
        () => _amountErrors[trainee.id] = AppLocalizations.of(
          context,
        )!.trainerPaymentAmountInvalid,
      );
      return;
    }
    _amountErrors.remove(trainee.id);
    setState(() => _saving.add(trainee.id));
    try {
      await widget.onSave(
        trainee,
        paid,
        amount,
        _notesController(trainee).text,
      );
    } catch (_) {
      // The parent reports repository failures; keep the draft available to retry.
    } finally {
      if (mounted) setState(() => _saving.remove(trainee.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final paid = widget.trainees.where((item) => item.paid).length;
    final total = widget.trainees.fold<double>(
      0,
      (sum, item) => sum + (item.paid ? item.paymentAmount ?? 0 : 0),
    );
    return TrainerResponsiveList(
      onRefresh: widget.onRefresh,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              alignment: WrapAlignment.spaceAround,
              runAlignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 16,
              children: [
                _Summary(
                  label: l10n.trainerPaid,
                  value: '$paid/${widget.trainees.length}',
                ),
                _Summary(
                  label: l10n.trainerOverdue,
                  value: '${widget.trainees.length - paid}',
                ),
                _Summary(
                  label: l10n.trainerReceived,
                  value: '€${total.toStringAsFixed(2)}',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final trainee in widget.trainees)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          trainee.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Chip(
                        label: Text(
                          trainee.paid ? l10n.trainerPaid : l10n.trainerOverdue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _controller(trainee),
                    enabled: !_saving.contains(trainee.id),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.trainerMonthlyAmount,
                      prefixText: '€ ',
                      errorText: _amountErrors[trainee.id],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController(trainee),
                    enabled: !_saving.contains(trainee.id),
                    minLines: 2,
                    maxLines: 4,
                    maxLength: 2000,
                    decoration: InputDecoration(
                      labelText: l10n.trainerPaymentNotes,
                      alignLabelWithHint: true,
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.trainerAppAccessActive),
                    value: trainee.paid,
                    onChanged: _saving.contains(trainee.id)
                        ? null
                        : (value) => _save(trainee, value),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: _saving.contains(trainee.id)
                          ? null
                          : () => _save(trainee, trainee.paid),
                      icon: _saving.contains(trainee.id)
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(l10n.trainerSave),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}
