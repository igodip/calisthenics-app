import 'package:flutter/material.dart';
import '../components/exercise_guide_card.dart';
import '../data/exercise_guides.dart';
import '../l10n/app_localizations.dart';
import '../model/exercise_guide.dart';

class ExerciseGuidesPage extends StatefulWidget {
  const ExerciseGuidesPage({
    super.key,
    this.initialGuideSlug,
    this.initialGuideId,
  });

  final String? initialGuideSlug;
  final String? initialGuideId;

  @override
  State<ExerciseGuidesPage> createState() => _ExerciseGuidesPageState();
}

class _ExerciseGuidesPageState extends State<ExerciseGuidesPage> {
  Difficulty _selectedDifficulty = Difficulty.beginner;
  final Set<String> _unlockedSkills = {};
  Future<List<ExerciseGuide>>? _guidesFuture;
  String? _localeName;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _guideKeys = {};
  String? _highlightedGuideId;
  bool _initialGuideHandled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    if (_guidesFuture == null || _localeName != l10n.localeName) {
      _localeName = l10n.localeName;
      _guidesFuture = ExerciseGuides.load(l10n);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String? _initialGuideTarget() {
    final slug = widget.initialGuideSlug?.trim();
    if (slug != null && slug.isNotEmpty) {
      return slug;
    }
    final id = widget.initialGuideId?.trim();
    if (id != null && id.isNotEmpty) {
      return id;
    }
    return null;
  }

  void _handleInitialGuide(List<ExerciseGuide> guides) {
    if (_initialGuideHandled) return;
    _initialGuideHandled = true;
    final target = _initialGuideTarget();
    if (target == null) return;
    ExerciseGuide? matched;
    for (final guide in guides) {
      if (guide.id == target) {
        matched = guide;
        break;
      }
    }
    if (matched == null) return;
    final matchedGuide = matched;
    if (_selectedDifficulty != matchedGuide.difficulty ||
        _highlightedGuideId != matchedGuide.id) {
      setState(() {
        _selectedDifficulty = matchedGuide.difficulty;
        _highlightedGuideId = matchedGuide.id;
      });
    } else {
      _highlightedGuideId = matchedGuide.id;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToGuide(matchedGuide.id);
    });
  }

  void _scrollToGuide(String guideId) {
    final key = _guideKeys[guideId];
    final context = key?.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      alignment: 0.12,
    );
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
        if (!_initialGuideHandled &&
            snapshot.connectionState == ConnectionState.done) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleInitialGuide(guides);
          });
        }

        return ListView(
          controller: _scrollController,
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
                  l10n.guidesLoadError,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              for (final guide in filteredGuides)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    key: _guideKeys.putIfAbsent(
                      guide.id,
                      () => GlobalKey(),
                    ),
                    child: ExerciseGuideCard(
                      guide: guide,
                      l10n: l10n,
                      isHighlighted: guide.id == _highlightedGuideId,
                      onUnlock: guide.isUnlocked
                          ? null
                          : () {
                              setState(() {
                                _unlockedSkills.add(guide.id);
                              });
                            },
                    ),
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
