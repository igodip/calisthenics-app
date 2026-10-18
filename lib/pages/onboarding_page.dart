import 'package:calisync/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/auth_gate.dart';
import '../components/auth_visuals.dart';

class OnboardingGate extends StatefulWidget {
  const OnboardingGate({super.key});

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  static const _onboardingPrefKey = 'hasSeenOnboarding';

  late Future<bool> _hasSeenOnboarding;
  bool _startInSignupMode = false;

  @override
  void initState() {
    super.initState();
    _hasSeenOnboarding = _loadHasSeenOnboarding();
  }

  Future<bool> _loadHasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingPrefKey) ?? false;
  }

  Future<void> _completeOnboarding({bool signup = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingPrefKey, true);
    if (!mounted) return;
    setState(() {
      _startInSignupMode = signup;
      _hasSeenOnboarding = Future.value(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasSeenOnboarding,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !(snapshot.data ?? false)) {
          return OnboardingPage(
            onFinish: _completeOnboarding,
            onCreateAccount: () => _completeOnboarding(signup: true),
          );
        }

        return AuthGate(startInSignupMode: _startInSignupMode);
      },
    );
  }
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    super.key,
    required this.onFinish,
    this.onCreateAccount,
  });

  final VoidCallback onFinish;
  final VoidCallback? onCreateAccount;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: AuthVisuals.theme(context),
    child: Builder(builder: _buildContent),
  );

  Widget _buildContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final titles = [
      l10n.onboardingTitleOne,
      l10n.onboardingTitleTwo,
      l10n.onboardingTitleThree,
    ];
    final descriptions = [
      l10n.onboardingDescriptionOne,
      l10n.onboardingDescriptionTwo,
      l10n.onboardingDescriptionThree,
    ];
    const assets = ['pull_up', 'handstand', 'dip'];
    final last = _currentIndex == 2;
    final compact =
        MediaQuery.sizeOf(context).width < 360 ||
        MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final brand = AuthBrand(title: l10n.appTitle);
    final skip = TextButton(
      onPressed: widget.onFinish,
      child: Text(l10n.onboardingSkip),
    );
    final back = TextButton(
      onPressed: () => _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      ),
      child: Text(l10n.onboardingBack),
    );
    final signIn = TextButton(
      onPressed: widget.onFinish,
      child: Text(
        compact ? l10n.loginButton : l10n.existingAccountPrompt,
        textAlign: TextAlign.center,
      ),
    );
    final titleStyle = theme.textTheme.headlineMedium!.copyWith(
      fontWeight: FontWeight.w800,
      height: 1.12,
    );
    final descriptionStyle = theme.textTheme.bodyLarge!.copyWith(
      color: AuthVisuals.muted,
      height: 1.4,
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 12, 0),
                  child: compact
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            brand,
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: skip,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(child: brand),
                            skip,
                          ],
                        ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Measure all translations together so every page shares
                      // the same text baselines, including large system fonts.
                      double maxHeight(List<String> strings, TextStyle style) {
                        var result = 0.0;
                        for (final text in strings) {
                          final painter = TextPainter(
                            text: TextSpan(text: text, style: style),
                            textDirection: Directionality.of(context),
                            textScaler: MediaQuery.textScalerOf(context),
                          )..layout(maxWidth: constraints.maxWidth - 48);
                          if (painter.height > result) result = painter.height;
                          painter.dispose();
                        }
                        return result;
                      }

                      final titleHeight = maxHeight(titles, titleStyle);
                      final descriptionHeight = maxHeight(
                        descriptions,
                        descriptionStyle,
                      );
                      final heroHeight =
                          (constraints.maxHeight -
                                  titleHeight -
                                  descriptionHeight -
                                  40)
                              .clamp(140.0, 520.0)
                              .toDouble();
                      return PageView.builder(
                        controller: _pageController,
                        itemCount: 3,
                        onPageChanged: (index) =>
                            setState(() => _currentIndex = index),
                        itemBuilder: (context, index) => SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AuthArtwork(
                                asset: 'assets/auth/${assets[index]}.webp',
                                height: heroHeight,
                                subdued: true,
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  8,
                                  24,
                                  16,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    SizedBox(
                                      height: titleHeight,
                                      child: Text(
                                        titles[index],
                                        style: titleStyle,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      height: descriptionHeight,
                                      child: Text(
                                        descriptions[index],
                                        style: descriptionStyle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var index = 0; index < 3; index++)
                            Semantics(
                              label: titles[index],
                              selected: index == _currentIndex,
                              child: Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: index == _currentIndex
                                      ? AuthVisuals.mint
                                      : const Color(0xFF52626A),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: () {
                          if (last) {
                            (widget.onCreateAccount ?? widget.onFinish)();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                            );
                          }
                        },
                        child: Text(
                          last ? l10n.signupButton : l10n.onboardingNext,
                        ),
                      ),
                      if (compact)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_currentIndex > 0)
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: back,
                              ),
                            signIn,
                          ],
                        )
                      else
                        Row(
                          children: [
                            if (_currentIndex > 0) back,
                            Expanded(child: signIn),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
