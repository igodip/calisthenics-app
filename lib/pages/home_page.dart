// lib/pages/home_page.dart
import 'dart:async';
import 'package:calisync/admin/admin_repository.dart';
import 'package:calisync/admin/pages/admin_console_page.dart';
import 'package:calisync/admin/pages/admin_bug_reports.dart';
import 'package:calisync/pages/profile_page.dart';
import 'package:calisync/notifications/push_notification_service.dart';
import 'package:calisync/pages/terminology_page.dart';
import 'package:calisync/pages/trainee_feedback_page.dart';
import 'package:calisync/trainer/pages/trainer_section_page.dart';
import 'package:calisync/trainer/trainer_models.dart';
import 'package:calisync/trainer/trainer_repository.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/plan_expired_gate.dart';
import '../components/first_login_pushup.dart';
import '../data/account_access.dart';
import '../data/trainee_final_week.dart';
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
  adminBugReports,
}

bool requiresTrainingAccess(HomeSection section) => switch (section) {
  HomeSection.home ||
  HomeSection.workoutPlan ||
  HomeSection.maxTests ||
  HomeSection.timer => true,
  _ => false,
};

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

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late HomeSection selectedSection;
  String? _cachedLocale;
  TrainerProfile? _trainerProfile;
  bool _isAdmin = false;
  int _trainerUnreadFeedbackCount = 0;
  bool _roleLookupComplete = false;
  bool _rolesLoading = false;
  Object? _roleError;
  Timer? _rolesTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    selectedSection = widget.initialSection;
    PushNotificationService.instance.addListener(_handleNotificationRoute);
    _loadTrainerRole();
    _rolesTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadTrainerRole(),
    );
  }

  @override
  void dispose() {
    _rolesTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    PushNotificationService.instance.removeListener(_handleNotificationRoute);
    super.dispose();
  }

  Future<void> _loadTrainerRole() async {
    if (_rolesLoading || !mounted) return;
    _rolesLoading = true;
    try {
      final access = await AccountAccess.load();
      if (mounted) {
        setState(() {
          _trainerProfile = access.isTrainer && access.isActive
              ? TrainerProfile(id: accessUserId(), name: access.name)
              : null;
          _isAdmin = access.isAdmin && access.isActive;
          _roleError = null;
          _roleLookupComplete = true;
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
    } catch (error) {
      if (mounted) setState(() => _roleError = error);
    } finally {
      _rolesLoading = false;
      _handleNotificationRoute();
    }
  }

  String accessUserId() => AdminRepository().currentUserId!;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _loadTrainerRole();
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
      // Warm the caches without allowing offline prefetch failures to escape
      // as unhandled asynchronous errors. The catalog pages provide retry UI.
      unawaited(
        guide_data.ExerciseGuides.load(
          localeName,
        ).then<void>((_) {}, onError: (Object _, StackTrace stack) {}),
      );
      unawaited(
        TerminologyRepository.load(
          localeName,
        ).then<void>((_) {}, onError: (Object _, StackTrace stack) {}),
      );
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
      navigationItems.add(
        _NavigationItem(
          section: HomeSection.adminBugReports,
          title: l10n.adminBugReportsTitle,
          icon: Icons.bug_report,
          page: const AdminBugReportsPage(),
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
      bottomNavigationBar: _roleError == null
          ? currentItem.section == HomeSection.home
                ? FirstLoginPushup(
                    key: ValueKey(
                      Supabase.instance.client.auth.currentUser?.id,
                    ),
                    userId: Supabase.instance.client.auth.currentUser?.id ?? '',
                    loadAura: () => loadTraineeFinalWeek(
                      Supabase.instance.client,
                      Supabase.instance.client.auth.currentUser?.id ?? '',
                    ),
                  )
                : null
          : Material(
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(l10n.trainingAccessErrorTitle)),
                      TextButton(
                        onPressed: _loadTrainerRole,
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        title: Text(
          currentTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: colorScheme.onSurface,
        actions: [
          if (selectedSection != HomeSection.profile) ...[
            IconButton(
              tooltip: l10n.navProfile,
              onPressed: () => _selectSection(HomeSection.profile),
              icon: const Icon(Icons.account_circle_outlined),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.fitness_center_rounded,
                        color: colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(l10n.appTitle, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text(
                      currentTitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                  child: ListTile(
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
              theme.scaffoldBackgroundColor,
              colorScheme.primaryContainer.withValues(alpha: 0.18),
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
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: requiresTrainingAccess(currentItem.section)
                      ? PlanExpiredGate(
                          onOpenProfile: () =>
                              _selectSection(HomeSection.profile),
                          child: currentItem.page,
                        )
                      : currentItem.page,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return scaffold;
  }
}
