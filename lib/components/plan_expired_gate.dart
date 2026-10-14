import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_localizations.dart';
import '../pages/profile_page.dart';
import '../pages/settings_page.dart';

/// Gates training content only. Keep enclosing navigation outside this widget.
class PlanExpiredGate extends StatefulWidget {
  const PlanExpiredGate({
    super.key,
    required this.child,
    this.bypass = false,
    this.onOpenProfile,
    this.loadAccess,
  });
  final Widget child;
  final bool bypass;
  final VoidCallback? onOpenProfile;
  final Future<bool> Function()? loadAccess;

  @override
  State<PlanExpiredGate> createState() => _PlanExpiredGateState();
}

class _PlanExpiredGateState extends State<PlanExpiredGate> {
  Future<bool>? _access;

  @override
  void initState() {
    super.initState();
    if (!widget.bypass) _access = _load();
  }

  @override
  void didUpdateWidget(PlanExpiredGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bypass != widget.bypass ||
        oldWidget.loadAccess != widget.loadAccess) {
      _access = widget.bypass ? null : _load();
    }
  }

  Future<bool> _load() async {
    if (widget.loadAccess != null) return widget.loadAccess!();
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return false;
    final payment = await client
        .from('trainee_monthly_payments')
        .select('paid')
        .eq('trainee_id', userId)
        .order('month_start', ascending: false)
        .limit(1)
        .maybeSingle();
    return payment?['paid'] == true;
  }

  void _refresh() {
    final access = _load();
    setState(() {
      _access = access;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bypass) return widget.child;
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<bool>(
      future: _access,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data == true) {
          return widget.child;
        }
        final loading = snapshot.connectionState != ConnectionState.done;
        return Material(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      Theme.of(context).colorScheme.surface,
                      Colors.black,
                      0.06,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 24),
                      if (loading)
                        const CircularProgressIndicator()
                      else
                        Icon(
                          Icons.hourglass_empty,
                          size: 56,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      const SizedBox(height: 20),
                      Text(
                        loading
                            ? l10n.trainingAccessChecking
                            : snapshot.hasError
                            ? l10n.trainingAccessErrorTitle
                            : l10n.waitingForTrainerTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        snapshot.hasError
                            ? l10n.trainingAccessErrorDescription
                            : l10n.waitingForTrainerDescription,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.icon(
                            onPressed:
                                widget.onOpenProfile ??
                                () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ProfilePage(),
                                  ),
                                ),
                            icon: const Icon(Icons.person_outline),
                            label: Text(l10n.navProfile),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SettingsPage(),
                              ),
                            ),
                            icon: const Icon(Icons.settings_outlined),
                            label: Text(l10n.accountSettingsTitle),
                          ),
                          OutlinedButton.icon(
                            onPressed: loading ? null : _refresh,
                            icon: const Icon(Icons.refresh),
                            label: Text(l10n.trainingAccessRefresh),
                          ),
                          TextButton.icon(
                            onPressed: () => logout(context),
                            icon: const Icon(Icons.logout),
                            label: Text(l10n.logout),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
