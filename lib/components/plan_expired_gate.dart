import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_localizations.dart';

final supabase = Supabase.instance.client;

class PlanExpiredGate extends StatefulWidget {
  final Widget child;
  final bool useOverlay;

  const PlanExpiredGate({
    super.key,
    required this.child,
    this.useOverlay = false,
  });

  @override
  State<PlanExpiredGate> createState() => _PlanExpiredGateState();
}

class _PlanExpiredGateState extends State<PlanExpiredGate> {
  late Future<bool> _expiredFuture;

  @override
  void initState() {
    super.initState();
    _expiredFuture = _fetchLatestPlanExpired();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _expiredFuture,
      builder: (context, snapshot) {
        final isWaiting = snapshot.connectionState == ConnectionState.waiting;
        final isExpired = snapshot.data == false;
        if (widget.useOverlay) {
          return Stack(
            children: [
              AbsorbPointer(
                absorbing: isWaiting || isExpired,
                child: widget.child,
              ),
              if (isWaiting)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x88000000),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              if (!isWaiting && isExpired)
                Positioned.fill(
                  child: _ExpiredPlanCover(
                    title: AppLocalizations.of(context)!.profilePlanExpired,
                    description: AppLocalizations.of(context)!.homeEmptyDescription,
                  ),
                ),
            ],
          );
        }

        if (isWaiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (isExpired) {
          return _ExpiredPlanScreen(
            title: AppLocalizations.of(context)!.profilePlanExpired,
            description: AppLocalizations.of(context)!.homeEmptyDescription,
          );
        }

        return widget.child;
      },
    );
  }

  Future<bool> _fetchLatestPlanExpired() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return false;

    final paymentResponse = await supabase
        .from('trainee_monthly_payments')
        .select('paid, month_start')
        .eq('trainee_id', userId)
        .order('month_start', ascending: false)
        .limit(1)
        .maybeSingle();

    return paymentResponse?['paid'] as bool? ?? false;
  }
}

class _ExpiredPlanScreen extends StatelessWidget {
  final String title;
  final String description;

  const _ExpiredPlanScreen({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: _ExpiredPlanContent(
        title: title,
        description: description,
      ),
    );
  }
}

class _ExpiredPlanCover extends StatelessWidget {
  final String title;
  final String description;

  const _ExpiredPlanCover({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.surface.withValues(alpha: 0.9),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Card(
              margin: const EdgeInsets.all(24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _ExpiredPlanContent(
                  title: title,
                  description: description,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpiredPlanContent extends StatelessWidget {
  final String title;
  final String description;

  const _ExpiredPlanContent({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.assignment_late_outlined,
          size: 64,
          color: theme.colorScheme.error,
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
