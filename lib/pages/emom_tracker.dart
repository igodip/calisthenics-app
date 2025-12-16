import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';

class EmomTrackerPage extends StatefulWidget {
  const EmomTrackerPage({super.key});

  @override
  State<EmomTrackerPage> createState() => _EmomTrackerPageState();
}

class _EmomTrackerPageState extends State<EmomTrackerPage> {
  static const _prepSeconds = 5;

  final _setsController = TextEditingController(text: '10');
  final _repsController = TextEditingController(text: '10');
  final _intervalController = TextEditingController(text: '60');

  int _totalSets = 10;
  int _repsPerSet = 10;
  int _intervalSeconds = 60;

  int _currentSet = 0;
  Duration _intervalRemaining = Duration.zero;
  int? _prepSecondsLeft;
  bool _sessionCompleted = false;

  Timer? _intervalTimer;
  Timer? _prepTimer;

  @override
  void dispose() {
    _intervalTimer?.cancel();
    _prepTimer?.cancel();
    _setsController.dispose();
    _repsController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  void _startSession() {
    if (_totalSets <= 0 || _repsPerSet <= 0 || _intervalSeconds <= 0) {
      return;
    }

    _intervalTimer?.cancel();
    _prepTimer?.cancel();

    setState(() {
      _sessionCompleted = false;
      _currentSet = 1;
      _intervalRemaining = Duration(seconds: _intervalSeconds);
    });

    _beginPrepCountdown();
  }

  void _beginPrepCountdown() {
    setState(() {
      _prepSecondsLeft = _prepSeconds;
    });

    _prepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final secondsLeft = _prepSecondsLeft;

      if (secondsLeft != null && secondsLeft > 1) {
        final nextValue = secondsLeft - 1;
        if (nextValue == 3) {
          _playPrepWarning();
        }

        setState(() {
          _prepSecondsLeft = nextValue;
        });
      } else {
        setState(() {
          _prepSecondsLeft = null;
        });
        timer.cancel();
        _startIntervalTimer();
      }
    });
  }

  void _playPrepWarning() {
    SystemSound.play(SystemSoundType.alert);
  }

  void _startIntervalTimer() {
    _intervalTimer?.cancel();
    setState(() {
      _intervalRemaining = Duration(seconds: _intervalSeconds);
    });

    _intervalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_intervalRemaining.inSeconds <= 1) {
        timer.cancel();
        _handleSetCompletion();
      } else {
        setState(() {
          _intervalRemaining -= const Duration(seconds: 1);
        });
      }
    });
  }

  void _handleSetCompletion() {
    if (_currentSet >= _totalSets) {
      setState(() {
        _sessionCompleted = true;
        _currentSet = 0;
      });
      return;
    }

    setState(() {
      _currentSet += 1;
      _intervalRemaining = Duration(seconds: _intervalSeconds);
    });

    _beginPrepCountdown();
  }

  void _resetSession() {
    _intervalTimer?.cancel();
    _prepTimer?.cancel();
    setState(() {
      _currentSet = 0;
      _intervalRemaining = Duration.zero;
      _prepSecondsLeft = null;
      _sessionCompleted = false;
    });
  }

  void _updateIntValue(String value, void Function(int) onValid) {
    final parsed = int.tryParse(value);
    if (parsed != null && parsed > 0) {
      onValid(parsed);
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: Text(l10n.emomTrackerTitle)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.emomTrackerTitle,
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.emomTrackerDescription,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _setsController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: l10n.emomSetsLabel,
                                ),
                                onChanged: (value) =>
                                    setState(() => _updateIntValue(value, (v) {
                                          _totalSets = v;
                                        })),
                                enabled: _currentSet == 0,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _repsController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: l10n.emomRepsLabel,
                                ),
                                onChanged: (value) =>
                                    setState(() => _updateIntValue(value, (v) {
                                          _repsPerSet = v;
                                        })),
                                enabled: _currentSet == 0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _intervalController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.emomIntervalLabel,
                          ),
                          onChanged: (value) =>
                              setState(() => _updateIntValue(value, (v) {
                                    _intervalSeconds = v;
                                  })),
                          enabled: _currentSet == 0,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed:
                                    _currentSet == 0 ? _startSession : null,
                                icon: const Icon(Icons.play_arrow),
                                label: Text(l10n.emomStartButton),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed:
                                    _currentSet > 0 || _sessionCompleted
                                        ? _resetSession
                                        : null,
                                icon: const Icon(Icons.restart_alt),
                                label: Text(l10n.emomResetButton),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_currentSet > 0 || _sessionCompleted)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _sessionCompleted
                                    ? l10n.emomSessionComplete
                                    : l10n.emomCurrentSet(
                                        _currentSet, _totalSets),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (!_sessionCompleted)
                                Chip(
                                  label: Text(l10n.emomRepsPerSet(_repsPerSet)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_sessionCompleted)
                            Text(
                              l10n.emomFinishedMessage,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            )
                          else ...[
                            Text(
                              l10n.emomTimeRemainingLabel,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: _intervalRemaining.inSeconds /
                                        _intervalSeconds,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _formatDuration(_intervalRemaining),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (_prepSecondsLeft != null)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.75),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.emomPrepHeadline(_currentSet),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '${_prepSecondsLeft ?? 0}',
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.emomPrepSubhead,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
