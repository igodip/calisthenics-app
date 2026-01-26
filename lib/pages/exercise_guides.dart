import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';
import '../model/exercise_guide.dart';

class ExerciseGuidesPage extends StatefulWidget {
  const ExerciseGuidesPage({super.key});

  @override
  State<ExerciseGuidesPage> createState() => _ExerciseGuidesPageState();
}

class _ExerciseGuidesPageState extends State<ExerciseGuidesPage> {
  Difficulty _selectedDifficulty = Difficulty.beginner;
  final Set<String> _unlockedSkills = {};
  Future<List<ExerciseGuide>>? _guidesFuture;
  String? _localeName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    if (_guidesFuture == null || _localeName != l10n.localeName) {
      _localeName = l10n.localeName;
      _guidesFuture = _loadGuides(l10n);
    }
  }

  Future<List<ExerciseGuide>> _loadGuides(AppLocalizations l10n) async {
    final response = await Supabase.instance.client
        .from('exercise_guides')
        .select('slug, difficulty, default_unlocked, accent')
        .order('sort_order', ascending: true);
    final rows = (response as List<dynamic>).cast<Map<String, dynamic>>();
    return rows
        .map((row) => ExerciseGuide.fromDatabase(row, l10n.localeName))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<List<ExerciseGuide>>(
      future: _guidesFuture,
      builder: (context, snapshot) {
        final guides = (snapshot.data ?? const <ExerciseGuide>[])
            .map(
              (guide) => guide.copyWith(
                isUnlocked:
                    guide.isUnlocked || _unlockedSkills.contains(guide.id),
              ),
            )
            .toList();
        final filteredGuides = guides
            .where((guide) => guide.difficulty == _selectedDifficulty)
            .toList();

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _PageHeader(
              title: l10n.guidesTitle,
              description: l10n.guidesSubtitle,
            ),
            const SizedBox(height: 16),
            _DifficultySelector(
              selected: _selectedDifficulty,
              l10n: l10n,
              onChanged: (difficulty) {
                setState(() {
                  _selectedDifficulty = difficulty;
                });
              },
            ),
            const SizedBox(height: 16),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (snapshot.hasError)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Unable to load skill guides right now.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              for (final guide in filteredGuides)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _ExerciseGuideCard(
                    guide: guide,
                    l10n: l10n,
                    onUnlock: guide.isUnlocked
                        ? null
                        : () {
                            setState(() {
                              _unlockedSkills.add(guide.id);
                            });
                          },
                  ),
                ),
          ],
        );
      },
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.75),
            colorScheme.secondaryContainer.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseGuideCard extends StatelessWidget {
  const _ExerciseGuideCard({
    required this.guide,
    required this.l10n,
    this.onUnlock,
  });

  final ExerciseGuide guide;
  final AppLocalizations l10n;
  final VoidCallback? onUnlock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isUnlocked = guide.isUnlocked;
    final accent = isUnlocked ? guide.accent : colorScheme.outline;
    final statusBackground = isUnlocked
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final statusForeground =
        isUnlocked ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant;

    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      color: isUnlocked
          ? colorScheme.surface
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    guide.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isUnlocked
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isUnlocked ? Icons.lock_open : Icons.lock,
                            size: 14,
                            color: statusForeground,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isUnlocked
                                ? l10n.skillsUnlockedLabel
                                : l10n.skillsLockedLabel,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: statusForeground,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        guide.difficulty.label(l10n),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              guide.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isUnlocked
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            if (isUnlocked) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.center_focus_strong, color: accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.guidesPrimaryFocus,
                          style: theme.textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          guide.focus,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.tips_and_updates, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.guidesCoachTip,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            guide.tip,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lock, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.skillsLockedHint,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: onUnlock,
                        icon: const Icon(Icons.lock_open),
                        label: Text(l10n.skillsUnlockAction),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DifficultySelector extends StatelessWidget {
  const _DifficultySelector({
    required this.selected,
    required this.l10n,
    required this.onChanged,
  });

  final Difficulty selected;
  final AppLocalizations l10n;
  final ValueChanged<Difficulty> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: Difficulty.values.map((difficulty) {
        return ChoiceChip(
          label: Text(difficulty.label(l10n)),
          selected: selected == difficulty,
          selectedColor: theme.colorScheme.primaryContainer,
          onSelected: (_) => onChanged(difficulty),
        );
      }).toList(),
    );
  }
}
