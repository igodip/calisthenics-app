import 'package:calisync/components/coach_tip.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/progress_card.dart';
import '../components/skill_progress_card.dart';
import '../components/strength_level_card.dart';
import '../data/exercise_guides.dart';
import '../data/exercise_unlocks.dart';
import '../l10n/app_localizations.dart';
import 'profile.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({
    super.key,
    required this.onOpenPlan,
    required this.onViewStats,
  });

  final VoidCallback onOpenPlan;
  final VoidCallback onViewStats;

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late Future<UserProfileData> _profileFuture;
  late Future<String?> _coachTip;
  Future<_ExerciseUnlockSummary>? _unlockSummaryFuture;
  String? _localeName;

  @override
  void initState() {
    super.initState();
    final client = Supabase.instance.client;
    _profileFuture = getUserData();
    _coachTip = _loadCoachTipForUser(Supabase.instance.client, client.auth.currentUser!.id);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    if (_unlockSummaryFuture == null || _localeName != l10n.localeName) {
      _localeName = l10n.localeName;
      _unlockSummaryFuture = _loadExerciseSummary(l10n.localeName);
    }
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

  Future<_ExerciseUnlockSummary> _loadExerciseSummary(String localeName) async {
    final guides = await ExerciseGuides.load(localeName);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final unlockedSlugs = userId == null
        ? <String>{}
        : await ExerciseUnlocks.loadUnlockedExerciseSlugs(userId);
    final unlockedCount = guides
        .where((guide) => guide.isUnlocked || unlockedSlugs.contains(guide.id))
        .length;
    return _ExerciseUnlockSummary(
      unlockedSkills: unlockedCount,
      totalSkills: guides.length,
    );
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
            _ActionButtons(
              onOpenPlan: widget.onOpenPlan,
              onViewStats: widget.onViewStats,
            ),
            const SizedBox(height: 16),
            const StrengthLevelCard(),
            const SizedBox(height: 16),
            FutureBuilder<_ExerciseUnlockSummary>(
              future: _unlockSummaryFuture,
              builder: (context, summarySnap) {
                final summary = summarySnap.data ??
                    const _ExerciseUnlockSummary(
                      unlockedSkills: 0,
                      totalSkills: 0,
                    );
                return SkillProgressCard(
                  unlockedSkills: summary.unlockedSkills,
                  totalSkills: summary.totalSkills,
                );
              },
            ),
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
  final VoidCallback onViewStats;
  const _ActionButtons({
      required this.onOpenPlan,
      required this.onViewStats,
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
            onPressed: onViewStats,
            child: Text(l10n.homeViewStats),
          ),
        ),
      ],
    );
  }
}

class _ExerciseUnlockSummary {
  const _ExerciseUnlockSummary({
    required this.unlockedSkills,
    required this.totalSkills,
  });

  final int unlockedSkills;
  final int totalSkills;
}
