// lib/main.dart
import 'package:calisync/pages/terminologia.dart';
import 'package:flutter/material.dart';
import 'package:calisync/pages/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'home_content.dart';
import 'login.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.hasData
            ? snapshot.data!.session
            : Supabase.instance.client.auth.currentSession;

        if (session != null) {
          return const HomePage(title: 'Calisthenics');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Errore durante l\'autenticazione',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return const LoginPage();
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  bool? payed;
  
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final navigationItems = [
      _NavigationItem(
        icon: Icons.home,
        label: 'Home',
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.secondary],
        ),
      ),
      _NavigationItem(
        icon: Icons.settings,
        label: 'Impostazioni',
        gradient: LinearGradient(
          colors: [colorScheme.secondary, colorScheme.tertiary],
        ),
      ),
      _NavigationItem(
        icon: Icons.account_circle,
        label: 'Profilo',
        gradient: LinearGradient(
          colors: [colorScheme.tertiary, colorScheme.primary],
        ),
      ),
      _NavigationItem(
        icon: Icons.book,
        label: 'Terminologia',
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.error],
        ),
      ),
    ];

    final List<Widget> pages = [
      HomeContent(),
      const Center(child: Text('Impostazioni')),
      const ProfilePage(),
      const TerminologiaPage()
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          widget.title,
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primaryContainer.withOpacity(0.12),
              colorScheme.secondaryContainer.withOpacity(0.08),
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
                  color: theme.cardColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.06),
                      offset: const Offset(0, 12),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: pages[selectedIndex],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.08),
                offset: const Offset(0, 10),
                blurRadius: 32,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BottomNavigationBar(
              backgroundColor: colorScheme.surface.withOpacity(0),
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              currentIndex: selectedIndex,
              selectedItemColor: colorScheme.primary,
              unselectedItemColor: colorScheme.onSurfaceVariant,
              showUnselectedLabels: true,
              onTap: (int index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              items: [
                for (final item in navigationItems)
                  BottomNavigationBarItem(
                    icon: _GradientIcon(
                      icon: item.icon,
                      gradient: item.gradient,
                      isActive: navigationItems.indexOf(item) == selectedIndex,
                      inactiveColor: colorScheme.onSurfaceVariant,
                    ),
                    label: item.label,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.gradient,
  });

  final IconData icon;
  final String label;
  final Gradient gradient;
}

class _GradientIcon extends StatelessWidget {
  const _GradientIcon({
    required this.icon,
    required this.gradient,
    required this.isActive,
    required this.inactiveColor,
  });

  final IconData icon;
  final Gradient gradient;
  final bool isActive;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    if (!isActive) {
      return Icon(icon, color: inactiveColor);
    }

    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Icon(icon, color: Theme.of(context).colorScheme.onPrimary),
    );
  }
}

