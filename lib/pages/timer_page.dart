import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'timer_components.dart' as timer_components;

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
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
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.timerTitle,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    timer_components.WorkoutTimerPanel(
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
