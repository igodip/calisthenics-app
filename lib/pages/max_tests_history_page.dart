import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'max_tests_page.dart';

/// Retained for existing navigation links; uses the same categories and complete
/// attempt history as the main screen, with histories expanded initially.
class MaxTestsHistoryPage extends StatelessWidget {
  const MaxTestsHistoryPage({
    super.key,
    required this.userId,
    required this.displayName,
  });
  final String userId, displayName;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(AppLocalizations.of(context)!.profileMaxTestsHistoryTitle),
    ),
    body: SafeArea(
      child: MaxTestsContent(
        userId: userId,
        displayName: displayName,
        historyExpanded: true,
      ),
    ),
  );
}
