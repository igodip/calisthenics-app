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
    this.loadGuides,
  });

  final String? initialGuideSlug;
  final String? initialGuideId;
  final Future<List<ExerciseGuide>> Function(String locale)? loadGuides;

  @override
  State<ExerciseGuidesPage> createState() => _ExerciseGuidesPageState();
}

class _ExerciseGuidesPageState extends State<ExerciseGuidesPage>
    with WidgetsBindingObserver {
  Future<void>? _refreshInFlight;
  Difficulty _selectedDifficulty = Difficulty.beginner;
  Future<List<ExerciseGuide>>? _guidesFuture;
  String? _localeName;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _guideKeys = {};
  String? _highlightedGuideId;
  bool _initialGuideHandled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted && _localeName != null) {
      _reload(forceRefresh: false);
    }
  }

  Future<void> _reload({bool forceRefresh = true}) {
    if (_refreshInFlight != null) return _refreshInFlight!;
    final future = _loadGuides(_localeName!, forceRefresh: forceRefresh);
    setState(() {
      _guidesFuture = future;
      if (forceRefresh) _initialGuideHandled = false;
    });
    final handled = future.then<void>(
      (_) {},
      onError: (Object _, StackTrace stack) {},
    );
    late final Future<void> operation;
    operation = handled.whenComplete(() {
      if (identical(_refreshInFlight, operation)) _refreshInFlight = null;
    });
    _refreshInFlight = operation;
    return operation;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    if (_guidesFuture == null || _localeName != l10n.localeName) {
      _localeName = l10n.localeName;
      _refreshInFlight = null;
      _guidesFuture = _loadGuides(l10n.localeName);
    }
  }

  @override
  void didUpdateWidget(covariant ExerciseGuidesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.loadGuides != widget.loadGuides) {
      _refreshInFlight = null;
      _guidesFuture = _loadGuides(_localeName!);
    }
    if (oldWidget.loadGuides != widget.loadGuides ||
        oldWidget.initialGuideSlug != widget.initialGuideSlug ||
        oldWidget.initialGuideId != widget.initialGuideId) {
      _initialGuideHandled = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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

  Future<List<ExerciseGuide>> _loadGuides(
    String localeName, {
    bool forceRefresh = false,
  }) {
    return widget.loadGuides?.call(localeName) ??
        ExerciseGuides.load(localeName, forceRefresh: forceRefresh);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return RefreshIndicator(
      onRefresh: _reload,
      child: FutureBuilder<List<ExerciseGuide>>(
        future: _guidesFuture,
        builder: (context, snapshot) {
          final guides = snapshot.data ?? const <ExerciseGuide>[];
          final filteredGuides = guides
              .where((guide) => guide.difficulty == _selectedDifficulty)
              .toList();
          if (!_initialGuideHandled &&
              !snapshot.hasError &&
              snapshot.connectionState == ConnectionState.done) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _handleInitialGuide(guides);
            });
          }

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              _PageHeader(
                title: l10n.guidesTitle,
                description: l10n.guidesSubtitle,
                onRefresh: _reload,
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
                  child: Column(
                    children: [
                      Text(
                        l10n.guidesLoadError,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _reload,
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              else
                for (final guide in filteredGuides)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      key: _guideKeys.putIfAbsent(guide.id, () => GlobalKey()),
                      child: ExerciseGuideCard(
                        guide: guide,
                        l10n: l10n,
                        isHighlighted: guide.id == _highlightedGuideId,
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.description,
    required this.onRefresh,
  });

  final String title;
  final String description;
  final VoidCallback onRefresh;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              IconButton(
                tooltip: AppLocalizations.of(context)!.refresh,
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
              ),
            ],
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

    return Material(
      type: MaterialType.transparency,
      child: Wrap(
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
      ),
    );
  }
}
