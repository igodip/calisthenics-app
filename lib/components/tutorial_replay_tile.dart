import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/account_access.dart';
import '../data/account_tutorial_repository.dart';
import '../l10n/app_localizations.dart';
import '../pages/account_tutorial_page.dart';

class TutorialReplayTile extends StatefulWidget {
  const TutorialReplayTile({super.key});
  @override
  State<TutorialReplayTile> createState() => _TutorialReplayTileState();
}

class _TutorialReplayTileState extends State<TutorialReplayTile> {
  bool _loading = false;
  Future<void> _open() async {
    setState(() => _loading = true);
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) return;
      final access = await AccountAccess.load(client);
      if (!mounted || client.auth.currentUser?.id != userId) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (routeContext) => AccountTutorialPage(
            access: access,
            onComplete: (skipped) async {
              await AccountTutorialRepository(
                userId,
                client: client,
              ).complete(skipped: skipped);
              if (routeContext.mounted) Navigator.of(routeContext).pop();
            },
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.trainingAccessErrorDescription,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.school_outlined),
      title: Text(AppLocalizations.of(context)!.tutorialReplay),
      trailing: _loading
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.chevron_right),
      onTap: _loading ? null : _open,
    ),
  );
}
