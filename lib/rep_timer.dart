import 'dart:async';
import 'package:flutter/material.dart';

class RepTimerWidget extends StatefulWidget {
  final String title;
  final Duration countdownDuration;
  final int initialRepCount;
  final int? targetRepCount;

  const RepTimerWidget({
    super.key,
    required this.title,
    this.countdownDuration = const Duration(minutes: 5),
    this.initialRepCount = 0,
    this.targetRepCount,
  });

  @override
  State<RepTimerWidget> createState() => _RepTimerWidgetState();
}

class _RepTimerWidgetState extends State<RepTimerWidget> {
  late Duration _remaining;
  Timer? _timer;
  bool _isRunning = false;

  late int _repCount;

  @override
  void initState() {
    super.initState();
    _remaining = widget.countdownDuration;
    _repCount = widget.initialRepCount;
  }

  void _startTimer() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining.inSeconds <= 1) {
        _stopTimer();
        setState(() => _remaining = Duration.zero);
      } else {
        setState(() {
          _remaining -= const Duration(seconds: 1);
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _isRunning = false;
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _remaining = widget.countdownDuration;
    });
  }

  void _incrementRep() {
    setState(() {
      _repCount++;
      if (widget.targetRepCount != null &&
          _repCount >= widget.targetRepCount!) {
        // Optionally do something on reaching goal
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Rep goal reached!')));
      }
    });
  }

  void _decrementRep() {
    if (_repCount > 0) {
      setState(() => _repCount--);
    }
  }

  void _resetRep() {
    setState(() => _repCount = 0);
  }

  String get _formattedTime {
    final hours = _remaining.inHours.toString().padLeft(2, '0');
    final minutes = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: Text("Timer")),
  //     body: Center(
  //       child: Text(
  //         _formattedTime,
  //         style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(16),
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Timer section
                  Text(
                    _formattedTime,
                    style: const TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _isRunning ? _stopTimer : _startTimer,
                        child: Text(_isRunning ? 'Pause' : 'Start'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _resetTimer,
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const Divider(height: 40),
                  // Rep counter section
                  Text(
                    'Serie: $_repCount',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.targetRepCount != null)
                    Text(
                      'Goal: ${widget.targetRepCount}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: 36,
                        icon: const Icon(Icons.remove),
                        onPressed: _decrementRep,
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        iconSize: 36,
                        icon: const Icon(Icons.add),
                        onPressed: _incrementRep,
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _resetRep,
                    child: const Text('Reset Reps'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
