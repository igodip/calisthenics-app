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
    final List<Widget> pages = [
      HomeContent(),
      const Center(child: Text('Impostazioni')),
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Impostazioni'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profilo'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Terminologia'),
        ],
      ),
    );
  }
}

