import 'package:calisync/components/coach_tip.dart';
import 'package:calisync/pages/workout_plan_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/progress_card.dart';
import '../components/skill_progress_card.dart';
import '../components/strength_level_card.dart';
import '../l10n/app_localizations.dart';
import 'profile.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late Future<UserProfileData> _profileFuture;
  late Future<String?> _coachTip;

  @override
  void initState() {
    super.initState();
    final client = Supabase.instance.client;
    _profileFuture = getUserData();
    _coachTip = _loadCoachTipForUser(Supabase.instance.client, client.auth.currentUser!.id);
  }

  Future<String?> _loadCoachTipForUser(
      SupabaseClient client,
      String userId,
      ) async {
    final response = await client
        .from('trainee_trainers')
        .select('coach_tip')
        .eq('trainee_id', userId)
        .maybeSingle();
    if (response == null) {
      return null;
    }
    final tip = response['coach_tip'] as String?;
    return tip?.trim().isEmpty ?? true ? null : tip?.trim();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<UserProfileData>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final displayName = data?.displayName(l10n) ?? l10n.profileFallbackName;
        final initials = data?.initials(l10n) ?? '';
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          children: [
            _HomeHeader(
              displayName: displayName,
              initials: initials,
            ),
            const SizedBox(height: 16),
            const ProgressCard(),
            const SizedBox(height: 16),
            const _ActionButtons(),
            const SizedBox(height: 16),
            const StrengthLevelCard(),
            const SizedBox(height: 16),
            const SkillProgressCard(),
            const SizedBox(height: 16),
            const CoachTipSection()
          ],
        );
      },
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.displayName,
    required this.initials,
  });

  final String displayName;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            'Hi, $displayName!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _AvatarChip(initials: initials),
      ],
    );
  }
}

class _AvatarChip extends StatelessWidget {
  const _AvatarChip({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarText = initials.isEmpty ? null : initials;
    return CircleAvatar(
      radius: 18,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: CircleAvatar(
        radius: 16,
        backgroundColor: theme.colorScheme.surface,
        child: avatarText == null
            ? Icon(
                Icons.person,
                color: theme.colorScheme.onSurfaceVariant,
                size: 18,
              )
            : Text(
                avatarText,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: () {},
            child: const Text('Start Workout'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            child: const Text('View Stats'),
          ),
        ),
      ],
    );
  }
}


