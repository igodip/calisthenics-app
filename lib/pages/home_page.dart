// lib/pages/home_page.dart
import 'package:calisync/pages/profile_page.dart';
import 'package:calisync/notifications/push_notification_service.dart';
import 'package:calisync/pages/terminology_page.dart';
import 'package:calisync/pages/trainee_feedback_page.dart';
import 'package:calisync/trainer/pages/trainer_section_page.dart';
import 'package:calisync/trainer/trainer_models.dart';
import 'package:calisync/trainer/trainer_repository.dart';
import 'package:flutter/material.dart';

import '../components/plan_expired_gate.dart';
import '../data/exercise_guides.dart' as guide_data;
import '../data/terminology_repository.dart';
import '../l10n/app_localizations.dart';
import 'exercise_guides_page.dart';
import 'home_content.dart';
import 'max_tests_menu_page.dart';
import 'timer_page.dart';
import 'workout_plan_page.dart';

class _NavigationItem {
  const _NavigationItem({
    required this.title,
    required this.icon,
    required this.page,
  });

  final String title;
  final IconData icon;
  final Widget page;
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.title,
    this.initialIndex = 0,
    this.initialTerminologyTermKey,
    this.initialGuideSlug,
    this.initialGuideId,
  });
  final String title;
  final int initialIndex;
  final String? initialTerminologyTermKey;
  final String? initialGuideSlug;
  final String? initialGuideId;

  static const int terminologyIndex = 6;
  static const int guidesIndex = 2;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int selectedIndex;
  String? _cachedLocale;
  TrainerProfile? _trainerProfile;
  bool _roleLookupComplete = false;

  static const int _workoutPlanIndex = 1;
  static const int _maxTestsIndex = 4;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
    PushNotificationService.instance.addListener(_handleNotificationRoute);
    _loadTrainerRole();
  }

  @override
  void dispose() {
    PushNotificationService.instance.removeListener(_handleNotificationRoute);
    super.dispose();
  }

  Future<void> _loadTrainerRole() async {
    try {
      final trainer = await TrainerRepository().currentTrainer();
      if (mounted) setState(() => _trainerProfile = trainer);
    } catch (_) {
      // The standard trainee experience remains available if role lookup fails.
    } finally {
      _roleLookupComplete = true;
      _handleNotificationRoute();
    }
  }

  void _handleNotificationRoute() {
    if (!mounted || !_roleLookupComplete) return;
    final route = PushNotificationService.instance.takePendingRoute();
    if (route == null) return;
    final index = switch (route) {
      'trainee_plan' => _workoutPlanIndex,
      'trainee_feedback' => 5,
      'trainer_feedback' when _trainerProfile != null => 10,
      _ => 0,
    };
    setState(() => selectedIndex = index);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localeName = AppLocalizations.of(context)!.localeName;
    if (_cachedLocale != localeName) {
      _cachedLocale = localeName;
      guide_data.ExerciseGuides.load(localeName);
      TerminologyRepository.load(localeName);
    }
  }

  void _selectIndex(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final navigationItems = [
      _NavigationItem(
        title: l10n.navHome,
        icon: Icons.home,
        page: HomeContent(
          onOpenPlan: () => _selectIndex(_workoutPlanIndex),
          onViewStats: () => _selectIndex(_maxTestsIndex),
        ),
      ),
      _NavigationItem(
        title: l10n.workoutPlanTitle,
        icon: Icons.event_note,
        page: const WorkoutPlanPage(),
      ),
      _NavigationItem(
        title: l10n.navGuides,
        icon: Icons.fitness_center,
        page: ExerciseGuidesPage(
          initialGuideSlug: widget.initialGuideSlug,
          initialGuideId: widget.initialGuideId,
        ),
      ),
      _NavigationItem(
        title: l10n.navProfile,
        icon: Icons.person,
        page: const ProfilePage(),
      ),
      _NavigationItem(
        title: l10n.profileMaxTestsTitle,
        icon: Icons.emoji_events_outlined,
        page: const MaxTestsMenuPage(),
      ),
      _NavigationItem(
        title: l10n.traineeFeedbackTitle,
        icon: Icons.feedback,
        page: const TraineeFeedbackPage(),
      ),
      _NavigationItem(
        title: l10n.navTerminology,
        icon: Icons.menu_book,
        page: TerminologyPage(termKey: widget.initialTerminologyTermKey),
      ),
      _NavigationItem(
        title: l10n.timerTitle,
        icon: Icons.timer,
        page: const TimerPage(),
      ),
    ];

    if (_trainerProfile != null) {
      navigationItems.addAll([
        _NavigationItem(
          title: l10n.trainerNavDashboard,
          icon: Icons.dashboard_customize,
          page: const TrainerSectionPage(section: TrainerSection.dashboard),
        ),
        _NavigationItem(
          title: l10n.trainerNavTrainees,
          icon: Icons.groups,
          page: const TrainerSectionPage(section: TrainerSection.trainees),
        ),
        _NavigationItem(
          title: l10n.trainerNavFeedback,
          icon: Icons.mark_chat_unread,
          page: const TrainerSectionPage(section: TrainerSection.feedback),
        ),
        _NavigationItem(
          title: l10n.trainerNavPayments,
          icon: Icons.payments,
          page: const TrainerSectionPage(section: TrainerSection.payments),
        ),
      ]);
    }

    final currentTitle = navigationItems[selectedIndex].title;

    final scaffold = Scaffold(
      extendBody: true,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        title: Text(
          currentTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    currentTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              for (final entry in navigationItems.indexed) ...[
                if (entry.$1 == 8) ...[
                  const Divider(height: 24),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      l10n.trainerMenuGroup,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
                ListTile(
                  leading: Icon(entry.$2.icon),
                  title: Text(entry.$2.title),
                  selected: selectedIndex == entry.$1,
                  onTap: () {
                    setState(() {
                      selectedIndex = entry.$1;
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.12),
              colorScheme.secondaryContainer.withValues(alpha: 0.08),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0.02),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Container(
              key: ValueKey<int>(selectedIndex),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.cardColor.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withValues(alpha: 0.06),
                      offset: const Offset(0, 12),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: navigationItems[selectedIndex].page,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return PlanExpiredGate(useOverlay: true, child: scaffold);
  }
}
