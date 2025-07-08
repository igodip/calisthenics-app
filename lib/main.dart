import 'package:Calisthenics/training.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CalisthenicsApp());
}

class CalisthenicsApp extends StatelessWidget {
  const CalisthenicsApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calisthenics',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white, // changes title & icon color
        ),
        primaryColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Home page'),
      debugShowCheckedModeBanner: false,
    );
  }
}



class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
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
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;
  int selectedIndex = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
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
                    builder:
                        (context) => Allenamento(
                          data: [
                            {
                              "esercizio": "Chin up negativi",
                              "settimana1": "5x2",
                              "settimana2": "",
                              "settimana3": "",
                              "settimana4": "",
                              "scarico": "-2serie",
                              "recupero": "1-3'",
                              "note":
                                  "6’ di negativa, se chiuse tutte le rep e serie, +1rep volta dopo",
                              "timer": 15,
                              "rep": 5,
                            },
                            {
                              "esercizio": "Dip",
                              "settimana1": "Armap2 15'",
                              "settimana2": "",
                              "settimana3": "",
                              "settimana4": "",
                              "scarico": "-2serie",
                              "recupero": "",
                              "note":
                                  "Quando arrivi a 12 serie passa a triple volta dopo",
                              "timer": 15,
                            },
                            {
                              "esercizio": "Pull up elastico viola",
                              "settimana1": "Amrap1 12’",
                              "settimana2": "",
                              "settimana3": "",
                              "settimana4": "",
                              "scarico": "-2serie",
                              "recupero": "",
                              "note": "Se arrivi a 12 singole, passa a doppie",
                              "timer": 15,
                            },
                            {
                              "esercizio": "Push up",
                              "settimana1": "4x8",
                              "settimana2": "",
                              "settimana3": "",
                              "settimana4": "",
                              "scarico": "-1serie",
                              "recupero": "2-3'",
                              "note":
                                  "Se chiuse tutte le rep e le serie bene, +1rep a tutte",
                              "timer": 15,
                            },
                            {
                              "esercizio": "Australian 30",
                              "settimana1": "3xMax tecnico",
                              "settimana2": "",
                              "settimana3": "",
                              "settimana4": "",
                              "scarico": "-1serie",
                              "recupero": "90\"",
                              "note":
                                  "Se chiuse tutte le rep e le serie bene, +1rep a tutte",
                              "rep": 3,
                            },
                            {
                              "esercizio": "Plank + barchetta raccolta",
                              "settimana1": "3x30\" + Max",
                              "settimana2": "",
                              "settimana3": "",
                              "settimana4": "",
                              "scarico": "",
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
            SizedBox(height: 16),
            SelectionCard(title: 'Giorno B', icon: Icons.settings),
            SizedBox(height: 16),
            SelectionCard(title: 'Giorno C', icon: Icons.info),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
