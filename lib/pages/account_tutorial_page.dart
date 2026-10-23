import 'package:flutter/material.dart';

import '../data/account_access.dart';
import '../l10n/app_localizations.dart';

typedef _TutorialStep = ({IconData icon, String title, String body});

class AccountTutorialPage extends StatefulWidget {
  const AccountTutorialPage({
    super.key,
    required this.access,
    required this.onComplete,
  });
  final AccountAccess access;
  final Future<void> Function(bool skipped) onComplete;

  @override
  State<AccountTutorialPage> createState() => _AccountTutorialPageState();
}

class _AccountTutorialPageState extends State<AccountTutorialPage> {
  final _scroll = ScrollController();
  int _index = 0;
  bool _saving = false;

  List<_TutorialStep> _steps(AppLocalizations l) => [
    (
      icon: Icons.waving_hand_outlined,
      title: l.tutorialWelcomeTitle,
      body: l.tutorialWelcomeBody,
    ),
    if (!widget.access.hasTrainingAccess)
      (
        icon: Icons.hourglass_empty,
        title: l.waitingForTrainerTitle,
        body: l.waitingForTrainerDescription,
      ),
    if (widget.access.isTrainer) ...[
      (
        icon: Icons.groups_outlined,
        title: l.trainerNavTrainees,
        body: l.tutorialTrainerTrainees,
      ),
      (
        icon: Icons.calendar_month_outlined,
        title: l.workoutPlanTitle,
        body: l.tutorialTrainerPlans,
      ),
      (
        icon: Icons.insights_outlined,
        title: l.trainerMaxTests,
        body: l.tutorialTrainerProgress,
      ),
      (
        icon: Icons.payments_outlined,
        title: l.trainerNavPayments,
        body: l.tutorialTrainerPayments,
      ),
    ] else if (widget.access.hasTrainingAccess) ...[
      (
        icon: Icons.calendar_month_outlined,
        title: l.workoutPlanTitle,
        body: l.tutorialTraineePlan,
      ),
      (
        icon: Icons.insights_outlined,
        title: l.profileMaxTestsTitle,
        body: l.tutorialTraineeProgress,
      ),
    ],
    (
      icon: Icons.chat_bubble_outline,
      title: widget.access.isTrainer
          ? l.trainerNavFeedback
          : l.traineeFeedbackTitle,
      body: widget.access.isTrainer
          ? l.tutorialTrainerFeedback
          : l.tutorialTraineeFeedback,
    ),
    (
      icon: Icons.menu_book_outlined,
      title: l.navGuides,
      body: l.tutorialGuides,
    ),
    if (widget.access.isAdmin)
      (
        icon: Icons.admin_panel_settings_outlined,
        title: l.adminNavConsole,
        body: l.tutorialAdmin,
      ),
    (
      icon: Icons.settings_outlined,
      title: l.accountSettingsTitle,
      body: l.tutorialAccount,
    ),
  ];

  Future<void> _complete(bool skipped) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await widget.onComplete(skipped);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.authOperationFailed),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _move(int delta) {
    setState(() => _index += delta);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final steps = _steps(l);
    final step = steps[_index.clamp(0, steps.length - 1)];
    final last = _index >= steps.length - 1;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_saving) {
          if (_index > 0) {
            _move(-1);
          } else {
            _complete(true);
          }
        }
      },
      child: Scaffold(
        key: const ValueKey('account-tutorial'),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(l.tutorialStep(_index + 1, steps.length)),
                        ),
                        TextButton(
                          key: const ValueKey('tutorial-skip'),
                          onPressed: _saving ? null : () => _complete(true),
                          child: Text(l.onboardingSkip),
                        ),
                      ],
                    ),
                  ),
                  LinearProgressIndicator(value: (_index + 1) / steps.length),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scroll,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Icon(
                                step.icon,
                                size: 56,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Semantics(
                            header: true,
                            child: Text(
                              step.title,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            step.body,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        if (_index > 0) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _saving ? null : () => _move(-1),
                              child: Text(
                                l.onboardingBack,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: FilledButton(
                            key: const ValueKey('tutorial-next'),
                            onPressed: _saving
                                ? null
                                : () => last ? _complete(false) : _move(1),
                            child: _saving
                                ? const SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    last ? l.tutorialFinish : l.onboardingNext,
                                    textAlign: TextAlign.center,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
