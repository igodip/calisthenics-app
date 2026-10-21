import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'timer_components.dart' as timer_components;

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  final _timerKey = GlobalKey();
  bool _locked = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final heading = Row(
      children: [
        Icon(Icons.timer_outlined, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.timerTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        IconButton.filledTonal(
          key: const ValueKey('timer-lock-toggle'),
          tooltip: _locked ? l10n.timerUnlock : l10n.timerLock,
          onPressed: () => setState(() => _locked = !_locked),
          icon: Icon(_locked ? Icons.lock_open : Icons.lock_outline),
        ),
      ],
    );

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => _locked
              ? Padding(
                  key: const ValueKey('timer-locked-view'),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      heading,
                      const SizedBox(height: 8),
                      Expanded(
                        child: timer_components.WorkoutTimerPanel(
                          key: _timerKey,
                          l10n: l10n,
                          locked: true,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  key: const PageStorageKey('timer-page-scroll'),
                  padding: EdgeInsets.fromLTRB(
                    constraints.maxWidth < 360 ? 12 : 24,
                    constraints.maxHeight < 500 ? 12 : 24,
                    constraints.maxWidth < 360 ? 12 : 24,
                    24,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          heading,
                          const SizedBox(height: 16),
                          timer_components.WorkoutTimerPanel(
                            key: _timerKey,
                            l10n: l10n,
                            compact: constraints.maxHeight < 500,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
