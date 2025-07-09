// lib/profile.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<Map<String, String>> getUserData() async {
  try {
    final response = await supabase.from('users').select().single();
    final username = response['username'] ?? 'Nome sconosciuto';
    final email = response['mail'] ?? 'Mail Sconosciuta';

    return {
      'username': username,
      'email': email,
    };
  } catch (e) {
    print('Errore: $e');
     return {
      'username': 'Errore nel caricamento',
      'email': 'Errore nel caricamento',
    };
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                return const Text('Errore nel caricamento dati');
              }

              final data = snapshot.data!;
              final username = data['username'] ?? 'Nome non trovato';
              final email = data['email'] ?? 'Email non trovata';

              return Column(
                children: [
                  Text(username, style: const TextStyle(fontSize: 22)),
                  Text(email, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                ],
              );
            },
          ),


          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifica profilo'),
              onTap: () {
                // Azione Modifica
              },
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                // Azione logout
              },
            ),
          ),
        ],
      ),
    );
  }
}
