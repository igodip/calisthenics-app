import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  final _emomSetsController = TextEditingController(text: '5');
  final _emomRepsController = TextEditingController(text: '10');
  final _emomIntervalController = TextEditingController(text: '60');
  final _amrapDurationController = TextEditingController(text: '12');
  final _countdownMinutesController = TextEditingController(text: '3');
  final _countdownSecondsController = TextEditingController(text: '0');

  Timer? _emomTimer;
  Timer? _amrapTimer;
  Timer? _countdownTimer;

  bool _emomRunning = false;
  bool _emomComplete = false;
  int _emomCurrentSet = 1;
  int _emomTimeRemaining = 0;

  bool _amrapRunning = false;
  int _amrapTimeRemaining = 0;

  bool _countdownRunning = false;
  int _countdownTimeRemaining = 0;

  @override
  void dispose() {
    _emomTimer?.cancel();
    _amrapTimer?.cancel();
    _countdownTimer?.cancel();
    _emomSetsController.dispose();
    _emomRepsController.dispose();
    _emomIntervalController.dispose();
    _amrapDurationController.dispose();
    _countdownMinutesController.dispose();
    _countdownSecondsController.dispose();
    super.dispose();
  }

  void _startEmom() {
    final totalSets = int.tryParse(_emomSetsController.text) ?? 1;
    final intervalSeconds = int.tryParse(_emomIntervalController.text) ?? 60;

    _emomTimer?.cancel();
    setState(() {
      _emomRunning = true;
      _emomComplete = false;
      _emomCurrentSet = 1;
      _emomTimeRemaining = intervalSeconds;
    });

    _emomTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_emomTimeRemaining > 1) {
        setState(() {
          _emomTimeRemaining -= 1;
        });
        return;
      }

      if (_emomCurrentSet < totalSets) {
        setState(() {
          _emomCurrentSet += 1;
          _emomTimeRemaining = intervalSeconds;
        });
      } else {
        timer.cancel();
        setState(() {
          _emomRunning = false;
          _emomComplete = true;
        });
      }
    });
  }

  void _resetEmom() {
    _emomTimer?.cancel();
    setState(() {
      _emomRunning = false;
      _emomComplete = false;
      _emomCurrentSet = 1;
      _emomTimeRemaining = 0;
    });
  }

  void _startAmrap() {
    final durationMinutes = int.tryParse(_amrapDurationController.text) ?? 10;
    final durationSeconds = durationMinutes * 60;

    _amrapTimer?.cancel();
    setState(() {
      _amrapRunning = true;
      _amrapTimeRemaining = durationSeconds;
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
        });
      }
    });
  }

  void _resetAmrap() {
    _amrapTimer?.cancel();
    setState(() {
      _amrapRunning = false;
      _amrapTimeRemaining = 0;
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
        });
      }
    });
  }

  void _resetCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _countdownRunning = false;
      _countdownTimeRemaining = 0;
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: TabBar(
              indicatorColor: theme.colorScheme.primary,
              labelColor: theme.colorScheme.primary,
              tabs: [
                Tab(text: l10n.emomTrackerTitle),
                Tab(text: l10n.amrapTimerTitle),
                Tab(text: l10n.countdownTitle),
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
                      l10n.emomTrackerSubtitle,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.emomTrackerDescription,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildNumberField(
                      controller: _emomSetsController,
                      label: l10n.emomSetsLabel,
                    ),
                    const SizedBox(height: 12),
                    _buildNumberField(
                      controller: _emomRepsController,
                      label: l10n.emomRepsLabel,
                    ),
                    const SizedBox(height: 12),
                    _buildNumberField(
                      controller: _emomIntervalController,
                      label: l10n.emomIntervalLabel,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _emomTimeRemaining > 0
                          ? l10n.emomTimeRemainingLabel
                          : l10n.emomPrepSubhead,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _emomRunning || _emomComplete
                          ? _formatSeconds(_emomTimeRemaining)
                          : '--:--',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.emomCurrentSet(
                        _emomCurrentSet,
                        int.tryParse(_emomSetsController.text) ?? 1,
                      ),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.emomRepsPerSet(
                        int.tryParse(_emomRepsController.text) ?? 0,
                      ),
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (_emomComplete) ...[
                      const SizedBox(height: 12),
                      Text(
                        l10n.emomFinishedMessage,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: _emomRunning ? null : _startEmom,
                            child: Text(l10n.emomStartButton),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _resetEmom,
                            child: Text(l10n.emomResetButton),
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
                            onPressed: _countdownRunning ? null : _startCountdown,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
