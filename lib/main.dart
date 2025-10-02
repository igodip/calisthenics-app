// lib/main.dart
import 'package:calisync/terminologia.dart';
import 'package:flutter/material.dart';
import 'package:calisync/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'home_content.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://jrqjysycoqhlnyufhliy.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpycWp5c3ljb3FobG55dWZobGl5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI0MzM0NTIsImV4cCI6MjA2ODAwOTQ1Mn0.3BVA-Ar9YtLGGO12Gt6NQkMl2cn18E_b48PGtlFxxCw',
  );

  runApp(const CalisthenicsApp());
}

class CalisthenicsApp extends StatelessWidget {
  const CalisthenicsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calisthenics',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        primaryColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePage(title: 'Calisthenics');
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

  Future<bool?> getPayedStatus() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final response = await supabase
        .from('users')
        .select('payed')
        .eq('uuid', user.id)
        .maybeSingle();

    if (response == null) return null;

    return response['payed'] == true;
  }

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

