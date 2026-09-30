// lib/pages/home_page.dart
import 'package:calisync/admin/admin_repository.dart';
import 'package:calisync/admin/pages/admin_console_page.dart';
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

enum HomeSection {
  home,
  workoutPlan,
  maxTests,
  traineeFeedback,
  timer,
  guides,
  terminology,
  profile,
  trainerDashboard,
  trainerTrainees,
  trainerFeedback,
  trainerPayments,
  adminConsole,
}

HomeSection homeSectionForNotificationRoute(
  String route, {
  required bool isTrainer,
}) {
  return switch (route) {
    'trainee_plan' => HomeSection.workoutPlan,
    'trainee_feedback' => HomeSection.traineeFeedback,
    'trainer_feedback' when isTrainer => HomeSection.trainerFeedback,
    _ => HomeSection.home,
  };
}

class _NavigationItem {
  const _NavigationItem({
    required this.section,
    required this.title,
    required this.icon,
    required this.page,
    this.groupTitle,
    this.badgeCount = 0,
  });

  final HomeSection section;
  final String title;
  final IconData icon;
  final Widget page;
  final String? groupTitle;
  final int badgeCount;
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.title,
    this.initialSection = HomeSection.home,
    this.initialTerminologyTermKey,
    this.initialGuideSlug,
    this.initialGuideId,
  });
  final String title;
  final HomeSection initialSection;
  final String? initialTerminologyTermKey;
  final String? initialGuideSlug;
  final String? initialGuideId;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeSection selectedSection;
  String? _cachedLocale;
  TrainerProfile? _trainerProfile;
  bool _isAdmin = false;
  int _trainerUnreadFeedbackCount = 0;
  bool _roleLookupComplete = false;

  @override
  void initState() {
    super.initState();
    selectedSection = widget.initialSection;
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
      final roles = await Future.wait<Object?>([
        TrainerRepository().currentTrainer().catchError((_) => null),
        AdminRepository().isCurrentUserAdmin().catchError((_) => false),
      ]);
      if (mounted) {
        setState(() {
          _trainerProfile = roles[0] as TrainerProfile?;
          _isAdmin = roles[1] as bool;
        });
      }
      if (_trainerProfile != null) {
        try {
          final count = await TrainerRepository().unreadFeedbackCount();
          if (mounted) setState(() => _trainerUnreadFeedbackCount = count);
        } catch (_) {
          // A badge failure must not hide the trainer workspace.
        }
      }
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
    final section = homeSectionForNotificationRoute(
      route,
      isTrainer: _trainerProfile != null,
    );
    setState(() => selectedSection = section);
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

  void _selectSection(HomeSection section) {
    setState(() {
      selectedSection = section;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final navigationItems = [
      _NavigationItem(
        section: HomeSection.home,
        title: l10n.navHome,
        icon: Icons.home,
        page: HomeContent(
          onOpenPlan: () => _selectSection(HomeSection.workoutPlan),
          onViewStats: () => _selectSection(HomeSection.maxTests),
        ),
      ),
      _NavigationItem(
        section: HomeSection.workoutPlan,
        title: l10n.workoutPlanTitle,
        icon: Icons.event_note,
        page: const WorkoutPlanPage(),
      ),
      _NavigationItem(
        section: HomeSection.maxTests,
        title: l10n.profileMaxTestsTitle,
        icon: Icons.emoji_events_outlined,
        page: const MaxTestsMenuPage(),
      ),
      _NavigationItem(
        section: HomeSection.traineeFeedback,
        title: l10n.traineeFeedbackTitle,
        icon: Icons.feedback,
        page: const TraineeFeedbackPage(),
      ),
      _NavigationItem(
        section: HomeSection.timer,
        title: l10n.timerTitle,
        icon: Icons.timer,
        page: const TimerPage(),
      ),
      _NavigationItem(
        section: HomeSection.guides,
        title: l10n.navGuides,
        icon: Icons.fitness_center,
        page: ExerciseGuidesPage(
          initialGuideSlug: widget.initialGuideSlug,
          initialGuideId: widget.initialGuideId,
        ),
      ),
      _NavigationItem(
        section: HomeSection.terminology,
        title: l10n.navTerminology,
        icon: Icons.menu_book,
        page: TerminologyPage(termKey: widget.initialTerminologyTermKey),
      ),
      _NavigationItem(
        section: HomeSection.profile,
        title: l10n.navProfile,
        icon: Icons.person,
        page: const ProfilePage(),
      ),
    ];

    if (_trainerProfile != null) {
      navigationItems.addAll([
        _NavigationItem(
          section: HomeSection.trainerDashboard,
          title: l10n.trainerNavDashboard,
          icon: Icons.dashboard_customize,
          page: const TrainerSectionPage(section: TrainerSection.dashboard),
          groupTitle: l10n.trainerMenuGroup,
        ),
        _NavigationItem(
          section: HomeSection.trainerTrainees,
          title: l10n.trainerNavTrainees,
          icon: Icons.groups,
          page: const TrainerSectionPage(section: TrainerSection.trainees),
        ),
        _NavigationItem(
          section: HomeSection.trainerFeedback,
          title: l10n.trainerNavFeedback,
          icon: Icons.mark_chat_unread,
          page: TrainerSectionPage(
            section: TrainerSection.feedback,
            onUnreadCountChanged: (count) {
              if (mounted && count != _trainerUnreadFeedbackCount) {
                setState(() => _trainerUnreadFeedbackCount = count);
              }
            },
          ),
          badgeCount: _trainerUnreadFeedbackCount,
        ),
        _NavigationItem(
          section: HomeSection.trainerPayments,
          title: l10n.trainerNavPayments,
          icon: Icons.payments,
          page: const TrainerSectionPage(section: TrainerSection.payments),
        ),
      ]);
    }

    if (_isAdmin) {
      navigationItems.add(
        _NavigationItem(
          section: HomeSection.adminConsole,
          title: l10n.adminNavConsole,
          icon: Icons.admin_panel_settings,
          page: const AdminConsolePage(),
          groupTitle: l10n.adminMenuGroup,
        ),
      );
    }

    final currentItem = navigationItems.firstWhere(
      (item) => item.section == selectedSection,
      orElse: () => navigationItems.first,
    );
    final currentTitle = currentItem.title;

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
              for (final item in navigationItems) ...[
                if (item.groupTitle != null) ...[
                  const Divider(height: 24),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      item.groupTitle!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
                ListTile(
                  leading: item.badgeCount > 0
                      ? Badge.count(
                          count: item.badgeCount,
                          child: Icon(item.icon),
                        )
                      : Icon(item.icon),
                  title: Text(item.title),
                  selected: currentItem.section == item.section,
                  onTap: () {
                    setState(() {
                      selectedSection = item.section;
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
              key: ValueKey<HomeSection>(currentItem.section),
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
                  child: currentItem.page,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return PlanExpiredGate(
      useOverlay: true,
      bypass: _trainerProfile != null || _isAdmin,
      child: scaffold,
    );
  }
}
