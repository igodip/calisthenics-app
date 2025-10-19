// lib/main.dart
import 'package:calisync/pages/terminologia.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

        final l10n = AppLocalizations.of(context)!;

        if (session != null) {
          return HomePage(title: l10n.appTitle);
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
                l10n.authErrorMessage,
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
    final l10n = AppLocalizations.of(context)!;
    final List<Widget> pages = [
      const HomeContent(),
      Center(child: Text(l10n.settingsPlaceholderMessage)),
      const ProfilePage(),
      const TerminologiaPage()
    ];

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: pages[selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: l10n.homeTabLabel),
          BottomNavigationBarItem(icon: const Icon(Icons.settings), label: l10n.settingsTabLabel),
          BottomNavigationBarItem(icon: const Icon(Icons.account_circle), label: l10n.profileTabLabel),
          BottomNavigationBarItem(icon: const Icon(Icons.book), label: l10n.terminologyTabLabel),
        ],
      ),
    );
  }
}

