import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RepCounter extends StatefulWidget {
  final String title;
  final int initialCount;
  final int? targetCount; // Optional rep goal
  final String timerType;

  const RepCounter({
    super.key,
    required this.title,
    this.initialCount = 0,
    this.targetCount,
    required this.timerType,
  });

  @override
  State<RepCounter> createState() => _RepCounterState();
}

class _RepCounterState extends State<RepCounter> {
  late int _count;

  @override
  void initState() {
    super.initState();
    _count = widget.initialCount;
  }

  void _increment() {
    final navigator = Navigator.of(context);
    setState(() {
      _count++;
      if (widget.targetCount != null && _count >= widget.targetCount!) {
        Future.delayed(const Duration(milliseconds: 300), () {
          navigator.pop(_count); // return count if needed
        });
      }
    });
  }

  void _reset() {
    setState(() => _count = 0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.timerTitle)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              '$_count',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w600),
            ),
            if (widget.targetCount != null)
              Text(
                l10n.repCounterGoalLabel(widget.targetCount!),
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _increment,
                  icon: const Icon(Icons.add),
                  iconSize: 36,
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _reset,
              child: Text(l10n.resetButtonLabel),
            ),
          ],
        ),
      ),
    );
  }
}