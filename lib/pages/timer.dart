import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

enum IntervalPhase { work, rest }

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

  int _nextExerciseIndex = 0;
  int _nextSet = 1;

  final List<_ExercisePlan> _exercisePlan = const [
    _ExercisePlan(name: 'Push-ups', totalSets: 3),
    _ExercisePlan(name: 'Pull-ups', totalSets: 3),
    _ExercisePlan(name: 'Squats', totalSets: 4),
    _ExercisePlan(name: 'Plank', totalSets: 2),
  ];

  @override
  void dispose() {
    _intervalTimer?.cancel();
    super.dispose();
  }

  int get _workDurationSeconds => _defaultWorkSeconds;
  int get _restDurationSeconds => _defaultRestSeconds;

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

  void _adjustTime(int deltaSeconds) {
    setState(() {
      _remainingSeconds = (_remainingSeconds + deltaSeconds).clamp(0, 36000);
    });
  }

  String _formatSeconds(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _nextExerciseLabel() {
    if (_exercisePlan.isEmpty) {
      return 'Next: --';
    }
    final plan = _exercisePlan[_nextExerciseIndex];
    return 'Next: ${plan.name} · Set $_nextSet/${plan.totalSets}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWork = _phase == IntervalPhase.work;
    final phaseLabel = isWork ? 'WORK' : 'REST';
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
            final buttonFontSize = (ringSize * 0.06).clamp(14, 22).toDouble();

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
                                  theme.colorScheme.onSurface.withOpacity(0.1),
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
                        Positioned(
                          left: 0,
                          child: _TimeAdjustButton(
                            label: '+10s',
                            onPressed: () => _adjustTime(10),
                            fontSize: buttonFontSize,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: _TimeAdjustButton(
                            label: '-10s',
                            onPressed: () => _adjustTime(-10),
                            fontSize: buttonFontSize,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ControlButton(
                          label: 'SKIP',
                          icon: Icons.skip_next,
                          onPressed: _skipPhase,
                        ),
                        const SizedBox(width: 16),
                        _ControlButton(
                          label: _isRunning ? 'PAUSE' : 'PLAY',
                          icon: _isRunning ? Icons.pause : Icons.play_arrow,
                          onPressed: _toggleRunning,
                          isPrimary: true,
                        ),
                        const SizedBox(width: 16),
                        _ControlButton(
                          label: 'RESET',
                          icon: Icons.restart_alt,
                          onPressed: _resetPhase,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _nextExerciseLabel(),
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

class _ExercisePlan {
  final String name;
  final int totalSets;

  const _ExercisePlan({
    required this.name,
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

class _TimeAdjustButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double fontSize;

  const _TimeAdjustButton({
    required this.label,
    required this.onPressed,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 72,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          shape: const StadiumBorder(),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
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
    final theme = Theme.of(context);
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
