import 'package:calisync/selection_card.dart';
import 'package:calisync/training.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class HomeContent extends StatefulWidget {

  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  void initState() {
    super.initState();
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
                  builder:
                      (context) => Training(
                    data: [
                      {
                        "esercizio": "Chin up negativi",
                        "settimana1": "5x2",
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
                        "scarico": "-2serie",
                        "note":
                        "Quando arrivi a 12 serie passa a triple volta dopo",
                        "timer": 15,
                        "rep": 12,
                      },
                      {
                        "esercizio": "Pull up elastico viola",
                        "settimana1": "Amrap1 12’",
                        "scarico": "-2serie",
                        "note": "Se arrivi a 12 singole, passa a doppie",
                        "timer": 15,
                        "rep": 12,
                      },
                      {
                        "esercizio": "Push up",
                        "settimana1": "4x8",
                        "scarico": "-1serie",
                        "recupero": "2-3'",
                        "note":
                        "Se chiuse tutte le rep e le serie bene, +1rep a tutte",
                        "timer": 15,
                      },
                      {
                        "esercizio": "Australian 30",
                        "settimana1": "3xMax tecnico",
                        "scarico": "-1serie",
                        "recupero": "90\"",
                        "note":
                        "Se chiuse tutte le rep e le serie bene, +1rep a tutte",
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
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('In arrivo...')));
            },
          ),
          const SizedBox(height: 16),
          SelectionCard(
            title: 'Giorno C',
            icon: Icons.info,
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('In arrivo...')));
            },
          ),
        ],
      ),
    );
  }
}
