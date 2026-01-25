import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

enum TimerMode { simple, amrap }

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  final _amrapDurationController = TextEditingController(text: '12');
  final _countdownMinutesController = TextEditingController(text: '3');
  final _countdownSecondsController = TextEditingController(text: '0');

  Timer? _amrapTimer;
  Timer? _countdownTimer;

  bool _amrapRunning = false;
  int _amrapTimeRemaining = 0;

  bool _countdownRunning = false;
  int _countdownTimeRemaining = 0;

  TimerMode? _activeTimerMode;

  @override
  void dispose() {
    _amrapTimer?.cancel();
    _countdownTimer?.cancel();
    _amrapDurationController.dispose();
    _countdownMinutesController.dispose();
    _countdownSecondsController.dispose();
    super.dispose();
  }

  void _startAmrap() {
    final durationMinutes = int.tryParse(_amrapDurationController.text) ?? 10;
    final durationSeconds = durationMinutes * 60;

    _amrapTimer?.cancel();
    setState(() {
      _amrapRunning = true;
      _amrapTimeRemaining = durationSeconds;
      _activeTimerMode = TimerMode.amrap;
    });

    _amrapTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_amrapTimeRemaining > 1) {
        setState(() {
          _amrapTimeRemaining -= 1;
        });
      } else {
        timer.cancel();
        setState(() {
          _amrapRunning = false;
          _amrapTimeRemaining = 0;
          _activeTimerMode = null;
        });
      }
    });
  }

  void _resetAmrap() {
    _amrapTimer?.cancel();
    setState(() {
      _amrapRunning = false;
      _amrapTimeRemaining = 0;
      _activeTimerMode = null;
    });
  }

  void _startCountdown() {
    final minutes = int.tryParse(_countdownMinutesController.text) ?? 0;
    final seconds = int.tryParse(_countdownSecondsController.text) ?? 0;
    final totalSeconds = (minutes * 60) + seconds;

    _countdownTimer?.cancel();
    setState(() {
      _countdownRunning = true;
      _countdownTimeRemaining = totalSeconds;
      _activeTimerMode = TimerMode.simple;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownTimeRemaining > 1) {
        setState(() {
          _countdownTimeRemaining -= 1;
        });
      } else {
        timer.cancel();
        setState(() {
          _countdownRunning = false;
          _countdownTimeRemaining = 0;
          _activeTimerMode = null;
        });
      }
    });
  }

  void _resetCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _countdownRunning = false;
      _countdownTimeRemaining = 0;
      _activeTimerMode = null;
    });
  }

  String _formatSeconds(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildFullscreenTimer(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isAmrap = _activeTimerMode == TimerMode.amrap;
    final timeRemaining =
        isAmrap ? _amrapTimeRemaining : _countdownTimeRemaining;
    final title = isAmrap ? l10n.amrapTimerTitle : l10n.countdownTitle;
    final actionLabel =
        isAmrap ? l10n.amrapResetButton : l10n.countdownResetButton;
    final onStop = isAmrap ? _resetAmrap : _resetCountdown;

    return Positioned.fill(
      child: Material(
        color: theme.colorScheme.surface,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final timeFontSize =
                    (constraints.maxWidth * 0.18).clamp(48, 160).toDouble();
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.amrapTimeRemainingLabel,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: onStop,
                            child: Text(actionLabel),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Center(
                        child: Text(
                          _countdownRunning || _amrapRunning
                              ? _formatSeconds(timeRemaining)
                              : '--:--',
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: timeFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: TabBar(
                  indicatorColor: theme.colorScheme.primary,
                  labelColor: theme.colorScheme.primary,
                  tabs: [
                    Tab(text: l10n.countdownTitle),
                    Tab(text: l10n.amrapTimerTitle),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text(
                          l10n.countdownSubtitle,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.countdownDescription,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildNumberField(
                                controller: _countdownMinutesController,
                                label: l10n.countdownMinutesLabel,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildNumberField(
                                controller: _countdownSecondsController,
                                label: l10n.countdownSecondsLabel,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _countdownRunning
                              ? _formatSeconds(_countdownTimeRemaining)
                              : '--:--',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed:
                                    _countdownRunning ? null : _startCountdown,
                                child: Text(l10n.countdownStartButton),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _resetCountdown,
                                child: Text(l10n.countdownResetButton),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text(
                          l10n.amrapTimerSubtitle,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.amrapTimerDescription,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        _buildNumberField(
                          controller: _amrapDurationController,
                          label: l10n.amrapDurationLabel,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.amrapTimeRemainingLabel,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _amrapRunning
                              ? _formatSeconds(_amrapTimeRemaining)
                              : '--:--',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: _amrapRunning ? null : _startAmrap,
                                child: Text(l10n.amrapStartButton),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _resetAmrap,
                                child: Text(l10n.amrapResetButton),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_activeTimerMode != null) _buildFullscreenTimer(context),
        ],
      ),
    );
  }
}
