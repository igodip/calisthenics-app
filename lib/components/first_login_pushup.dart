import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'home_mascot_setting.dart';
export 'home_mascot_setting.dart' show AthleteAuraStyle;

enum WelcomeExercise {
  pushUp,
  handstandPushUp,
  pullUp,
  muscleUp,
  squat,
  dip,
  lSit,
  australianRow,
  lunge,
  jumpingJack,
  tricepsExtension,
}

WelcomeExercise chooseWelcomeExercise(
  math.Random random, {
  WelcomeExercise? previous,
}) {
  final choices = WelcomeExercise.values
      .where((value) => value != previous)
      .toList();
  return choices[random.nextInt(choices.length)];
}

/// Optional, continuous decoration while Home is in the foreground.
class FirstLoginPushup extends StatefulWidget {
  const FirstLoginPushup({super.key, required this.userId, this.loadAura});

  final String userId;
  final Future<bool> Function()? loadAura;

  @override
  State<FirstLoginPushup> createState() => _FirstLoginPushupState();
}

class _FirstLoginPushupState extends State<FirstLoginPushup>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  );
  bool _visible = false;
  bool _initialized = false;
  bool _restartOnResume = false;
  bool _foreground = true;
  final _random = math.Random();
  WelcomeExercise? _exercise;
  bool _aura = false;
  bool _changingAura = false;
  int _auraRequest = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    HomeMascotSettings.enabled.addListener(_settingChanged);
    HomeMascotSettings.auraStyle.addListener(_auraSettingChanged);
    unawaited(HomeMascotSettings.load());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _welcome();
    } else if (_visible) {
      _runAnimation();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (state == AppLifecycleState.resumed) {
      if (_restartOnResume) _welcome();
      _restartOnResume = false;
    } else {
      _restartOnResume = true;
      _controller.stop();
      _auraRequest++;
      if (_visible) setState(() => _visible = false);
    }
  }

  void _welcome() {
    _auraRequest++;
    _controller.stop();
    if (widget.userId.isEmpty ||
        !HomeMascotSettings.enabled.value ||
        !_foreground) {
      if (_visible) setState(() => _visible = false);
      return;
    }
    setState(() {
      _exercise = chooseWelcomeExercise(_random, previous: _exercise);
      _visible = true;
      _aura = false;
    });
    _controller.value = 0;
    _runAnimation();
    unawaited(_refreshAura());
  }

  Future<void> _refreshAura() async {
    final load = widget.loadAura;
    if (load == null) return;
    final request = ++_auraRequest;
    var aura = false;
    try {
      aura = await load();
    } catch (_) {
      // Decorative enhancement must never block Home or expose plan errors.
    }
    if (mounted && _visible && request == _auraRequest) {
      setState(() => _aura = aura);
    }
  }

  void _settingChanged() {
    if (mounted && _initialized) _welcome();
  }

  void _auraSettingChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _toggleAura() async {
    if (!_aura || _changingAura) return;
    _changingAura = true;
    try {
      await HomeMascotSettings.setAuraStyle(
        HomeMascotSettings.auraStyle.value == AthleteAuraStyle.dragonBall
            ? AthleteAuraStyle.naruto
            : AthleteAuraStyle.dragonBall,
      );
    } catch (_) {
      debugPrint('Unable to save the athlete aura preference.');
    } finally {
      _changingAura = false;
    }
  }

  void _runAnimation() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    HomeMascotSettings.enabled.removeListener(_settingChanged);
    HomeMascotSettings.auraStyle.removeListener(_auraSettingChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final auraStyle = HomeMascotSettings.auraStyle.value;
    return ExcludeSemantics(
      excluding: !_aura,
      child: SafeArea(
        top: false,
        child: SizedBox(
          key: const ValueKey('first-login-pushup'),
          height: 56,
          child: Center(
            child: Semantics(
              button: _aura,
              label: auraStyle == AthleteAuraStyle.dragonBall
                  ? l10n.homeMascotAuraDragonBall
                  : l10n.homeMascotAuraNaruto,
              hint: l10n.homeMascotAuraSwitch,
              onTap: _aura ? _toggleAura : null,
              child: Tooltip(
                message: l10n.homeMascotAuraSwitch,
                excludeFromSemantics: true,
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    key: const ValueKey('home-mascot-aura-switch'),
                    onTap: _aura ? _toggleAura : null,
                    excludeFromSemantics: true,
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 110,
                      height: 48,
                      child: RepaintBoundary(
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) => CustomPaint(
                            size: const Size(110, 48),
                            painter: WelcomeExercisePainter(
                              exercise: _exercise!,
                              aura: _aura,
                              auraStyle: auraStyle,
                              progress: MediaQuery.disableAnimationsOf(context)
                                  ? 0
                                  : _controller.value,
                              color: colors.primary,
                              floorColor: colors.outlineVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WelcomeExercisePainter extends CustomPainter {
  const WelcomeExercisePainter({
    required this.exercise,
    required this.progress,
    required this.color,
    required this.floorColor,
    this.aura = false,
    this.auraStyle = AthleteAuraStyle.dragonBall,
  });

  final double progress;
  final WelcomeExercise exercise;
  final Color color;
  final Color floorColor;
  final bool aura;
  final AthleteAuraStyle auraStyle;

  @override
  void paint(Canvas canvas, Size size) {
    // Five controlled repetitions per loop, with no display time limit.
    final bend = (1 - math.cos(progress * math.pi * 10)) / 2;
    if (aura) {
      switch (auraStyle) {
        case AthleteAuraStyle.dragonBall:
          _paintAura(canvas);
        case AthleteAuraStyle.naruto:
          _paintNarutoAura(canvas);
      }
    }
    final shoulder = Offset(76, 18 + 13 * bend);
    final hip = Offset(46, 26 + 6 * bend);
    final paint = Paint()
      ..color = aura
          ? (auraStyle == AthleteAuraStyle.dragonBall
                ? const Color(0xFFFFD65A)
                : const Color(0xFFFFA044))
          : color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      const Offset(12, 42),
      const Offset(100, 42),
      Paint()
        ..color = floorColor
        ..strokeWidth = 1,
    );
    void line(Offset from, Offset to) => canvas.drawLine(from, to, paint);
    void head(Offset center) => canvas.drawCircle(center, 4, paint);
    void chain(List<Offset> points) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, paint);
    }

    switch (exercise) {
      case WelcomeExercise.handstandPushUp:
        final shoulder = Offset(55, 25 + 7 * bend);
        head(Offset(55, shoulder.dy + 7));
        line(shoulder, Offset(55, 13 + 7 * bend));
        chain([
          Offset(49, 2 + 7 * bend),
          Offset(55, 13 + 7 * bend),
          Offset(61, 2 + 7 * bend),
        ]);
        chain([
          const Offset(41, 39),
          Offset(43 - 5 * bend, 30 + 4 * bend),
          shoulder,
          Offset(67 + 5 * bend, 30 + 4 * bend),
          const Offset(69, 39),
        ]);
        return;
      case WelcomeExercise.pullUp:
        line(const Offset(29, 6), const Offset(81, 6));
        final shoulder = Offset(55, 24 - 12 * bend);
        head(Offset(55, shoulder.dy - 6));
        chain([
          const Offset(39, 6),
          Offset(36, 17 - 5 * bend),
          shoulder,
          Offset(74, 17 - 5 * bend),
          const Offset(71, 6),
        ]);
        final hip = Offset(55, shoulder.dy + 11);
        line(shoulder, hip);
        chain([Offset(48, hip.dy + 6), hip, Offset(62, hip.dy + 6)]);
        return;
      case WelcomeExercise.muscleUp:
        line(const Offset(27, 20), const Offset(83, 20));
        // Pull, transition over the bar, then press into straight-arm support.
        final lift = Curves.easeInOut.transform(bend);
        final shoulder = Offset(
          55 + 4 * math.sin(lift * math.pi),
          30 - 19 * lift,
        );
        head(Offset(shoulder.dx, shoulder.dy - 7));
        chain([
          const Offset(39, 20),
          Offset(40, 27 - 12 * lift),
          shoulder,
          Offset(70, 27 - 12 * lift),
          const Offset(71, 20),
        ]);
        final hip = Offset(shoulder.dx - 2, shoulder.dy + 8);
        line(shoulder, hip);
        chain([
          Offset(hip.dx - 5, hip.dy + 4),
          hip,
          Offset(hip.dx + 7, hip.dy + 4),
        ]);
        return;
      case WelcomeExercise.squat:
        final hip = Offset(53 - 8 * bend, 27 + 6 * bend);
        final shoulder = Offset(55 + 3 * bend, 14 + 7 * bend);
        head(Offset(shoulder.dx, shoulder.dy - 7));
        line(shoulder, hip);
        chain([
          const Offset(45, 39),
          Offset(43 - 3 * bend, 33),
          hip,
          Offset(63 + 4 * bend, 33),
          const Offset(65, 39),
        ]);
        chain([shoulder, Offset(63, 24 + 2 * bend), Offset(71, 18 + 4 * bend)]);
        return;
      case WelcomeExercise.dip:
        // Fixed parallel bars; the athlete lowers between them.
        chain([
          const Offset(35, 40),
          const Offset(35, 24),
          const Offset(45, 24),
        ]);
        chain([
          const Offset(75, 40),
          const Offset(75, 24),
          const Offset(65, 24),
        ]);
        final shoulder = Offset(55, 14 + 9 * bend);
        final hip = Offset(55, 27 + 9 * bend);
        head(Offset(55, shoulder.dy - 7));
        line(shoulder, hip);
        chain([
          const Offset(42, 24),
          Offset(41 - 3 * bend, 20 + 8 * bend),
          shoulder,
          Offset(69 + 3 * bend, 20 + 8 * bend),
          const Offset(68, 24),
        ]);
        chain([hip, Offset(62, 30 + 5 * bend), const Offset(70, 39)]);
        return;
      case WelcomeExercise.lSit:
        // Small controlled leg lifts from a supported L-sit.
        chain([
          const Offset(36, 40),
          const Offset(36, 27),
          const Offset(49, 27),
        ]);
        chain([
          const Offset(61, 27),
          const Offset(70, 27),
          const Offset(70, 40),
        ]);
        final shoulder = Offset(55, 15 - bend);
        final hip = Offset(55, 28 - bend);
        head(Offset(55, shoulder.dy - 7));
        line(shoulder, hip);
        line(shoulder, const Offset(44, 27));
        line(shoulder, const Offset(65, 27));
        chain([
          hip,
          Offset(77, 28 - 5 * bend),
          Offset(93, 28 - 5 * bend),
          Offset(96, 25 - 5 * bend),
        ]);
        return;
      case WelcomeExercise.australianRow:
        // Feet stay planted while the chest rises toward a low bar.
        chain([const Offset(89, 40), const Offset(89, 8), const Offset(70, 8)]);
        final shoulder = Offset(69 + 3 * bend, 26 - 10 * bend);
        final hip = Offset(46, 32 - 5 * bend);
        head(Offset(shoulder.dx + 8, shoulder.dy - 4));
        chain([const Offset(20, 39), hip, shoulder]);
        chain([
          shoulder,
          Offset(72 - 5 * bend, 18 - 3 * bend),
          const Offset(76, 8),
        ]);
        return;
      case WelcomeExercise.lunge:
        final shoulder = Offset(55, 13 + 7 * bend);
        final hip = Offset(52, 26 + 5 * bend);
        head(Offset(55, shoulder.dy - 7));
        line(shoulder, hip);
        chain([
          const Offset(25, 39),
          Offset(35, 30 + 8 * bend),
          hip,
          Offset(71, 30 + 4 * bend),
          const Offset(79, 39),
        ]);
        chain([shoulder, Offset(46, 23 + 5 * bend), Offset(58, 24 + 5 * bend)]);
        return;
      case WelcomeExercise.jumpingJack:
        const shoulder = Offset(55, 15);
        const hip = Offset(55, 27);
        head(const Offset(55, 8));
        line(shoulder, hip);
        chain([Offset(43 - 13 * bend, 39), hip, Offset(67 + 13 * bend, 39)]);
        chain([
          Offset(38 - 7 * bend, 30 - 28 * bend),
          Offset(44 - 5 * bend, 23 - 14 * bend),
          shoulder,
          Offset(66 + 5 * bend, 23 - 14 * bend),
          Offset(72 + 7 * bend, 30 - 28 * bend),
        ]);
        return;
      case WelcomeExercise.tricepsExtension:
        chain([
          const Offset(96, 40),
          const Offset(96, 21),
          const Offset(87, 21),
        ]);
        final shoulder = Offset(75 - 8 * bend, 17 + 8 * bend);
        head(Offset(83 - 8 * bend, 12 + 8 * bend));
        chain([const Offset(21, 39), Offset(48, 27 + 5 * bend), shoulder]);
        chain([
          shoulder,
          Offset(80 - 9 * bend, 25 + 4 * bend),
          const Offset(91, 21),
        ]);
        return;
      case WelcomeExercise.pushUp:
        break;
    }
    canvas.drawPath(
      Path()
        ..moveTo(19, 39)
        ..lineTo(hip.dx, hip.dy)
        ..lineTo(shoulder.dx, shoulder.dy)
        ..lineTo(83, shoulder.dy - 2),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(shoulder.dx, shoulder.dy)
        ..lineTo(72 - 8 * bend, (shoulder.dy + 39) / 2)
        ..lineTo(85, 39)
        ..lineTo(91, 39),
      paint,
    );
    canvas.drawCircle(Offset(89, shoulder.dy - 4), 4.5, paint);
    canvas.drawLine(const Offset(16, 39), const Offset(23, 39), paint);
  }

  @override
  bool shouldRepaint(covariant WelcomeExercisePainter oldDelegate) =>
      oldDelegate.aura != aura ||
      oldDelegate.auraStyle != auraStyle ||
      oldDelegate.exercise != exercise ||
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.floorColor != floorColor;

  void _paintNarutoAura(Canvas canvas) {
    final phase = progress * math.pi * 10;
    final pulse = (1 + math.sin(phase)) / 2;
    canvas.drawOval(
      const Rect.fromLTWH(12, 1, 88, 41),
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFB64D).withValues(alpha: .16 + pulse * .1),
            const Color(0xFFFF6500).withValues(alpha: .04),
            Colors.transparent,
          ],
        ).createShader(const Rect.fromLTWH(12, 1, 88, 41)),
    );
    final chakra = Paint()
      ..color = const Color(0xFFFF7B27).withValues(alpha: .55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    // Flowing chakra tails, rather than Dragon Ball's angular lightning.
    for (var index = 0; index < 3; index++) {
      final sway = math.sin(phase + index) * 3;
      canvas.drawPath(
        Path()
          ..moveTo(43 + index * 5, 38)
          ..cubicTo(
            18 + index * 4,
            35,
            13 + sway,
            13 + index * 4,
            23 + sway,
            5 + index * 3,
          ),
        chakra,
      );
      canvas.drawPath(
        Path()
          ..moveTo(65 - index * 4, 38)
          ..cubicTo(
            89 - index * 3,
            36,
            99 - sway,
            22,
            88 - sway,
            6 + index * 4,
          ),
        chakra,
      );
    }
    for (var index = 0; index < 7; index++) {
      final angle = phase + index * math.pi * 2 / 7;
      canvas.drawCircle(
        Offset(55 + math.cos(angle) * 35, 23 + math.sin(angle) * 17),
        1.1,
        Paint()..color = const Color(0xFFFFC66F).withValues(alpha: .75),
      );
    }
    // A small spinning blue chakra sphere contrasts with the orange cloak.
    const orb = Offset(99, 16);
    canvas.drawCircle(
      orb,
      5,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFDBFAFF), Color(0x994ABEFF), Color(0x00308EFF)],
        ).createShader(const Rect.fromLTWH(93, 10, 12, 12)),
    );
    canvas.drawArc(
      Rect.fromCircle(center: orb, radius: 3),
      phase,
      math.pi * 1.5,
      false,
      Paint()
        ..color = const Color(0xFF81DCFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _paintAura(Canvas canvas) {
    final pulse = (1 + math.sin(progress * math.pi * 40)) / 2;
    final flame = Path()
      ..moveTo(18, 41)
      ..lineTo(27, 24)
      ..lineTo(24, 19)
      ..lineTo(36, 25)
      ..lineTo(33, 8)
      ..lineTo(47, 17)
      ..lineTo(55, 1)
      ..lineTo(61, 16)
      ..lineTo(76, 7)
      ..lineTo(72, 24)
      ..lineTo(88, 17)
      ..lineTo(86, 31)
      ..lineTo(96, 41)
      ..close();
    canvas.drawPath(
      flame,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFEE8B).withValues(alpha: .18 + pulse * .12),
            const Color(0xFFFFB300).withValues(alpha: .05),
          ],
        ).createShader(const Rect.fromLTWH(12, 0, 86, 46)),
    );
    final energy = Paint()
      ..color = const Color(0xFFFFD65A).withValues(alpha: .65);
    for (var index = 0; index < 6; index++) {
      final rise = (progress * 5 + index / 6) % 1;
      canvas.drawCircle(
        Offset(23 + index * 13, 40 - rise * 36),
        1 - rise * .5,
        energy,
      );
    }
    if (pulse > .8) {
      canvas.drawPath(
        Path()
          ..moveTo(29, 14)
          ..lineTo(25, 25)
          ..lineTo(30, 23)
          ..lineTo(27, 34),
        Paint()
          ..color = const Color(0xFFFFF0B0).withValues(alpha: .7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }
}
