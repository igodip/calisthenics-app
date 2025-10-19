// lib/profile.dart
import 'package:calisync/model/profiles.dart';
import 'package:calisync/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

  String displayName(AppLocalizations l10n) {
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
    return l10n.profileFallbackName;
  }

  String initials(AppLocalizations l10n) {
    final name = displayName(l10n);
    final nameParts = name.trim().split(RegExp(r'\s+'));
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
      .select('id, email, username, active, paid')
      .eq('id', user.id)
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
    throw Exception('user-not-found');
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
  final l10n = AppLocalizations.of(context)!;
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
      SnackBar(content: Text(l10n.logoutError('$e'))),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<UserProfileData>(
          future: getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              final rawError = snapshot.error.toString();
              final errorText =
                  rawError.contains('user-not-found') ? l10n.userNotFound : rawError;
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

            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;
            final appColors = theme.extension<AppColors>()!;
            final statusChipTextStyle =
                theme.textTheme.labelMedium?.copyWith(color: colorScheme.onPrimary);
            final displayName = data.displayName(l10n);
            final emailText = data.email.isEmpty ? l10n.profileEmailUnavailable : data.email;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _ProfileAvatar(data: data),
                  const SizedBox(height: 16),
                  Text(
                    displayName,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    emailText,
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
                          color: colorScheme.onPrimary,
                        ),
                        label: Text(
                          data.isActive ? l10n.profileStatusActive : l10n.profileStatusInactive,
                          style: statusChipTextStyle,
                        ),
                        backgroundColor:
                            data.isActive ? appColors.success : colorScheme.outlineVariant,
                      ),
                      Chip(
                        avatar: Icon(
                          data.isPayed ? Icons.workspace_premium : Icons.lock_clock,
                          color: colorScheme.onPrimary,
                        ),
                        label: Text(
                          data.isPayed ? l10n.profilePlanActive : l10n.profilePlanExpired,
                          style: statusChipTextStyle,
                        ),
                        backgroundColor:
                            data.isPayed ? colorScheme.secondary : appColors.warning,
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
                          title: Text(l10n.profileUsername),
                          subtitle: Text(data.username.isEmpty ? '-' : data.username),
                        ),
                        const Divider(height: 0),
                        ListTile(
                          leading: const Icon(Icons.schedule),
                          title: Text(l10n.profileLastUpdated),
                          subtitle: Text(
                            data.updatedAt != null
                                ? _formatDate(data.updatedAt!)
                                : l10n.profileValueUnavailable,
                          ),
                        ),
                        const Divider(height: 0),
                        ListTile(
                          leading: const Icon(Icons.public),
                          title: Text(l10n.profileTimezone),
                          subtitle: Text(data.timezone ?? l10n.profileNotSet),
                        ),
                        const Divider(height: 0),
                        ListTile(
                          leading: const Icon(Icons.straighten),
                          title: Text(l10n.profileUnitSystem),
                          subtitle: Text(data.unitSystem ?? l10n.profileNotSet),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: Text(l10n.profileEdit),
                      subtitle: Text(l10n.profileComingSoon),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.featureUnavailable)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => logout(context),
                      icon: const Icon(Icons.logout),
                      label: Text(l10n.logout),
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
    final l10n = AppLocalizations.of(context)!;

    return CircleAvatar(
      radius: 48,
      backgroundColor: backgroundColor,
      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
          ? NetworkImage(avatarUrl)
          : null,
      child: (avatarUrl == null || avatarUrl.isEmpty)
          ? Text(
              data.initials(l10n),
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
            )
          : null,
    );
  }
}
