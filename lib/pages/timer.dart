import 'dart:async';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class TimerPage extends StatefulWidget {
  final Duration countdownDuration;

  const TimerPage({super.key, this.countdownDuration = const Duration(minutes: 5),});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.countdownDuration;
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining.inSeconds <= 1) {
        _timer?.cancel();
        setState(() {
          _remaining = Duration.zero;
        });
      } else {
        setState(() {
          _remaining -= const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final hours = _remaining.inHours.toString().padLeft(2, '0');
    final minutes = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.timerTitle)),
      body: Center(
        child: Text(
          _formattedTime,
          style: theme.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}