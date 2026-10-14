import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../pages/login_page.dart';

class AccountDeletionSection extends StatefulWidget {
  const AccountDeletionSection({super.key, this.deleteAccount});

  final Future<void> Function()? deleteAccount;

  @override
  State<AccountDeletionSection> createState() => _AccountDeletionSectionState();
}

class _AccountDeletionSectionState extends State<AccountDeletionSection> {
  bool _deleting = false;

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccountTitle),
        content: Text(l10n.deleteAccountConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.trainerCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.deleteAccountTitle),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _deleting = true);
    try {
      if (widget.deleteAccount != null) {
        await widget.deleteAccount!();
      } else {
        final client = Supabase.instance.client;
        final response = await client.functions.invoke(
          'delete-account',
          body: {'confirm': true},
        );
        if (response.status != 200 ||
            response.data is! Map ||
            response.data['deleted'] != true) {
          throw StateError('Account deletion was not completed');
        }
        await client.auth.signOut(scope: SignOutScope.local);
        final preferences = await SharedPreferences.getInstance();
        for (final key in preferences.getKeys()) {
          if (key.startsWith('cached_profile_image_url:') ||
              key.startsWith('timer_')) {
            await preferences.remove(key);
          }
        }
      }
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.deleteAccountError)));
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.deleteAccountTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(l10n.deleteAccountDescription),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _deleting ? null : _delete,
              icon: _deleting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_forever_outlined),
              label: Text(
                _deleting
                    ? l10n.deleteAccountProgress
                    : l10n.deleteAccountTitle,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
