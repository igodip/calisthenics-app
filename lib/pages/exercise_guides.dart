import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';

class ExerciseGuidesPage extends StatelessWidget {
  const ExerciseGuidesPage({super.key});

  static const _guides = [
    _ExerciseGuide(
      name: 'Pull-up',
      difficulty: 'Intermediate',
      focus: 'Lats, biceps, grip',
      tip:
          'Drive elbows toward your ribs and keep your ribs tucked to avoid swinging.',
      description:
          'Start from a hollow body hang, then pull until your chin clears the bar. Control the descent for stronger reps.',
      videoUrl: 'https://youtu.be/eGo4IYlbE5g',
      accent: Colors.blue,
    ),
    _ExerciseGuide(
      name: 'Push-up',
      difficulty: 'Beginner',
      focus: 'Chest, triceps, core',
      tip: 'Squeeze your glutes and keep a straight line from head to heels.',
      description:
          'Lower with elbows at roughly 45° to your torso, touch your chest lightly, then press back up without letting hips sag.',
      videoUrl: 'https://youtu.be/IODxDxX7oi4',
      accent: Colors.orange,
    ),
    _ExerciseGuide(
      name: 'Bodyweight squat',
      difficulty: 'Beginner',
      focus: 'Quads, glutes, core',
      tip: 'Push your knees out as you descend and keep your heels planted.',
      description:
          'Sit the hips back and down until thighs are at least parallel. Drive evenly through the whole foot to stand tall.',
      videoUrl: 'https://youtu.be/aclHkVaku9U',
      accent: Colors.green,
    ),
    _ExerciseGuide(
      name: 'Hanging leg raise',
      difficulty: 'Intermediate',
      focus: 'Abdominals, hip flexors, grip',
      tip: 'Initiate each rep by engaging your lats to steady the torso.',
      description:
          'From a dead hang, lift your legs together until they reach hip height or higher. Lower slowly to keep tension.',
      videoUrl: 'https://youtu.be/0yRQw1wqHik',
      accent: Colors.purple,
    ),
    _ExerciseGuide(
      name: 'Muscle-up',
      difficulty: 'Advanced',
      focus: 'Lats, chest, triceps, transition strength',
      tip:
          'Pull high to your upper chest and keep the bar close to reduce the swing.',
      description:
          'From a controlled hang, explode into a high pull, transition the wrists over the bar, and press to lockout.',
      videoUrl: 'https://youtu.be/4NnU1YuZzUE',
      accent: Colors.teal,
    ),
    _ExerciseGuide(
      name: 'Straight bar dip',
      difficulty: 'Intermediate',
      focus: 'Chest, triceps, shoulders',
      tip: 'Keep elbows tucked and press down while leaning slightly forward.',
      description:
          'Start on top of the bar with locked elbows, lower under control until shoulders dip below elbows, then drive back up.',
      videoUrl: 'https://youtu.be/2z8JmcrW-As',
      accent: Colors.deepOrange,
    ),
    _ExerciseGuide(
      name: 'Dips',
      difficulty: 'Intermediate',
      focus: 'Chest, triceps, shoulders',
      tip: 'Lean slightly forward and keep shoulders packed to protect the joints.',
      description:
          'Start locked out on parallel bars, lower until shoulders dip below elbows, then press back to a strong lockout.',
      videoUrl: 'https://youtu.be/2z8JmcrW-As',
      accent: Colors.red,
    ),
    _ExerciseGuide(
      name: 'Australian row',
      difficulty: 'Beginner',
      focus: 'Upper back, biceps, core',
      tip: 'Brace your core and keep a straight line from shoulders to heels.',
      description:
          'Set the bar at waist height, hang underneath, and row your chest to the bar with elbows tight.',
      videoUrl: 'https://youtu.be/9efgcAjQe7E',
      accent: Colors.indigo,
    ),
    _ExerciseGuide(
      name: 'Pike push-up',
      difficulty: 'Intermediate',
      focus: 'Shoulders, triceps, core',
      tip:
          'Keep hips high and lower your head to a spot just in front of your hands.',
      description:
          'From a pike position, bend elbows to bring the head down, then press back to a strong lockout.',
      videoUrl: 'https://youtu.be/0wDEO1i2bFM',
      accent: Colors.amber,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _PageHeader(
          title: l10n.guidesTitle,
          description: l10n.guidesSubtitle,
        ),
        const SizedBox(height: 12),
        for (final guide in _guides)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _ExerciseGuideCard(guide: guide, l10n: l10n),
          ),
      ],
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
  const _ExerciseGuideCard({required this.guide, required this.l10n});

  final _ExerciseGuide guide;
  final AppLocalizations l10n;

  Future<void> _openVideo(BuildContext context) async {
    final uri = Uri.parse(guide.videoUrl);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.guidesVideoUnavailable)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
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
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: guide.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    guide.difficulty,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: guide.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              guide.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.center_focus_strong, color: guide.accent),
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
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => _openVideo(context),
              child: _VideoPreview(
                guide: guide,
                label: l10n.guidesWatchVideo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoPreview extends StatelessWidget {
  const _VideoPreview({required this.guide, required this.label});

  final _ExerciseGuide guide;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    guide.accent.withValues(alpha: 0.2),
                    colorScheme.onSurface.withValues(alpha: 0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(14),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseGuide {
  const _ExerciseGuide({
    required this.name,
    required this.difficulty,
    required this.focus,
    required this.tip,
    required this.description,
    required this.videoUrl,
    required this.accent,
  });

  final String name;
  final String difficulty;
  final String focus;
  final String tip;
  final String description;
  final String videoUrl;
  final Color accent;
}
