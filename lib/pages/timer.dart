import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../l10n/app_localizations.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  static const int _defaultWorkSeconds = 40;
  static const int _defaultRestSeconds = 90;
  static const int _defaultRounds = 4;

  Timer? _intervalTimer;
  final FlutterTts _flutterTts = FlutterTts();

  bool _didSeedExercises = false;
  bool _isRunning = false;
  bool _isRestPhase = false;
  int? _lastCountdownAnnouncement;
  int _remainingSeconds = _defaultWorkSeconds;
  int _workSeconds = _defaultWorkSeconds;
  int _restSeconds = _defaultRestSeconds;
  int _rounds = _defaultRounds;
  int _exerciseIndex = 0;
  int _roundIndex = 0;
  List<_WorkoutExercise> _exercises = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    unawaited(_configureSpeech());
    if (_didSeedExercises) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    _exercises = [
      _WorkoutExercise(
        name: l10n.timerExercisePullUps,
        icon: Icons.fitness_center,
      ),
      _WorkoutExercise(
        name: l10n.timerExercisePushUps,
        icon: Icons.front_hand_outlined,
      ),
      _WorkoutExercise(
        name: l10n.timerExerciseSquats,
        icon: Icons.accessibility_new,
      ),
      _WorkoutExercise(
        name: l10n.timerExercisePlank,
        icon: Icons.horizontal_rule_rounded,
      ),
    ];
    _didSeedExercises = true;
  }

  @override
  void dispose() {
    _intervalTimer?.cancel();
    unawaited(_flutterTts.stop());
    super.dispose();
  }

  int get _exerciseCount => _exercises.length;

  int get _currentPhaseDuration => _isRestPhase ? _restSeconds : _workSeconds;

  int get _completedSets => (_roundIndex * _exerciseCount) + _exerciseIndex;

  int get _totalSets => _exerciseCount * _rounds;

  void _restartTicker() {
    _intervalTimer?.cancel();
    if (_remainingSeconds <= 0) {
      _advancePhase(autoContinue: true);
      return;
    }
    _intervalTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds -= 1;
        });
        _announceCountdownIfNeeded(_remainingSeconds);
        return;
      }
      _advancePhase(autoContinue: true);
    });
  }

  void _resetWorkoutState() {
    _intervalTimer?.cancel();
    _lastCountdownAnnouncement = null;
    unawaited(_flutterTts.stop());
    setState(() {
      _isRunning = false;
      _isRestPhase = false;
      _remainingSeconds = _workSeconds;
      _exerciseIndex = 0;
      _roundIndex = 0;
    });
  }

  void _startTimer() {
    if (_isRunning || _exerciseCount == 0) {
      return;
    }
    setState(() {
      _isRunning = true;
      if (_remainingSeconds == 0) {
        _remainingSeconds = _currentPhaseDuration;
      }
    });
    _restartTicker();
  }

  void _pauseTimer() {
    _intervalTimer?.cancel();
    unawaited(_flutterTts.stop());
    setState(() {
      _isRunning = false;
    });
  }

  void _toggleRunning() {
    if (_isRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void _resetWorkout() {
    _resetWorkoutState();
  }

  void _adjustCurrentPhase(int deltaSeconds) {
    if (_exerciseCount == 0) {
      return;
    }
    final minimumValue = _isRestPhase ? 0 : 5;
    final updatedValue = (_remainingSeconds + deltaSeconds).clamp(
      minimumValue,
      36000,
    );
    setState(() {
      _remainingSeconds = updatedValue;
    });
  }

  void _setWorkDuration(int valueSeconds) {
    final updatedValue = valueSeconds.clamp(5, 36000);
    setState(() {
      _workSeconds = updatedValue;
      if (!_isRestPhase && !_isRunning) {
        _remainingSeconds = updatedValue;
      } else if (!_isRestPhase) {
        _remainingSeconds = math.min(_remainingSeconds, updatedValue);
      }
    });
  }

  void _setRestDuration(int valueSeconds) {
    final updatedValue = valueSeconds.clamp(0, 36000);
    setState(() {
      _restSeconds = updatedValue;
      if (_isRestPhase && !_isRunning) {
        _remainingSeconds = updatedValue;
      } else if (_isRestPhase) {
        _remainingSeconds = updatedValue == 0
            ? 0
            : math.min(_remainingSeconds, updatedValue);
      }
    });
    if (_isRestPhase && _isRunning && updatedValue == 0) {
      _intervalTimer?.cancel();
      _advancePhase(autoContinue: true);
    }
  }

  void _setRounds(int value) {
    final updatedValue = value.clamp(1, 99);
    _lastCountdownAnnouncement = null;
    setState(() {
      _rounds = updatedValue;
      _isRunning = false;
      _isRestPhase = false;
      _remainingSeconds = _workSeconds;
      _exerciseIndex = 0;
      _roundIndex = 0;
    });
    _intervalTimer?.cancel();
  }

  Future<void> _editNumber({
    required String title,
    required int currentValue,
    required ValueChanged<int> onConfirm,
  }) async {
    final controller = TextEditingController(text: currentValue.toString());
    final materialL10n = MaterialLocalizations.of(context);

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(hintText: '0'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(materialL10n.cancelButtonLabel),
            ),
            TextButton(
              onPressed: () {
                final parsed = int.tryParse(controller.text);
                Navigator.of(context).pop(parsed);
              },
              child: Text(materialL10n.okButtonLabel),
            ),
          ],
        );
      },
    );

    if (result != null) {
      onConfirm(result);
    }
  }

  Future<void> _editExerciseName({int? index}) async {
    final l10n = AppLocalizations.of(context)!;
    final materialL10n = MaterialLocalizations.of(context);
    final currentValue = index == null ? '' : _exercises[index].name;
    final controller = TextEditingController(text: currentValue);

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.timerExerciseNameLabel),
          content: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(hintText: l10n.timerExerciseNameHint),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(materialL10n.cancelButtonLabel),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: Text(materialL10n.okButtonLabel),
            ),
          ],
        );
      },
    );

    final name = result?.trim();
    if (name == null || name.isEmpty) {
      return;
    }

    setState(() {
      if (index == null) {
        _exercises = [
          ..._exercises,
          _WorkoutExercise(name: name, icon: _iconForIndex(_exercises.length)),
        ];
      } else {
        final updated = [..._exercises];
        updated[index] = updated[index].copyWith(name: name);
        _exercises = updated;
      }
      _isRunning = false;
      _isRestPhase = false;
      _remainingSeconds = _workSeconds;
      _exerciseIndex = 0;
      _roundIndex = 0;
    });
    _intervalTimer?.cancel();
  }

  void _removeExerciseAt(int index) {
    if (index < 0 || index >= _exercises.length) {
      return;
    }
    final updated = [..._exercises]..removeAt(index);
    _intervalTimer?.cancel();
    setState(() {
      _exercises = updated;
      _isRunning = false;
      _isRestPhase = false;
      _remainingSeconds = _workSeconds;
      _exerciseIndex = 0;
      _roundIndex = 0;
    });
  }

  void _advancePhase({required bool autoContinue}) {
    final l10n = AppLocalizations.of(context)!;
    if (_exerciseCount == 0) {
      _intervalTimer?.cancel();
      _lastCountdownAnnouncement = null;
      setState(() {
        _isRunning = false;
        _remainingSeconds = _workSeconds;
      });
      return;
    }

    final isLastExercise = _exerciseIndex == _exerciseCount - 1;
    final isLastRound = _roundIndex == _rounds - 1;

    HapticFeedback.mediumImpact();

    if (!_isRestPhase && isLastExercise && isLastRound) {
      _intervalTimer?.cancel();
      _lastCountdownAnnouncement = null;
      unawaited(_speakCue(l10n.timerCountdownStop));
      setState(() {
        _isRunning = false;
        _remainingSeconds = 0;
      });
      return;
    }

    setState(() {
      if (_isRestPhase) {
        if (isLastExercise) {
          _exerciseIndex = 0;
          _roundIndex += 1;
        } else {
          _exerciseIndex += 1;
        }
        _isRestPhase = false;
        _remainingSeconds = _workSeconds;
      } else {
        if (_restSeconds == 0) {
          if (isLastExercise) {
            _exerciseIndex = 0;
            _roundIndex += 1;
          } else {
            _exerciseIndex += 1;
          }
          _isRestPhase = false;
          _remainingSeconds = _workSeconds;
        } else {
          _isRestPhase = true;
          _remainingSeconds = _restSeconds;
        }
      }
      _isRunning = autoContinue;
    });
    _lastCountdownAnnouncement = null;
    unawaited(
      _speakCue(_isRestPhase ? l10n.timerCountdownStop : l10n.timerCountdownGo),
    );

    _intervalTimer?.cancel();
    if (autoContinue) {
      _restartTicker();
    }
  }

  Future<void> _configureSpeech() async {
    final locale = Localizations.localeOf(context);
    try {
      await _flutterTts.setLanguage(_speechLocaleTag(locale));
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.0);
    } catch (_) {
      // Ignore unsupported TTS locales on the current device.
    }
  }

  String _speechLocaleTag(Locale locale) {
    switch (locale.languageCode) {
      case 'it':
        return 'it-IT';
      case 'es':
        return 'es-ES';
      default:
        return 'en-US';
    }
  }

  void _announceCountdownIfNeeded(int remainingSeconds) {
    if (remainingSeconds < 1 || remainingSeconds > 3) {
      return;
    }
    if (_lastCountdownAnnouncement == remainingSeconds) {
      return;
    }
    _lastCountdownAnnouncement = remainingSeconds;
    unawaited(_speakCue('$remainingSeconds'));
  }

  Future<void> _speakCue(String cue) async {
    try {
      await _flutterTts.stop();
      await _flutterTts.speak(cue);
    } catch (_) {
      // Ignore TTS failures and keep the timer running.
    }
  }

  String _formatSeconds(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  _WorkoutExercise? _currentExercise() {
    if (_exerciseCount == 0) {
      return null;
    }
    return _exercises[_exerciseIndex];
  }

  _WorkoutExercise? _nextExercise() {
    if (_exerciseCount == 0) {
      return null;
    }
    if (!_isRestPhase &&
        _exerciseIndex == _exerciseCount - 1 &&
        _roundIndex == _rounds - 1) {
      return null;
    }
    if (_isRestPhase) {
      if (_exerciseIndex == _exerciseCount - 1) {
        return _exercises.first;
      }
      return _exercises[_exerciseIndex + 1];
    }
    return _currentExercise();
  }

  int _nextRoundNumber() {
    if (_isRestPhase && _exerciseIndex == _exerciseCount - 1) {
      return _roundIndex + 2;
    }
    return _roundIndex + 1;
  }

  IconData _iconForIndex(int index) {
    const icons = [
      Icons.fitness_center,
      Icons.front_hand_outlined,
      Icons.accessibility_new,
      Icons.horizontal_rule_rounded,
      Icons.sports_gymnastics,
      Icons.self_improvement,
    ];
    return icons[index % icons.length];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentExercise = _currentExercise();
    final nextExercise = _nextExercise();
    final phaseLabel = _isRestPhase ? l10n.timerPhaseRest : l10n.timerPhaseWork;
    final phaseColor = _isRestPhase
        ? colorScheme.tertiary
        : colorScheme.primary;
    final progress = _currentPhaseDuration == 0
        ? 0.0
        : (1 - (_remainingSeconds / _currentPhaseDuration)).clamp(0.0, 1.0);
    final headlineExercise = _exerciseCount == 0
        ? l10n.timerNoExercisesConfigured
        : (_isRestPhase
              ? nextExercise?.name ?? currentExercise!.name
              : currentExercise!.name);
    final setCounter = _exerciseCount == 0
        ? '0/0'
        : '${_completedSets + 1}/$_totalSets';
    final roundCounter = _exerciseCount == 0
        ? '0/$_rounds'
        : '${_roundIndex + 1}/$_rounds';
    final nextLabel = nextExercise == null
        ? l10n.timerNextPlaceholder
        : l10n.timerNextLabel(
            nextExercise.name,
            _nextRoundNumber().clamp(1, _rounds),
            _rounds,
          );

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final ringSize = (constraints.maxWidth * 0.68)
                .clamp(220, 400)
                .toDouble();
            final ringThickness = (ringSize * 0.11).clamp(14, 30).toDouble();
            final timeFontSize = (ringSize * 0.24).clamp(42, 104).toDouble();
            final phaseFontSize = (ringSize * 0.07).clamp(16, 28).toDouble();

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.timerTitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        headlineExercise,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: phaseColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _MetricChip(
                            icon: Icons.repeat,
                            label: '${l10n.timerRoundsLabel}: $roundCounter',
                          ),
                          _MetricChip(
                            icon: Icons.checklist_rounded,
                            label: setCounter,
                          ),
                          _MetricChip(
                            icon: Icons.timer_outlined,
                            label: _isRestPhase
                                ? _formatSeconds(_restSeconds)
                                : _formatSeconds(_workSeconds),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: ringSize,
                              height: ringSize,
                              child: CustomPaint(
                                painter: _IntervalRingPainter(
                                  progress: progress,
                                  activeColor: phaseColor,
                                  inactiveColor: colorScheme.onSurface
                                      .withValues(alpha: 0.1),
                                  thickness: ringThickness,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  phaseLabel,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: phaseColor,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.4,
                                    fontSize: phaseFontSize,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  _formatSeconds(_remainingSeconds),
                                  style: theme.textTheme.displayMedium
                                      ?.copyWith(
                                        fontSize: timeFontSize,
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  nextLabel,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.center,
                        child: _ControlButton(
                          label: _isRunning
                              ? l10n.timerControlPause
                              : l10n.timerControlPlay,
                          icon: _isRunning ? Icons.pause : Icons.play_arrow,
                          onPressed: _exerciseCount == 0 ? null : _toggleRunning,
                          isPrimary: true,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _AdjustButton(
                            label: l10n.timerAdjustDecrease,
                            onPressed: () => _adjustCurrentPhase(-10),
                          ),
                          const SizedBox(width: 12),
                          _AdjustButton(
                            label: l10n.timerAdjustIncrease,
                            onPressed: () => _adjustCurrentPhase(10),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _ExerciseRail(
                        exercises: _exercises,
                        activeIndex: _exerciseIndex,
                        activeColor: phaseColor,
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: constraints.maxWidth > 560
                                ? (constraints.maxWidth - 12) / 2
                                : constraints.maxWidth,
                            child: _TimerConfigRow(
                              title: l10n.timerWorkDurationLabel,
                              value: _formatSeconds(_workSeconds),
                              onEdit: () => _editNumber(
                                title: l10n.timerWorkDurationLabel,
                                currentValue: _workSeconds,
                                onConfirm: _setWorkDuration,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: constraints.maxWidth > 560
                                ? (constraints.maxWidth - 12) / 2
                                : constraints.maxWidth,
                            child: _TimerConfigRow(
                              title: l10n.timerRestDurationLabel,
                              value: _formatSeconds(_restSeconds),
                              onEdit: () => _editNumber(
                                title: l10n.timerRestDurationLabel,
                                currentValue: _restSeconds,
                                onConfirm: _setRestDuration,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: constraints.maxWidth > 560
                                ? (constraints.maxWidth - 12) / 2
                                : constraints.maxWidth,
                            child: _TimerConfigRow(
                              title: l10n.timerRoundsLabel,
                              value: _rounds.toString(),
                              onEdit: () => _editNumber(
                                title: l10n.timerRoundsLabel,
                                currentValue: _rounds,
                                onConfirm: _setRounds,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _ExerciseEditorCard(
                        title: l10n.timerExercisesLabel,
                        addLabel: l10n.timerAddExercise,
                        emptyLabel: l10n.timerNoExercisesConfigured,
                        exercises: _exercises,
                        onAdd: () => _editExerciseName(),
                        onEdit: _editExerciseName,
                        onRemove: _removeExerciseAt,
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _ControlButton(
                            label: l10n.timerControlSkip,
                            icon: Icons.skip_next_rounded,
                            onPressed: _exerciseCount == 0
                                ? null
                                : () => _advancePhase(autoContinue: _isRunning),
                          ),
                          _ControlButton(
                            label: l10n.timerControlReset,
                            icon: Icons.restart_alt,
                            onPressed: _resetWorkout,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WorkoutExercise {
  final String name;
  final IconData icon;

  const _WorkoutExercise({required this.name, required this.icon});

  _WorkoutExercise copyWith({String? name, IconData? icon}) {
    return _WorkoutExercise(name: name ?? this.name, icon: icon ?? this.icon);
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetricChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseRail extends StatelessWidget {
  final List<_WorkoutExercise> exercises;
  final int activeIndex;
  final Color activeColor;

  const _ExerciseRail({
    required this.exercises,
    required this.activeIndex,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    if (exercises.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        for (var i = 0; i < exercises.length; i += 1)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: i == activeIndex
                  ? activeColor.withValues(alpha: 0.16)
                  : theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
              border: Border.all(
                color: i == activeIndex
                    ? activeColor
                    : theme.colorScheme.outlineVariant,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  exercises[i].icon,
                  size: 18,
                  color: i == activeIndex
                      ? activeColor
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  exercises[i].name,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: i == activeIndex ? activeColor : null,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TimerConfigRow extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onEdit;

  const _TimerConfigRow({
    required this.title,
    required this.value,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.35,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
        ],
      ),
    );
  }
}

class _ExerciseEditorCard extends StatelessWidget {
  final String title;
  final String addLabel;
  final String emptyLabel;
  final List<_WorkoutExercise> exercises;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final Future<void> Function({int? index}) onEdit;

  const _ExerciseEditorCard({
    required this.title,
    required this.addLabel,
    required this.emptyLabel,
    required this.exercises,
    required this.onAdd,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.22,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: Text(addLabel),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (exercises.isEmpty)
            Text(
              emptyLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            Column(
              children: [
                for (var i = 0; i < exercises.length; i += 1) ...[
                  _ExerciseEditorRow(
                    exercise: exercises[i],
                    onEdit: () => onEdit(index: i),
                    onRemove: () => onRemove(i),
                  ),
                  if (i != exercises.length - 1) const SizedBox(height: 10),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _ExerciseEditorRow extends StatelessWidget {
  final _WorkoutExercise exercise;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const _ExerciseEditorRow({
    required this.exercise,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final materialL10n = MaterialLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: theme.colorScheme.surface,
      ),
      child: Row(
        children: [
          Icon(exercise.icon, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              exercise.name,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
          IconButton(
            onPressed: onRemove,
            tooltip: materialL10n.deleteButtonTooltip,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _IntervalRingPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color inactiveColor;
  final double thickness;

  const _IntervalRingPainter({
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    const startAngle = -math.pi / 2;
    const totalSweep = math.pi * 2;
    const segments = 60;
    const gapRadians = 0.02;
    final segmentSweep = (totalSweep / segments) - gapRadians;

    final activePaint = Paint()
      ..color = activeColor
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final inactivePaint = Paint()
      ..color = inactiveColor
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final activeSegments = (segments * progress).round();
    for (var i = 0; i < segments; i += 1) {
      final paint = i < activeSegments ? activePaint : inactivePaint;
      final angle = startAngle + (i * (segmentSweep + gapRadians));
      canvas.drawArc(rect, angle, segmentSweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _IntervalRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor ||
        oldDelegate.thickness != thickness;
  }
}

class _AdjustButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _AdjustButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
      child: Text(label),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const _ControlButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = isPrimary
        ? FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          )
        : OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          );
    final button = isPrimary
        ? FilledButton(
            onPressed: onPressed,
            style: style,
            child: _ControlContent(label: label, icon: icon),
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: style,
            child: _ControlContent(label: label, icon: icon),
          );

    return button;
  }
}

class _ControlContent extends StatelessWidget {
  final String label;
  final IconData icon;

  const _ControlContent({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}
