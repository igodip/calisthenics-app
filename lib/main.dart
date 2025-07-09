import 'package:Calisthenics/training.dart';
import 'package:flutter/material.dart';
import 'package:Calisthenics/profile.dart';

void main() {
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
      home: const HomePage(title: 'Calisthenics'),
      debugShowCheckedModeBanner: false,
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
  bool payed = false;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeContent(payed: payed),
      const Center(child: Text('Impostazioni')),
      const ProfilePage(),
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
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final bool payed;

  const HomeContent({super.key, required this.payed});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.payed) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Avviso'),
            content: const Text(
              'Non hai ancora effettuato il pagamento del mese.\nNon hai ancora effettuato il pagamento del mese.\nNon hai ancora effettuato il pagamento del mese.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SelectionCard(
            title: 'Giorno A',
            icon: Icons.numbers,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Allenamento(
                    data: [
                      {
                        "esercizio": "Chin up negativi",
                        "settimana1": "5x2",
                        "scarico": "-2serie",
                        "recupero": "1-3'",
                        "note": "6’ di negativa, se chiuse tutte le rep e serie, +1rep volta dopo",
                        "timer": 15,
                        "rep": 5,
                      },
                      {
                        "esercizio": "Dip",
                        "settimana1": "Armap2 15'",
                        "scarico": "-2serie",
                        "note": "Quando arrivi a 12 serie passa a triple volta dopo",
                        "timer": 15,
                        "rep": 12,
                      },
                      {
                        "esercizio": "Pull up elastico viola",
                        "settimana1": "Amrap1 12’",
                        "scarico": "-2serie",
                        "note": "Se arrivi a 12 singole, passa a doppie",
                        "timer": 15,
                        "rep": 12
                      },
                      {
                        "esercizio": "Push up",
                        "settimana1": "4x8",
                        "scarico": "-1serie",
                        "recupero": "2-3'",
                        "note": "Se chiuse tutte le rep e le serie bene, +1rep a tutte",
                        "timer": 15,
                      },
                      {
                        "esercizio": "Australian 30",
                        "settimana1": "3xMax tecnico",
                        "scarico": "-1serie",
                        "recupero": "90\"",
                        "note": "Se chiuse tutte le rep e le serie bene, +1rep a tutte",
                        "rep": 3,
                      },
                      {
                        "esercizio": "Plank + barchetta raccolta",
                        "settimana1": "3x30\" + Max",
                        "recupero": "60\" fra giri",
                        "note": "",
                        "timer": 15,
                      },
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          SelectionCard(
            title: 'Giorno B',
            icon: Icons.settings,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('In arrivo...')),
              );
            },
          ),
          const SizedBox(height: 16),
          const SelectionCard(title: 'Giorno C', icon: Icons.info),
        ],
      ),
    );
  }
}

class SelectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const SelectionCard({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
