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

  Future<void> _openWorkoutPlan() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const WorkoutPlanPage()),
    );
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
        final avatarUrl = data?.profile?.profileImageUrl?.trim();
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          children: [
            _HomeHeader(
              displayName: displayName,
              initials: initials,
              imageUrl: (avatarUrl == null || avatarUrl.isEmpty) ? null : avatarUrl,
            ),
            const SizedBox(height: 16),
            const ProgressCard(),
            const SizedBox(height: 16),
            _ActionButtons(onOpenPlan: _openWorkoutPlan),
            const SizedBox(height: 16),
            const StrengthLevelCard(),
            const SizedBox(height: 16),
            const SkillProgressCard(),
            const SizedBox(height: 16),
            FutureBuilder<String?>(
              future: _coachTip,
              builder: (context, tipSnap) {
                if (tipSnap.connectionState != ConnectionState.done) {
                  // optional: show placeholder while loading
                  return const SizedBox.shrink();
                }
                if (tipSnap.hasError) {
                  // optional: hide on error (or show a small error widget)
                  return const SizedBox.shrink();
                }
                return CoachTipSection(tip: tipSnap.data);
              },
            ),
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
    required this.imageUrl,
  });

  final String displayName;
  final String initials;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.homeGreeting(displayName),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _AvatarChip(initials: initials, imageUrl: imageUrl),
      ],
    );
  }
}

class _AvatarChip extends StatelessWidget {
  const _AvatarChip({required this.initials, required this.imageUrl});

  final String initials;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarUrl = imageUrl?.trim();
    final avatarText = initials.isEmpty ? null : initials;
    return CircleAvatar(
      radius: 18,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: CircleAvatar(
        radius: 16,
        backgroundColor: theme.colorScheme.surface,
        backgroundImage: avatarUrl == null || avatarUrl.isEmpty
            ? null
            : NetworkImage(avatarUrl),
        child: avatarUrl == null || avatarUrl.isEmpty
            ? (avatarText == null
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
                  ))
            : null,
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onOpenPlan;
  const _ActionButtons({
      required this.onOpenPlan,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: onOpenPlan,
            child: Text(l10n.trainingStartWorkout),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            child: Text(l10n.homeViewStats),
          ),
        ),
      ],
    );
  }
}
