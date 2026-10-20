import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';

class UserIdSection extends StatelessWidget {
  const UserIdSection({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final id = Supabase.instance.client.auth.currentUser?.id;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.userIdTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(id ?? l10n.userIdUnavailable),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: id == null
                  ? null
                  : () async {
                      await Clipboard.setData(ClipboardData(text: id));

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(l10n.copied)));
                    },
              icon: const Icon(Icons.content_copy),
              label: Text(l10n.copy),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
