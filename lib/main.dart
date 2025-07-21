// lib/main.dart
import 'package:Calisthenics/login.dart';
import 'package:Calisthenics/training.dart';
import 'package:flutter/material.dart';
import 'package:Calisthenics/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'home_content.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://qxpcpenymczssmiyxwyr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF4cGNwZW55bWN6c3NtaXl4d3lyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIwOTUxNjcsImV4cCI6MjA2NzY3MTE2N30.UptZRydjQ6ZWU_gOALx5lgyfPoe5PFqNLxaaGX129As',          
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
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      return const HomePage(title: 'Calisthenics');
    } else {
      return const LoginPage();
    }
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
    fetchPayedStatus();
  }

  Future<void> fetchPayedStatus() async {
    final status = await getPayedStatus();
    setState(() {
      payed = status;
    });
  }

  @override
  Widget build(BuildContext context) {    
    final List<Widget> pages = [
      HomeContent(payed: payed ?? false),
      const Center(child: Text('Impostazioni')),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: payed == null ? const Center(child: CircularProgressIndicator()) : pages[selectedIndex],

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
        ],
      ),
    );
  }
}

