import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import 'timer_components.dart' as timer_components;

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with WidgetsBindingObserver {
  static const int _defaultWorkSeconds = 40;
  static const int _defaultRestSeconds = 90;
  static const int _defaultRounds = 4;
  static const String _workSecondsKey = 'timer_work_seconds';
  static const String _restSecondsKey = 'timer_rest_seconds';
  static const String _roundsKey = 'timer_rounds';
  static const String _exerciseNamesKey = 'timer_exercise_names';
  static const String _intervalSessionKey = 'timer_interval_session';

  Timer? _intervalTimer;
  final FlutterTts _flutterTts = FlutterTts();

  bool _didSeedExercises = false;
  bool _showWorkoutTimers = false;
  bool _isRunning = false;
  bool _isPreparing = false;
  bool _hasStarted = false;
  bool _isRestPhase = false;
  DateTime? _lastIntervalSyncAt;
  int? _lastCountdownAnnouncement;
  int _remainingSeconds = _defaultWorkSeconds;
  int _workSeconds = _defaultWorkSeconds;
  int _restSeconds = _defaultRestSeconds;
  int _rounds = _defaultRounds;
  int _exerciseIndex = 0;
  int _roundIndex = 0;
  List<_WorkoutExercise> _exercises = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

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
    unawaited(_restoreTimerPreferences());
  }

  @override
  void dispose() {
    _syncIntervalFromWallClock(updateUi: false);
    _intervalTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_saveIntervalRunState());
    unawaited(_flutterTts.stop());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncIntervalFromWallClock();
      if (_isRunning) _restartTicker();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _syncIntervalFromWallClock();
      unawaited(_saveIntervalRunState());
    }
  }

  int get _exerciseCount => _exercises.length;

  int get _currentPhaseDuration => _isRestPhase ? _restSeconds : _workSeconds;

  int get _completedSets => (_roundIndex * _exerciseCount) + _exerciseIndex;

  int get _totalSets => _exerciseCount * _rounds;

  void _restartTicker() {
    _intervalTimer?.cancel();
    if (!_isRunning) return;
    _intervalTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _syncIntervalFromWallClock(advanceAtLeastOneSecond: true),
    );
  }

  bool _moveIntervalPhaseForward() {
    if (_exerciseCount == 0) {
      _isRunning = false;
      _isPreparing = false;
      _remainingSeconds = _workSeconds;
      return true;
    }

    final isLastExercise = _exerciseIndex == _exerciseCount - 1;
    final isLastRound = _roundIndex == _rounds - 1;
    if (!_isRestPhase && isLastExercise && isLastRound) {
      _isRunning = false;
      _remainingSeconds = 0;
      return true;
    }

    if (_isRestPhase) {
      if (isLastExercise) {
        _exerciseIndex = 0;
        _roundIndex += 1;
      } else {
        _exerciseIndex += 1;
      }
      _isRestPhase = false;
      _remainingSeconds = _workSeconds;
    } else if (_restSeconds == 0) {
      if (isLastExercise) {
        _exerciseIndex = 0;
        _roundIndex += 1;
      } else {
        _exerciseIndex += 1;
      }
      _remainingSeconds = _workSeconds;
    } else {
      _isRestPhase = true;
      _remainingSeconds = _restSeconds;
    }
    return false;
  }

  int _consumeIntervalSeconds(int elapsedSeconds) {
    var remainingElapsed = elapsedSeconds;
    var transitions = 0;
    while (_isRunning && remainingElapsed > 0) {
      if (remainingElapsed < _remainingSeconds) {
        _remainingSeconds -= remainingElapsed;
        break;
      }
      remainingElapsed -= _remainingSeconds;
      if (_isPreparing) {
        _isPreparing = false;
        _remainingSeconds = _workSeconds;
        transitions += 1;
      } else if (_moveIntervalPhaseForward()) {
        transitions += 1;
        break;
      } else {
        transitions += 1;
      }
    }
    return transitions;
  }

  void _syncIntervalFromWallClock({
    bool updateUi = true,
    bool advanceAtLeastOneSecond = false,
  }) {
    if (!_isRunning) return;
    final now = DateTime.now();
    final elapsed = _lastIntervalSyncAt == null
        ? 0
        : now.difference(_lastIntervalSyncAt!).inSeconds;
    if (elapsed <= 0 && !advanceAtLeastOneSecond) return;
    final elapsedToApply = math.max(advanceAtLeastOneSecond ? 1 : 0, elapsed);
    var transitions = 0;
    void update() {
      transitions = _consumeIntervalSeconds(elapsedToApply);
      _lastIntervalSyncAt = _isRunning ? now : null;
    }

    if (updateUi && mounted) {
      setState(update);
    } else {
      update();
    }

    if (transitions > 0) {
      HapticFeedback.mediumImpact();
      _lastCountdownAnnouncement = null;
      if (_isRunning) {
        unawaited(
          _speakCue(
            _isRestPhase
                ? AppLocalizations.of(context)!.timerCountdownStop
                : AppLocalizations.of(context)!.timerCountdownGo,
          ),
        );
      } else if (_isWorkoutComplete()) {
        unawaited(_speakCue(AppLocalizations.of(context)!.timerCountdownStop));
      }
      unawaited(_saveIntervalRunState());
    } else if (_isRunning) {
      _announceCountdownIfNeeded(_remainingSeconds);
    }
  }

  void _resetWorkoutState() {
    _intervalTimer?.cancel();
    _lastCountdownAnnouncement = null;
    unawaited(_flutterTts.stop());
    setState(() {
      _isRunning = false;
      _isPreparing = false;
      _hasStarted = false;
      _isRestPhase = false;
      _remainingSeconds = _workSeconds;
      _exerciseIndex = 0;
      _roundIndex = 0;
      _lastIntervalSyncAt = null;
    });
    unawaited(_saveIntervalRunState());
  }

  void _startTimer() {
    if (_isRunning || _exerciseCount == 0) {
      return;
    }
    setState(() {
      if (!_hasStarted || _remainingSeconds == 0) {
        _hasStarted = true;
        _isPreparing = true;
        _isRestPhase = false;
        _remainingSeconds = 10;
        _exerciseIndex = 0;
        _roundIndex = 0;
      }
      _isRunning = true;
      _lastIntervalSyncAt = DateTime.now();
    });
    _restartTicker();
    unawaited(_saveIntervalRunState());
  }

  void _pauseTimer() {
    _syncIntervalFromWallClock(updateUi: false);
    _intervalTimer?.cancel();
    unawaited(_flutterTts.stop());
    setState(() {
      _isRunning = false;
      _lastIntervalSyncAt = null;
    });
    unawaited(_saveIntervalRunState());
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
    _syncIntervalFromWallClock(updateUi: false);
    final minimumValue = _isRestPhase ? 0 : 5;
    final updatedValue = (_remainingSeconds + deltaSeconds).clamp(
      minimumValue,
      36000,
    );
    setState(() {
      _remainingSeconds = updatedValue;
      _lastIntervalSyncAt = _isRunning ? DateTime.now() : null;
    });
    unawaited(_saveIntervalRunState());
  }

  void _setWorkDuration(int valueSeconds) {
    _syncIntervalFromWallClock(updateUi: false);
    final updatedValue = valueSeconds.clamp(5, 36000);
    setState(() {
      _workSeconds = updatedValue;
      if (!_isRestPhase && !_isRunning) {
        _remainingSeconds = updatedValue;
      } else if (!_isRestPhase) {
        _remainingSeconds = math.min(_remainingSeconds, updatedValue);
      }
    });
    unawaited(_saveTimerPreferences());
    unawaited(_saveIntervalRunState());
  }

  void _setRestDuration(int valueSeconds) {
    _syncIntervalFromWallClock(updateUi: false);
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
    unawaited(_saveTimerPreferences());
    unawaited(_saveIntervalRunState());
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
      _isPreparing = false;
      _hasStarted = false;
      _isRestPhase = false;
      _remainingSeconds = _workSeconds;
      _exerciseIndex = 0;
      _roundIndex = 0;
      _lastIntervalSyncAt = null;
    });
    _intervalTimer?.cancel();
    unawaited(_saveTimerPreferences());
    unawaited(_saveIntervalRunState());
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
    _syncIntervalFromWallClock(updateUi: false);
    _intervalTimer?.cancel();

    setState(() {
      if (index == null) {
        _exercises = [
          ..._exercises,
          _WorkoutExercise(name: name, icon: _iconForIndex(_exercises.length)),
        ];
        _isRunning = false;
        _isPreparing = false;
        _hasStarted = false;
        _lastIntervalSyncAt = null;
      } else {
        final updated = [..._exercises];
        updated[index] = updated[index].copyWith(name: name);
        _exercises = updated;
      }
      _isRunning = false;
      _isPreparing = false;
      _hasStarted = false;
      _lastIntervalSyncAt = null;
      _isRestPhase = false;
      _remainingSeconds = _workSeconds;
      _exerciseIndex = 0;
      _roundIndex = 0;
    });
    unawaited(_saveTimerPreferences());
    unawaited(_saveIntervalRunState());
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
      _isPreparing = false;
      _hasStarted = false;
      _lastIntervalSyncAt = null;
      _isRestPhase = false;
      _remainingSeconds = _workSeconds;
      _exerciseIndex = 0;
      _roundIndex = 0;
    });
    unawaited(_saveTimerPreferences());
    unawaited(_saveIntervalRunState());
  }

  Future<void> _restoreTimerPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    final workSeconds = preferences.getInt(_workSecondsKey);
    final restSeconds = preferences.getInt(_restSecondsKey);
    final rounds = preferences.getInt(_roundsKey);
    final exerciseNames = preferences.getStringList(_exerciseNamesKey);
    final savedRun = preferences.getString(_intervalSessionKey);
    Map<String, dynamic>? restoredRun;
    if (savedRun != null) {
      try {
        restoredRun = jsonDecode(savedRun) as Map<String, dynamic>;
      } catch (_) {
        await preferences.remove(_intervalSessionKey);
      }
    }

    if (!mounted) {
      return;
    }

    final restoredExercises = (exerciseNames ?? const <String>[])
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    setState(() {
      _workSeconds = (workSeconds ?? _defaultWorkSeconds).clamp(5, 36000);
      _restSeconds = (restSeconds ?? _defaultRestSeconds).clamp(0, 36000);
      _rounds = (rounds ?? _defaultRounds).clamp(1, 99);
      if (exerciseNames != null) {
        _exercises = List<_WorkoutExercise>.generate(
          restoredExercises.length,
          (index) => _WorkoutExercise(
            name: restoredExercises[index],
            icon: _iconForIndex(index),
          ),
        );
      }
      if (restoredRun == null) {
        _remainingSeconds = _workSeconds;
      } else {
        _isRunning = restoredRun['isRunning'] as bool? ?? false;
        _isPreparing = restoredRun['isPreparing'] as bool? ?? false;
        _hasStarted = restoredRun['hasStarted'] as bool? ?? false;
        _isRestPhase = restoredRun['isRestPhase'] as bool? ?? false;
        _remainingSeconds =
            (restoredRun['remainingSeconds'] as int? ?? _workSeconds).clamp(
              0,
              36000,
            );
        _exerciseIndex = (restoredRun['exerciseIndex'] as int? ?? 0).clamp(
          0,
          math.max(0, _exerciseCount - 1),
        );
        _roundIndex = (restoredRun['roundIndex'] as int? ?? 0).clamp(
          0,
          _rounds - 1,
        );
        final syncAt = restoredRun['lastSyncAt'] as int?;
        _lastIntervalSyncAt = _isRunning
            ? (syncAt == null
                  ? DateTime.now()
                  : DateTime.fromMillisecondsSinceEpoch(syncAt))
            : null;
      }
    });
    if (_isRunning) {
      _syncIntervalFromWallClock();
      _restartTicker();
    }
  }

  Future<void> _saveIntervalRunState() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _intervalSessionKey,
      jsonEncode({
        'isRunning': _isRunning,
        'isPreparing': _isPreparing,
        'hasStarted': _hasStarted,
        'isRestPhase': _isRestPhase,
        'remainingSeconds': _remainingSeconds,
        'exerciseIndex': _exerciseIndex,
        'roundIndex': _roundIndex,
        'lastSyncAt': _lastIntervalSyncAt?.millisecondsSinceEpoch,
      }),
    );
  }

  Future<void> _saveTimerPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_workSecondsKey, _workSeconds);
    await preferences.setInt(_restSecondsKey, _restSeconds);
    await preferences.setInt(_roundsKey, _rounds);
    await preferences.setStringList(
      _exerciseNamesKey,
      _exercises.map((exercise) => exercise.name).toList(),
    );
  }

  void _advancePhase({required bool autoContinue}) {
    final l10n = AppLocalizations.of(context)!;

    if (_exerciseCount == 0) {
      _intervalTimer?.cancel();
      _lastCountdownAnnouncement = null;
      setState(() {
        _isRunning = false;
        _isPreparing = false;
        _lastIntervalSyncAt = null;
        _remainingSeconds = _workSeconds;
      });
      unawaited(_saveIntervalRunState());
      return;
    }
    var completed = false;
    setState(() {
      if (_isPreparing) {
        _isRestPhase = false;
        _remainingSeconds = _workSeconds;
      } else {
        completed = _moveIntervalPhaseForward();
      }
      _isPreparing = false;
      _isRunning = autoContinue && !completed;
      _lastIntervalSyncAt = _isRunning ? DateTime.now() : null;
    });
    HapticFeedback.mediumImpact();
    _lastCountdownAnnouncement = null;
    unawaited(
      _speakCue(completed ? l10n.timerCountdownStop : l10n.timerCountdownGo),
    );

    _intervalTimer?.cancel();
    if (_isRunning) _restartTicker();
    unawaited(_saveIntervalRunState());
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

  bool _isWorkoutComplete() {
    if (_exerciseCount == 0) {
      return false;
    }
    return !_isRunning &&
        !_isRestPhase &&
        _remainingSeconds == 0 &&
        _exerciseIndex == _exerciseCount - 1 &&
        _roundIndex == _rounds - 1;
  }

  bool _isExerciseCompletedInCurrentRound(int index) {
    if (_isWorkoutComplete()) {
      return true;
    }
    if (_isRestPhase) {
      return index <= _exerciseIndex;
    }
    return index < _exerciseIndex;
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
    final phaseLabel = _isPreparing
        ? l10n.timerPhasePrepare
        : _isRestPhase
        ? l10n.timerPhaseRest
        : l10n.timerPhaseWork;
    final phaseColor = _isRestPhase
        ? colorScheme.tertiary
        : colorScheme.primary;
    final progress = _isPreparing
        ? 1 - (_remainingSeconds / 10)
        : _currentPhaseDuration == 0
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
                      const SizedBox(height: 16),
                      SegmentedButton<bool>(
                        segments: [
                          ButtonSegment<bool>(
                            value: false,
                            label: Text(l10n.timerSectionExercises),
                          ),
                          ButtonSegment<bool>(
                            value: true,
                            label: Text(l10n.timerSectionWorkouts),
                          ),
                        ],
                        selected: {_showWorkoutTimers},
                        onSelectionChanged: (selection) => setState(
                          () => _showWorkoutTimers = selection.first,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Visibility(
                        visible: !_showWorkoutTimers,
                        maintainState: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                                timer_components.MetricChip(
                                  icon: Icons.repeat,
                                  label:
                                      '${l10n.timerRoundsLabel}: $roundCounter',
                                ),
                                timer_components.MetricChip(
                                  icon: Icons.checklist_rounded,
                                  label: setCounter,
                                ),
                                timer_components.MetricChip(
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
                                      painter:
                                          timer_components.IntervalRingPainter(
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
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
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
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                timer_components.ControlButton(
                                  key: const ValueKey('exercise-timer-toggle'),
                                  label: _isRunning
                                      ? l10n.timerControlPause
                                      : l10n.timerControlPlay,
                                  icon: _isRunning
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  onPressed: _exerciseCount == 0
                                      ? null
                                      : _toggleRunning,
                                  isPrimary: true,
                                ),
                                timer_components.ControlButton(
                                  label: l10n.timerControlSkip,
                                  icon: Icons.skip_next_rounded,
                                  onPressed: _exerciseCount == 0
                                      ? null
                                      : () => _advancePhase(
                                          autoContinue: _isRunning,
                                        ),
                                ),
                                timer_components.ControlButton(
                                  label: l10n.timerControlReset,
                                  icon: Icons.restart_alt,
                                  onPressed: _resetWorkout,
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                timer_components.AdjustButton(
                                  label: l10n.timerAdjustDecrease,
                                  onPressed: () => _adjustCurrentPhase(-10),
                                ),
                                const SizedBox(width: 12),
                                timer_components.AdjustButton(
                                  label: l10n.timerAdjustIncrease,
                                  onPressed: () => _adjustCurrentPhase(10),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            timer_components.ExerciseRail(
                              exercises: _exercises
                                  .map(
                                    (exercise) =>
                                        timer_components.WorkoutExercise(
                                          name: exercise.name,
                                          icon: exercise.icon,
                                        ),
                                  )
                                  .toList(),
                              activeIndex: _exerciseIndex,
                              activeColor: phaseColor,
                              isRestPhase: _isRestPhase,
                              completedIndexes: {
                                for (var i = 0; i < _exerciseCount; i += 1)
                                  if (_isExerciseCompletedInCurrentRound(i)) i,
                              },
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
                                  child: timer_components.TimerConfigRow(
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
                                  child: timer_components.TimerConfigRow(
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
                                  child: timer_components.TimerConfigRow(
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
                            timer_components.ExerciseEditorCard(
                              title: l10n.timerExercisesLabel,
                              addLabel: l10n.timerAddExercise,
                              emptyLabel: l10n.timerNoExercisesConfigured,
                              exercises: _exercises
                                  .map(
                                    (exercise) =>
                                        timer_components.WorkoutExercise(
                                          name: exercise.name,
                                          icon: exercise.icon,
                                        ),
                                  )
                                  .toList(),
                              onAdd: () => _editExerciseName(),
                              onEdit: _editExerciseName,
                              onRemove: _removeExerciseAt,
                            ),
                          ],
                        ),
                      ),
                      if (_showWorkoutTimers)
                        timer_components.WorkoutTimerPanel(l10n: l10n),
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
