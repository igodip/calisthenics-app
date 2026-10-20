import 'package:flutter/material.dart';

import '../data/bug_report_repository.dart';
import '../l10n/app_localizations.dart';

class BugReportPage extends StatefulWidget {
  const BugReportPage({super.key});

  @override
  State<BugReportPage> createState() => _BugReportPageState();
}

class _BugReportPageState extends State<BugReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stepsController = TextEditingController();
  final _expectedController = TextEditingController();
  final _actualController = TextEditingController();
  final _repository = BugReportRepository();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _stepsController.dispose();
    _expectedController.dispose();
    _actualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bugReportTitle)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _textField(
                controller: _titleController,
                label: l10n.bugReportTitleLabel,
                hint: l10n.bugReportTitleHint,
                required: true,
              ),
              const SizedBox(height: 16),
              _textField(
                controller: _descriptionController,
                label: l10n.bugReportDescriptionLabel,
                hint: l10n.bugReportDescriptionHint,
                required: true,
                minLines: 4,
              ),
              const SizedBox(height: 16),
              _textField(
                controller: _stepsController,
                label: l10n.bugReportStepsLabel,
                hint: l10n.bugReportStepsHint,
                minLines: 3,
              ),
              const SizedBox(height: 16),
              _textField(
                controller: _expectedController,
                label: l10n.bugReportExpectedResultLabel,
                hint: l10n.bugReportExpectedResultHint,
                minLines: 2,
              ),
              const SizedBox(height: 16),
              _textField(
                controller: _actualController,
                label: l10n.bugReportActualResultLabel,
                hint: l10n.bugReportActualResultHint,
                minLines: 2,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(l10n.bugReportSubmit),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool required = false,
    int minLines = 1,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: minLines == 1 ? 1 : null,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: minLines > 1,
        border: const OutlineInputBorder(),
      ),
      validator: required
          ? (value) => value == null || value.trim().isEmpty
                ? l10n.bugReportRequired
                : null
          : null,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSubmitting = true);
    try {
      await _repository.createBugReport(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        reproductionSteps: _optionalText(_stepsController),
        expectedBehavior: _optionalText(_expectedController),
        actualBehavior: _optionalText(_actualController),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.bugReportSubmitError('$error'))),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String? _optionalText(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }
}
