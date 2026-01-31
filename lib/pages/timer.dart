import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';

enum IntervalPhase { work, rest }

enum TimerExercise { pushUps, pullUps, squats, plank }

extension TimerExerciseLabel on TimerExercise {
  String label(AppLocalizations l10n) {
    switch (this) {
      case TimerExercise.pushUps:
        return l10n.timerExercisePushUps;
      case TimerExercise.pullUps:
        return l10n.timerExercisePullUps;
      case TimerExercise.squats:
        return l10n.timerExerciseSquats;
      case TimerExercise.plank:
        return l10n.timerExercisePlank;
    }
  }
}

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  static const int _defaultWorkSeconds = 40;
  static const int _defaultRestSeconds = 20;
  static const Color _neonGreen = Color(0xFF39FF14);

  Timer? _intervalTimer;

  bool _isRunning = false;
  int _remainingSeconds = _defaultWorkSeconds;
  IntervalPhase _phase = IntervalPhase.work;
  int _workSeconds = _defaultWorkSeconds;
  int _restSeconds = _defaultRestSeconds;

  int _nextExerciseIndex = 0;
  int _nextSet = 1;

  final List<_ExercisePlan> _exercisePlan = const [
    _ExercisePlan(exercise: TimerExercise.pushUps, totalSets: 3),
    _ExercisePlan(exercise: TimerExercise.pullUps, totalSets: 3),
    _ExercisePlan(exercise: TimerExercise.squats, totalSets: 4),
    _ExercisePlan(exercise: TimerExercise.plank, totalSets: 2),
  ];

  @override
  void dispose() {
    _intervalTimer?.cancel();
    super.dispose();
  }

  int get _workDurationSeconds => _workSeconds;
  int get _restDurationSeconds => _restSeconds;

  int get _currentPhaseDuration {
    return _phase == IntervalPhase.work
        ? _workDurationSeconds
        : _restDurationSeconds;
  }

  void _startTimer() {
    if (_isRunning) {
      return;
    }
    if (_remainingSeconds == 0) {
      setState(() {
        _remainingSeconds = _currentPhaseDuration;
      });
    }
    setState(() {
      _isRunning = true;
    });
    _intervalTimer?.cancel();
    _intervalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds -= 1;
        });
      } else {
        setState(() {
          _remainingSeconds = 0;
        });
        _handlePhaseEnd();
      }
    });
  }

  void _pauseTimer() {
    _intervalTimer?.cancel();
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

  void _resetPhase() {
    setState(() {
      _remainingSeconds = _currentPhaseDuration;
    });
  }

  void _skipPhase() {
    _advancePhase();
  }

  void _handlePhaseEnd() {
    _advancePhase();
  }

  void _advancePhase() {
    setState(() {
      _phase = _phase == IntervalPhase.work
          ? IntervalPhase.rest
          : IntervalPhase.work;
      _remainingSeconds = _currentPhaseDuration;
    });
    _advanceWorkoutContext();
  }

  void _advanceWorkoutContext() {
    if (_exercisePlan.isEmpty) {
      return;
    }
    final currentPlan = _exercisePlan[_nextExerciseIndex];
    if (_nextSet < currentPlan.totalSets) {
      setState(() {
        _nextSet += 1;
      });
    } else {
      setState(() {
        _nextExerciseIndex = (_nextExerciseIndex + 1) % _exercisePlan.length;
        _nextSet = 1;
      });
    }
  }

  void _setPhaseDuration(IntervalPhase phase, int valueSeconds) {
    final updatedValue = valueSeconds.clamp(5, 36000);
    setState(() {
      if (phase == IntervalPhase.work) {
        _workSeconds = updatedValue;
      } else {
        _restSeconds = updatedValue;
      }

      if (_phase == phase) {
        if (_isRunning) {
          _remainingSeconds = math.min(_remainingSeconds, updatedValue);
        } else {
          _remainingSeconds = updatedValue;
        }
      }
    });
  }

  Future<void> _editPhaseDuration(IntervalPhase phase) async {
    final currentValue =
        phase == IntervalPhase.work ? _workSeconds : _restSeconds;
    final controller = TextEditingController(text: currentValue.toString());
    final materialL10n = MaterialLocalizations.of(context);
    final l10n = AppLocalizations.of(context)!;

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            phase == IntervalPhase.work
                ? l10n.timerWorkDurationLabel
                : l10n.timerRestDurationLabel,
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              hintText: '0',
            ),
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

    if (result == null) {
      return;
    }
    _setPhaseDuration(phase, result);
  }

  String _formatSeconds(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _nextExerciseLabel(AppLocalizations l10n) {
    if (_exercisePlan.isEmpty) {
      return l10n.timerNextPlaceholder;
    }
    final plan = _exercisePlan[_nextExerciseIndex];
    return l10n.timerNextLabel(
      plan.exercise.label(l10n),
      _nextSet,
      plan.totalSets,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isWork = _phase == IntervalPhase.work;
    final phaseLabel = isWork ? l10n.timerPhaseWork : l10n.timerPhaseRest;
    final phaseColor = isWork ? const Color(0xFFFF8A3D) : const Color(0xFF3D8BFF);
    final progress = _currentPhaseDuration == 0
        ? 0.0
        : (1 - (_remainingSeconds / _currentPhaseDuration)).clamp(0.0, 1.0);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final ringSize =
                (constraints.maxWidth * 0.7).clamp(220, 420).toDouble();
            final ringThickness = (ringSize * 0.12).clamp(16, 36).toDouble();
            final timeFontSize = (ringSize * 0.26).clamp(48, 120).toDouble();
            final labelFontSize = (ringSize * 0.08).clamp(18, 32).toDouble();

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      phaseLabel,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: phaseColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        fontSize: labelFontSize,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: ringSize,
                          height: ringSize,
                          child: CustomPaint(
                            painter: _IntervalRingPainter(
                              progress: progress,
                              activeColor: phaseColor,
                              inactiveColor:
                                  theme.colorScheme.onSurface.withValues(alpha: 0.1),
                              thickness: ringThickness,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatSeconds(_remainingSeconds),
                              style: theme.textTheme.displayMedium?.copyWith(
                                fontSize: timeFontSize,
                                fontWeight: FontWeight.w700,
                                color: _neonGreen,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _TimerConfigRow(
                      title: l10n.timerWorkDurationLabel,
                      value: _formatSeconds(_workDurationSeconds),
                      onEdit: () => _editPhaseDuration(IntervalPhase.work),
                    ),
                    const SizedBox(height: 12),
                    _TimerConfigRow(
                      title: l10n.timerRestDurationLabel,
                      value: _formatSeconds(_restDurationSeconds),
                      onEdit: () => _editPhaseDuration(IntervalPhase.rest),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ControlButton(
                          label: l10n.timerControlSkip,
                          icon: Icons.skip_next,
                          onPressed: _skipPhase,
                        ),
                        const SizedBox(width: 16),
                        _ControlButton(
                          label: _isRunning ? l10n.timerControlPause : l10n.timerControlPlay,
                          icon: _isRunning ? Icons.pause : Icons.play_arrow,
                          onPressed: _toggleRunning,
                          isPrimary: true,
                        ),
                        const SizedBox(width: 16),
                        _ControlButton(
                          label: l10n.timerControlReset,
                          icon: Icons.restart_alt,
                          onPressed: _resetPhase,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _nextExerciseLabel(l10n),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
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
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: onEdit,
            tooltip: 'Edit',
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
    );
  }
}

class _ExercisePlan {
  final TimerExercise exercise;
  final int totalSets;

  const _ExercisePlan({
    required this.exercise,
    required this.totalSets,
  });
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
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - thickness) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const totalSweep = 5 * math.pi / 3;
    const startAngle = 5 * math.pi / 6;
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

class _ControlButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
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

  const _ControlContent({
    required this.label,
    required this.icon,
  });

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
