import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

enum WorkoutTimerMode { amrap, emom, forTime, tabata }

class WorkoutTimerPanel extends StatefulWidget {
  final AppLocalizations l10n;

  const WorkoutTimerPanel({super.key, required this.l10n});

  @override
  State<WorkoutTimerPanel> createState() => _WorkoutTimerPanelState();
}

class _WorkoutTimerPanelState extends State<WorkoutTimerPanel>
    with WidgetsBindingObserver {
  static const String _sessionKey = 'timer_workout_session';

  Timer? _ticker;
  WorkoutTimerMode _mode = WorkoutTimerMode.amrap;
  bool _isRunning = false;
  bool _isFinished = false;
  bool _isPreparing = false;
  bool _hasStarted = false;
  bool _emomUnlimited = false;
  bool _isRestPhase = false;
  int _elapsedSeconds = 0;
  int _remainingSeconds = 20 * 60;
  int _amrapMinutes = 20;
  int _emomMinutes = 20;
  int _workSeconds = 20;
  int _restSeconds = 10;
  int _tabataRounds = 8;
  int _tabataRound = 1;
  int _amrapReps = 0;
  int _sessionElapsedSeconds = 0;
  DateTime? _lastWallSyncAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_restoreSession());
  }

  @override
  void dispose() {
    _syncFromWallClock(updateUi: false);
    _ticker?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_persistSession());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncFromWallClock();
      if (_isRunning) _startTicker();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _syncFromWallClock();
      unawaited(_persistSession());
    }
  }

  Future<void> _restoreSession() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_sessionKey);
    if (!mounted || saved == null) return;

    try {
      final session = jsonDecode(saved) as Map<String, dynamic>;
      setState(() {
        final modeIndex = (session['mode'] as int? ?? 0).clamp(
          0,
          WorkoutTimerMode.values.length - 1,
        );
        _mode = WorkoutTimerMode.values[modeIndex];
        _amrapMinutes = (session['amrapMinutes'] as int? ?? 20).clamp(1, 180);
        _emomMinutes = (session['emomMinutes'] as int? ?? 20).clamp(1, 180);
        _workSeconds = (session['workSeconds'] as int? ?? 20).clamp(5, 300);
        _restSeconds = (session['restSeconds'] as int? ?? 10).clamp(0, 300);
        _tabataRounds = (session['tabataRounds'] as int? ?? 8).clamp(1, 99);
        _emomUnlimited = session['emomUnlimited'] as bool? ?? false;
        _amrapReps = (session['amrapReps'] as int? ?? 0).clamp(0, 999999);
        _hasStarted = session['hasStarted'] as bool? ?? false;
        _isRunning = session['isRunning'] as bool? ?? false;
        _isFinished = session['isFinished'] as bool? ?? false;
        _sessionElapsedSeconds = (session['sessionElapsedSeconds'] as int? ?? 0)
            .clamp(0, 1 << 30);
        final syncAt = session['lastWallSyncAt'] as int?;
        _lastWallSyncAt = syncAt == null
            ? DateTime.now()
            : DateTime.fromMillisecondsSinceEpoch(syncAt);
        if (_hasStarted && !_isFinished) _updateFromElapsed();
      });
      if (_isRunning) {
        _syncFromWallClock();
        _startTicker();
      }
    } catch (_) {
      await preferences.remove(_sessionKey);
    }
  }

  Future<void> _persistSession() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _sessionKey,
      jsonEncode({
        'mode': _mode.index,
        'amrapMinutes': _amrapMinutes,
        'emomMinutes': _emomMinutes,
        'workSeconds': _workSeconds,
        'restSeconds': _restSeconds,
        'tabataRounds': _tabataRounds,
        'emomUnlimited': _emomUnlimited,
        'amrapReps': _amrapReps,
        'hasStarted': _hasStarted,
        'isRunning': _isRunning,
        'isFinished': _isFinished,
        'sessionElapsedSeconds': _sessionElapsedSeconds,
        'lastWallSyncAt': _lastWallSyncAt?.millisecondsSinceEpoch,
      }),
    );
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _syncFromWallClock({
    bool updateUi = true,
    bool advanceAtLeastOneSecond = false,
  }) {
    if (!_isRunning || !_hasStarted) return;
    final now = DateTime.now();
    final elapsed = _lastWallSyncAt == null
        ? 0
        : now.difference(_lastWallSyncAt!).inSeconds;
    if (elapsed <= 0 && !advanceAtLeastOneSecond) return;
    final oldElapsed = _elapsedSeconds;
    _sessionElapsedSeconds += math.max(
      advanceAtLeastOneSecond ? 1 : 0,
      elapsed,
    );
    _lastWallSyncAt = now;
    _updateFromElapsed();
    if (_mode == WorkoutTimerMode.emom &&
        _elapsedSeconds ~/ 60 > oldElapsed ~/ 60) {
      unawaited(HapticFeedback.mediumImpact());
    }
    if (!_isRunning) {
      _ticker?.cancel();
      unawaited(HapticFeedback.mediumImpact());
      unawaited(_persistSession());
    }
    if (updateUi && mounted) setState(() {});
  }

  void _updateFromElapsed() {
    _isPreparing = _sessionElapsedSeconds < 10;
    if (_isPreparing) {
      _elapsedSeconds = 0;
      _remainingSeconds = 10 - _sessionElapsedSeconds;
      _isRestPhase = false;
      _tabataRound = 1;
      return;
    }

    final activeSeconds = _sessionElapsedSeconds - 10;
    _elapsedSeconds = activeSeconds;
    _isRestPhase = false;
    _tabataRound = 1;

    switch (_mode) {
      case WorkoutTimerMode.amrap:
        final duration = _amrapMinutes * 60;
        _remainingSeconds = math.max(0, duration - activeSeconds);
        if (activeSeconds >= duration) _markFinished();
      case WorkoutTimerMode.emom:
        if (_emomUnlimited) {
          _remainingSeconds = 60 - (activeSeconds % 60);
        } else {
          final duration = _emomMinutes * 60;
          _remainingSeconds = math.max(0, duration - activeSeconds);
          if (activeSeconds >= duration) _markFinished();
        }
      case WorkoutTimerMode.forTime:
        _remainingSeconds = 0;
      case WorkoutTimerMode.tabata:
        var remaining = activeSeconds;
        for (var round = 1; round <= _tabataRounds; round += 1) {
          _tabataRound = round;
          if (remaining < _workSeconds) {
            _remainingSeconds = _workSeconds - remaining;
            return;
          }
          remaining -= _workSeconds;
          if (round < _tabataRounds) {
            if (remaining < _restSeconds) {
              _isRestPhase = true;
              _remainingSeconds = _restSeconds - remaining;
              return;
            }
            remaining -= _restSeconds;
          }
        }
        _remainingSeconds = 0;
        _markFinished();
    }
  }

  void _markFinished() {
    _isRunning = false;
    _isFinished = true;
    _isPreparing = false;
    _remainingSeconds = 0;
    _lastWallSyncAt = null;
  }

  Future<void> _selectMode(WorkoutTimerMode mode) async {
    if (_mode == mode) return;

    final materialL10n = MaterialLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.l10n.timerChangeModeTitle),
        content: Text(widget.l10n.timerChangeModeWarning),
        actions: [
          TextButton(
            key: const ValueKey('timer-change-cancel'),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(materialL10n.cancelButtonLabel),
          ),
          FilledButton(
            key: const ValueKey('timer-change-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(widget.l10n.timerChangeModeConfirm),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    setState(() {
      _mode = mode;
      _resetValues();
    });
    _ticker?.cancel();
    _lastWallSyncAt = null;
    unawaited(_persistSession());
  }

  void _resetValues() {
    _isRunning = false;
    _isFinished = false;
    _isPreparing = false;
    _hasStarted = false;
    _isRestPhase = false;
    _elapsedSeconds = 0;
    _sessionElapsedSeconds = 0;
    _lastWallSyncAt = null;
    _tabataRound = 1;
    _amrapReps = 0;
    _remainingSeconds = switch (_mode) {
      WorkoutTimerMode.amrap => _amrapMinutes * 60,
      WorkoutTimerMode.emom => _emomUnlimited ? 60 : _emomMinutes * 60,
      WorkoutTimerMode.forTime => 0,
      WorkoutTimerMode.tabata => _workSeconds,
    };
  }

  void _resetTimer() {
    _ticker?.cancel();
    setState(_resetValues);
    unawaited(_persistSession());
  }

  void _toggleTimer() {
    if (_isRunning) {
      _syncFromWallClock(updateUi: false);
      _ticker?.cancel();
      setState(() {
        _isRunning = false;
        _lastWallSyncAt = null;
      });
      unawaited(_persistSession());
      return;
    }
    if (_isFinished) {
      _resetTimer();
    }
    setState(() {
      if (!_hasStarted) {
        _hasStarted = true;
        _isPreparing = true;
        _sessionElapsedSeconds = 0;
        _lastWallSyncAt = DateTime.now();
        _remainingSeconds = 10;
      } else {
        _lastWallSyncAt = DateTime.now();
      }
      _isRunning = true;
    });
    _startTicker();
    unawaited(_persistSession());
  }

  void _tick() {
    if (!_isRunning) return;
    final beforeRound = _tabataRound;
    final beforeRest = _isRestPhase;
    final beforeMinute = _elapsedSeconds ~/ 60;
    _syncFromWallClock(advanceAtLeastOneSecond: true);
    if (_mode == WorkoutTimerMode.tabata &&
        (beforeRound != _tabataRound || beforeRest != _isRestPhase)) {
      unawaited(HapticFeedback.mediumImpact());
    } else if (_mode == WorkoutTimerMode.emom &&
        beforeMinute != _elapsedSeconds ~/ 60) {
      unawaited(HapticFeedback.mediumImpact());
    }
  }

  void _finishTimer() {
    _syncFromWallClock(updateUi: false);
    _ticker?.cancel();
    unawaited(HapticFeedback.mediumImpact());
    setState(() {
      _isRunning = false;
      _isFinished = true;
      _isPreparing = false;
      _remainingSeconds = 0;
      _lastWallSyncAt = null;
    });
    unawaited(_persistSession());
  }

  void _adjustValue(
    int current,
    int delta,
    int minimum,
    int maximum,
    void Function(int) update,
  ) {
    if (_isRunning) return;
    final value = (current + delta).clamp(minimum, maximum);
    setState(() {
      update(value);
      _resetValues();
    });
    unawaited(_persistSession());
  }

  String _formatSeconds(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _modeLabel(AppLocalizations l10n) => switch (_mode) {
    WorkoutTimerMode.amrap => l10n.timerModeAmrap,
    WorkoutTimerMode.emom => l10n.timerModeEmom,
    WorkoutTimerMode.forTime => l10n.timerModeForTime,
    WorkoutTimerMode.tabata => l10n.timerModeTabata,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final phaseColor = _isRestPhase ? colors.tertiary : colors.primary;
    final title = _isPreparing
        ? l10n.timerPhasePrepare
        : _isFinished
        ? l10n.timerWorkoutComplete
        : _mode == WorkoutTimerMode.tabata
        ? (_isRestPhase ? l10n.timerPhaseRest : l10n.timerPhaseWork)
        : _mode == WorkoutTimerMode.emom
        ? l10n.timerWorkoutMinute(_elapsedSeconds ~/ 60 + 1)
        : _modeLabel(l10n);
    final displaySeconds = switch (_mode) {
      WorkoutTimerMode.forTime => _elapsedSeconds,
      WorkoutTimerMode.emom when !_isFinished => 60 - (_elapsedSeconds % 60),
      _ => _remainingSeconds,
    };
    final progress = switch (_mode) {
      WorkoutTimerMode.amrap => 1 - (_remainingSeconds / (_amrapMinutes * 60)),
      WorkoutTimerMode.emom => (_elapsedSeconds % 60) / 60,
      WorkoutTimerMode.forTime => (_elapsedSeconds % 60) / 60,
      WorkoutTimerMode.tabata =>
        1 - (_remainingSeconds / (_isRestPhase ? _restSeconds : _workSeconds)),
    }.clamp(0.0, 1.0);
    final ringProgress = _isPreparing ? 0.0 : progress;
    final totalElapsed = _mode == WorkoutTimerMode.emom && !_emomUnlimited
        ? _emomMinutes * 60 - _remainingSeconds
        : _elapsedSeconds;

    return LayoutBuilder(
      builder: (context, constraints) {
        final ringSize = (constraints.maxWidth * 0.68)
            .clamp(220, 320)
            .toDouble();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final mode in WorkoutTimerMode.values)
                  ChoiceChip(
                    label: Text(switch (mode) {
                      WorkoutTimerMode.amrap => l10n.timerModeAmrap,
                      WorkoutTimerMode.emom => l10n.timerModeEmom,
                      WorkoutTimerMode.forTime => l10n.timerModeForTime,
                      WorkoutTimerMode.tabata => l10n.timerModeTabata,
                    }),
                    selected: _mode == mode,
                    onSelected: (_) => _selectMode(mode),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettings(l10n),
            if (_mode == WorkoutTimerMode.amrap) ...[
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                children: [
                  Text(
                    '${l10n.timerAmrapReps}: $_amrapReps',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.tonalIcon(
                    key: const ValueKey('amrap-add-rep'),
                    onPressed: _isFinished
                        ? null
                        : () {
                            setState(() => _amrapReps += 1);
                            unawaited(_persistSession());
                          },
                    icon: const Icon(Icons.add),
                    label: Text(l10n.timerAmrapAddRep),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            Center(
              child: SizedBox.square(
                dimension: ringSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size.square(ringSize),
                      painter: IntervalRingPainter(
                        progress: ringProgress,
                        activeColor: phaseColor,
                        inactiveColor: colors.onSurface.withValues(alpha: 0.1),
                        thickness: 20,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: phaseColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _formatSeconds(displaySeconds),
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontSize: (ringSize * 0.23)
                                .clamp(42, 76)
                                .toDouble(),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (_mode == WorkoutTimerMode.emom) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${l10n.timerWorkoutElapsed}: ${_formatSeconds(totalElapsed)}',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (_mode == WorkoutTimerMode.tabata) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${l10n.timerRoundsLabel}: $_tabataRound/$_tabataRounds',
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  key: const ValueKey('workout-timer-toggle'),
                  onPressed: _toggleTimer,
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(
                    _isRunning ? l10n.timerControlPause : l10n.timerControlPlay,
                  ),
                ),
                if (_mode == WorkoutTimerMode.forTime && !_isFinished)
                  OutlinedButton.icon(
                    onPressed: _elapsedSeconds == 0 ? null : _finishTimer,
                    icon: const Icon(Icons.stop_rounded),
                    label: Text(l10n.timerWorkoutFinish),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: _resetTimer,
                    icon: const Icon(Icons.restart_alt),
                    label: Text(l10n.timerControlReset),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettings(AppLocalizations l10n) {
    if (_mode == WorkoutTimerMode.forTime) return const SizedBox.shrink();
    if (_mode == WorkoutTimerMode.emom) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.timerWorkoutUnlimited)),
              Switch.adaptive(
                value: _emomUnlimited,
                onChanged: _isRunning
                    ? null
                    : (value) {
                        setState(() {
                          _emomUnlimited = value;
                          _resetValues();
                        });
                        unawaited(_persistSession());
                      },
              ),
            ],
          ),
          if (!_emomUnlimited)
            WorkoutTimerSetting(
              title: l10n.timerWorkoutDuration,
              value: '$_emomMinutes',
              enabled: !_isRunning,
              onDecrease: () => _adjustValue(
                _emomMinutes,
                -1,
                1,
                180,
                (value) => _emomMinutes = value,
              ),
              onIncrease: () => _adjustValue(
                _emomMinutes,
                1,
                1,
                180,
                (value) => _emomMinutes = value,
              ),
            ),
        ],
      );
    }
    if (_mode == WorkoutTimerMode.amrap) {
      return WorkoutTimerSetting(
        title: l10n.timerWorkoutDuration,
        value: '$_amrapMinutes',
        enabled: !_isRunning,
        onDecrease: () => _adjustValue(
          _amrapMinutes,
          -1,
          1,
          180,
          (value) => _amrapMinutes = value,
        ),
        onIncrease: () => _adjustValue(
          _amrapMinutes,
          1,
          1,
          180,
          (value) => _amrapMinutes = value,
        ),
      );
    }
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        WorkoutTimerSetting(
          title: l10n.timerTabataWork,
          value: '${_workSeconds}s',
          enabled: !_isRunning,
          onDecrease: () => _adjustValue(
            _workSeconds,
            -5,
            5,
            300,
            (value) => _workSeconds = value,
          ),
          onIncrease: () => _adjustValue(
            _workSeconds,
            5,
            5,
            300,
            (value) => _workSeconds = value,
          ),
        ),
        WorkoutTimerSetting(
          title: l10n.timerTabataRest,
          value: '${_restSeconds}s',
          enabled: !_isRunning,
          onDecrease: () => _adjustValue(
            _restSeconds,
            -5,
            0,
            300,
            (value) => _restSeconds = value,
          ),
          onIncrease: () => _adjustValue(
            _restSeconds,
            5,
            0,
            300,
            (value) => _restSeconds = value,
          ),
        ),
        WorkoutTimerSetting(
          title: l10n.timerRoundsLabel,
          value: '$_tabataRounds',
          enabled: !_isRunning,
          onDecrease: () => _adjustValue(
            _tabataRounds,
            -1,
            1,
            99,
            (value) => _tabataRounds = value,
          ),
          onIncrease: () => _adjustValue(
            _tabataRounds,
            1,
            1,
            99,
            (value) => _tabataRounds = value,
          ),
        ),
      ],
    );
  }
}

class WorkoutTimerSetting extends StatelessWidget {
  final String title;
  final String value;
  final bool enabled;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const WorkoutTimerSetting({
    super.key,
    required this.title,
    required this.value,
    required this.enabled,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.35,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: enabled ? onDecrease : null,
                icon: const Icon(Icons.remove),
              ),
              Text(value, style: theme.textTheme.titleMedium),
              IconButton(
                onPressed: enabled ? onIncrease : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WorkoutExercise {
  final String name;
  final IconData icon;

  const WorkoutExercise({required this.name, required this.icon});

  WorkoutExercise copyWith({String? name, IconData? icon}) {
    return WorkoutExercise(name: name ?? this.name, icon: icon ?? this.icon);
  }
}

class MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const MetricChip({super.key, required this.icon, required this.label});

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

class ExerciseRail extends StatelessWidget {
  final List<WorkoutExercise> exercises;
  final int activeIndex;
  final Color activeColor;
  final bool isRestPhase;
  final Set<int> completedIndexes;

  const ExerciseRail({
    super.key,
    required this.exercises,
    required this.activeIndex,
    required this.activeColor,
    required this.isRestPhase,
    required this.completedIndexes,
  });

  @override
  Widget build(BuildContext context) {
    if (exercises.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>();
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        for (var i = 0; i < exercises.length; i += 1)
          Builder(
            builder: (context) {
              final isCompleted = completedIndexes.contains(i);
              final isActive = i == activeIndex && !isRestPhase;
              final icon = isCompleted ? Icons.check_circle : exercises[i].icon;
              final iconColor = isCompleted
                  ? (appColors?.success ?? theme.colorScheme.secondary)
                  : (isActive
                        ? activeColor
                        : theme.colorScheme.onSurfaceVariant);
              final textColor = isCompleted
                  ? (appColors?.success ?? theme.colorScheme.secondary)
                  : (isActive ? activeColor : null);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: isCompleted
                      ? (appColors?.successContainer ??
                            theme.colorScheme.secondaryContainer)
                      : isActive
                      ? activeColor.withValues(alpha: 0.16)
                      : theme.colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.3,
                        ),
                  border: Border.all(
                    color: isCompleted
                        ? (appColors?.success ?? theme.colorScheme.secondary)
                        : isActive
                        ? activeColor
                        : theme.colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 18, color: iconColor),
                    const SizedBox(width: 8),
                    Text(
                      exercises[i].name,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class TimerConfigRow extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onEdit;

  const TimerConfigRow({
    super.key,
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

class ExerciseEditorCard extends StatelessWidget {
  final String title;
  final String addLabel;
  final String emptyLabel;
  final List<WorkoutExercise> exercises;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final Future<void> Function({int? index}) onEdit;

  const ExerciseEditorCard({
    super.key,
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
                  ExerciseEditorRow(
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

class ExerciseEditorRow extends StatelessWidget {
  final WorkoutExercise exercise;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const ExerciseEditorRow({
    super.key,
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

class IntervalRingPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color inactiveColor;
  final double thickness;

  const IntervalRingPainter({
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
  bool shouldRepaint(covariant IntervalRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor ||
        oldDelegate.thickness != thickness;
  }
}

class AdjustButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const AdjustButton({super.key, required this.label, required this.onPressed});

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

class ControlButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const ControlButton({
    super.key,
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
            child: ControlContent(label: label, icon: icon),
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: style,
            child: ControlContent(label: label, icon: icon),
          );

    return button;
  }
}

class ControlContent extends StatelessWidget {
  final String label;
  final IconData icon;

  const ControlContent({super.key, required this.label, required this.icon});

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
