import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class AdminBugReportsPage extends StatelessWidget {
  const AdminBugReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminBugReportsTitle)),
      body: const SafeArea(child: SizedBox.expand()),
    );
  }
}
