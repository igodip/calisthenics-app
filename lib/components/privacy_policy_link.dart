import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';

const privacyPolicyUrl =
    'https://igodip.github.io/calisthenics-app/docs/privacy-policy.html';

class PrivacyPolicyLink extends StatelessWidget {
  const PrivacyPolicyLink({super.key});

  Future<void> _open(BuildContext context) async {
    final message = AppLocalizations.of(context)!.privacyPolicyOpenError;
    try {
      if (await launchUrl(
        Uri.parse(privacyPolicyUrl),
        mode: LaunchMode.externalApplication,
      )) {
        return;
      }
    } catch (_) {
      // Keep registration and account controls usable if no browser is available.
    }
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$message\n$privacyPolicyUrl')));
    }
  }

  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: () => _open(context),
    icon: const Icon(Icons.privacy_tip_outlined),
    label: Text(AppLocalizations.of(context)!.privacyPolicyTitle),
  );
}
