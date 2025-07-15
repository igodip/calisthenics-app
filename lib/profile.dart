// lib/profile.dart
import 'package:Calisthenics/login.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<Map<String, String>> getUserData() async {
  try {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Utente non autenticato');

    final response = await supabase
      .from('users')
      .select()
      .eq('uuid', user.id)
      .limit(1)
      .maybeSingle();

    if (response == null) {
      throw Exception('Utente non trovato nel database');
    }

    final username = response['username'] ?? 'Nome sconosciuto';
    final email = response['email'] ?? 'Email sconosciuta';

    return {
      'username': username,
      'email': email,
    };
  } catch (e) {
    return {
      'username': 'Errore nel caricamento',
      'email': 'Errore nel caricamento',
    };
  }
}


Future<void> logout(BuildContext context) async {
  try {
    await supabase.auth.signOut();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Errore durante il logout: $e')),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                  return const Text('Errore nel caricamento dati');
                }

                final data = snapshot.data!;
                return Column(
                  children: [
                    Text(data['username']!, style: const TextStyle(fontSize: 22)),
                    Text(data['email']!, style: const TextStyle(color: Colors.grey)),
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
                title: const Text('Modifica profilo'),
                onTap: () {
                  // Azione Modifica profilo
                },
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () => logout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
