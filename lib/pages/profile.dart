// lib/profile.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login.dart';

final supabase = Supabase.instance.client;

Future<Map<String, String>> getUserData() async {
  final user = supabase.auth.currentUser;
  if (user == null) throw Exception('not_authenticated');

  final response = await supabase
      .from('users')
      .select()
      .eq('uuid', user.id)
      .limit(1)
      .maybeSingle();

  if (response == null) {
    throw Exception('not_found');
  }

  final username = response['username'] as String?;
  final email = response['email'] as String?;

  return {
    'username': username ?? '',
    'email': email ?? '',
  };
}


Future<void> logout(BuildContext context) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  try {
    await supabase.auth.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  } catch (e) {
    scaffoldMessenger.showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.logoutError(e.toString()))),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[800],
              child: const Icon(
                Icons.account_circle,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, String>>(
              future: getUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError || !snapshot.hasData) {
                  var message = l10n.profileLoadingError;
                  final error = snapshot.error;
                  final errorText = error?.toString() ?? '';
                  if (errorText.contains('not_authenticated')) {
                    message = l10n.profileNotAuthenticated;
                  } else if (errorText.contains('not_found')) {
                    message = l10n.profileUserNotFound;
                  }
                  return Text(message);
                }

                final data = snapshot.data!;
                return Column(
                  children: [
                    Text(
                      data['username']!.isEmpty ? l10n.profileUnknownName : data['username']!,
                      style: const TextStyle(fontSize: 22),
                    ),
                    Text(
                      data['email']!.isEmpty ? l10n.profileUnknownEmail : data['email']!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.edit),
                title: Text(l10n.editProfile),
                onTap: () {
                  // Azione Modifica profilo
                },
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: Text(l10n.logout),
                onTap: () => logout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
