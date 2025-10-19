// lib/profile.dart
import 'package:calisync/model/profiles.dart';
import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login.dart';

final supabase = Supabase.instance.client;

class UserProfileData {
  const UserProfileData({
    required this.userId,
    required this.email,
    required this.username,
    required this.isActive,
    required this.isPayed,
    this.profile,
  });

  final String userId;
  final String email;
  final String username;
  final bool isActive;
  final bool isPayed;
  final Profiles? profile;

  String get displayName {
    final fullName = profile?.fullName?.trim();
    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    }
    if (username.trim().isNotEmpty) {
      return username;
    }
    if (email.trim().isNotEmpty) {
      return email.split('@').first;
    }
    return 'Utente';
  }

  String get initials {
    final nameParts = displayName.trim().split(RegExp(r'\s+'));
    if (nameParts.length == 1) {
      return nameParts.first.characters.take(2).toString().toUpperCase();
    }
    return nameParts.take(2).map((part) => part.characters.first).join().toUpperCase();
  }

  String? get avatarUrl => profile?.avatarUrl;
  String? get timezone => profile?.timezone;
  String? get unitSystem => profile?.unitSystem;
  DateTime? get createdAt => profile?.createdAt;
  DateTime? get updatedAt => profile?.updatedAt;
}

Future<UserProfileData> getUserData() async {
  final user = supabase.auth.currentUser;
  if (user == null) {
    throw Exception('Utente non autenticato');
  }

  final usersResponse = await supabase
      .from('users')
      .select('uuid, email, username, active, payed')
      .eq('uuid', user.id)
      .limit(1)
      .maybeSingle();

  final profileResponse = await supabase
      .from('profiles')
      .select(
          'id, full_name, avatar_url, unit_system, timezone, created_at, updated_at')
      .eq('id', user.id)
      .limit(1)
      .maybeSingle();

  if (usersResponse == null && profileResponse == null) {
    throw Exception('Utente non trovato nel database');
  }

  final profile = profileResponse != null ? Profiles.fromMap(profileResponse) : null;
  final email = (usersResponse?['email'] as String?) ?? user.email ?? '';
  final username = (usersResponse?['username'] as String?) ??
      (user.email != null ? user.email!.split('@').first : '');

  return UserProfileData(
    userId: user.id,
    email: email,
    username: username,
    isActive: (usersResponse?['active'] as bool?) ?? false,
    isPayed: (usersResponse?['payed'] as bool?) ?? false,
    profile: profile,
  );
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
      SnackBar(content: Text('Errore durante il logout: $e')),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<UserProfileData>(
          future: getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Errore nel caricamento dati',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
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
              return const Center(child: Text('Nessun dato disponibile'));
            }

            final theme = Theme.of(context);
            final statusChipTextStyle = theme.textTheme.labelMedium?.copyWith(color: Colors.white);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _ProfileAvatar(data: data),
                  const SizedBox(height: 16),
                  Text(
                    data.displayName,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.email.isEmpty ? 'Email non disponibile' : data.email,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: Icon(
                          data.isActive ? Icons.check_circle : Icons.pause_circle_filled,
                          color: Colors.white,
                        ),
                        label: Text(
                          data.isActive ? 'Account attivo' : 'Account inattivo',
                          style: statusChipTextStyle,
                        ),
                        backgroundColor:
                            data.isActive ? Colors.green.shade600 : Colors.grey.shade600,
                      ),
                      Chip(
                        avatar: Icon(
                          data.isPayed ? Icons.workspace_premium : Icons.lock_clock,
                          color: Colors.white,
                        ),
                        label: Text(
                          data.isPayed ? 'Piano attivo' : 'Piano scaduto',
                          style: statusChipTextStyle,
                        ),
                        backgroundColor:
                            data.isPayed ? Colors.blue.shade600 : Colors.orange.shade600,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.badge_outlined),
                          title: const Text('Username'),
                          subtitle: Text(data.username.isEmpty ? '-' : data.username),
                        ),
                        const Divider(height: 0),
                        ListTile(
                          leading: const Icon(Icons.schedule),
                          title: const Text('Ultimo aggiornamento'),
                          subtitle: Text(
                            data.updatedAt != null
                                ? _formatDate(data.updatedAt!)
                                : 'Non disponibile',
                          ),
                        ),
                        const Divider(height: 0),
                        ListTile(
                          leading: const Icon(Icons.public),
                          title: const Text('Fuso orario'),
                          subtitle: Text(data.timezone ?? 'Non impostato'),
                        ),
                        const Divider(height: 0),
                        ListTile(
                          leading: const Icon(Icons.straighten),
                          title: const Text('Unità di misura'),
                          subtitle: Text(data.unitSystem ?? 'Non impostato'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: const Text('Modifica profilo'),
                      subtitle: const Text('Presto disponibile'),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Funzionalità non ancora disponibile.')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => logout(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.data});

  final UserProfileData data;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = data.avatarUrl;
    final backgroundColor = Theme.of(context).colorScheme.primaryContainer;

    return CircleAvatar(
      radius: 48,
      backgroundColor: backgroundColor,
      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
          ? NetworkImage(avatarUrl)
          : null,
      child: (avatarUrl == null || avatarUrl.isEmpty)
          ? Text(
              data.initials,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
            )
          : null,
    );
  }
}
