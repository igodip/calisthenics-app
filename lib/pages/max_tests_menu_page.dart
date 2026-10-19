import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_localizations.dart';
import 'max_tests_page.dart';

/// Open the trainee's records directly, without a second profile-loading gate.
class MaxTestsMenuPage extends StatelessWidget {
  const MaxTestsMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return Center(child: Text(AppLocalizations.of(context)!.unauthenticated));
    }
    return MaxTestsContent(
      userId: user.id,
      displayName: user.email?.split('@').first ?? '',
    );
  }
}
