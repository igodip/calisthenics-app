import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_localizations.dart';
import 'max_tests.dart';

final supabase = Supabase.instance.client;

class MaxTestsMenuPage extends StatefulWidget {
  const MaxTestsMenuPage({super.key});

  @override
  State<MaxTestsMenuPage> createState() => _MaxTestsMenuPageState();
}

class _MaxTestsMenuPageState extends State<MaxTestsMenuPage> {
  late Future<_MaxTestsUserData> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUserData();
  }

  Future<_MaxTestsUserData> _loadUserData() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('user-not-authenticated');
    }

    final profileResponse = await supabase
        .from('trainees')
        .select('id, name')
        .eq('id', user.id)
        .limit(1)
        .maybeSingle();

    final profileName = (profileResponse?['name'] as String?)?.trim();
    final displayName = profileName != null && profileName.isNotEmpty
        ? profileName
        : (user.email?.split('@').first ?? '');

    return _MaxTestsUserData(
      userId: user.id,
      displayName: displayName.isNotEmpty ? displayName : user.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<_MaxTestsUserData>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          final rawError = snapshot.error.toString();
          final errorText =
              rawError.contains('user-not-authenticated') ? l10n.userNotFound : rawError;
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    l10n.profileLoadError,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorText,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data;
        if (data == null) {
          return Center(child: Text(l10n.profileNoData));
        }

        return MaxTestsContent(
          userId: data.userId,
          displayName: data.displayName,
        );
      },
    );
  }
}

class _MaxTestsUserData {
  const _MaxTestsUserData({
    required this.userId,
    required this.displayName,
  });

  final String userId;
  final String displayName;
}
