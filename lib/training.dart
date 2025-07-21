import 'package:calisync/rep_counter.dart';
import 'package:calisync/rep_timer.dart';
import 'package:calisync/result.dart';
import 'package:calisync/timer.dart';
import 'package:flutter/material.dart';

class Training extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const Training({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final headers = [
      'Esercizi',
      'Settimana 1',
      'Settimana 2',
      'Settimana 3',
      'Settimana 4',
      'Scarico',
      'Recupero',
      'Note',
    ];
    return Scaffold(
      appBar: AppBar(title: Text('Allenamento')),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                border: TableBorder.all(color: Colors.grey),
                columnWidths: {
                  for (int i = 0; i < headers.length; i++)
                    i: IntrinsicColumnWidth(),
                },
                children: [
                  // Header row
                  TableRow(
                    decoration: BoxDecoration(color: Colors.blue[300]),
                    children:
                    headers.map((header) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          header,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }).toList(),
                  ),
                  // Data rows
                  ...data.map((row) {
                    return TableRow(
                      children: [
                        _cell(
                          row['esercizio'],
                          onTap: () {
                            if (row.containsKey('timer') &&
                                row.containsKey('rep')) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => RepTimerWidget(
                                    title: row['esercizio'],
                                    countdownDuration: Duration(
                                      minutes: row['timer'],
                                    ),
                                    initialRepCount: 0,
                                    targetRepCount: row['rep'],
                                  ),
                                ),
                              );
                            } else if (row.containsKey('timer')) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => TimerPage(
                                    countdownDuration: Duration(
                                      minutes: row['timer'],
                                    ),
                                  ),
                                ),
                              );
                            } else if (row.containsKey('rep')) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                      RepCounter(title: row['esercizio'], timerType: ""), //NICOLò RICORDATI DI FARE IL TIMERTYPE
                                ),
                              );
                            }
                          },
                        ),
                        _cell(row['settimana1']),
                        _cell(row['settimana2']),
                        _cell(row['settimana3']),
                        _cell(row['settimana4']),
                        _cell(row['scarico']),
                        _cell(row['recupero']),
                        _cell(row['note']),
                      ],
                    );
                  }),
                ],
              ),
              SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => HistogramChart()));
                },
                child: const Text('Check progress'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cell(dynamic value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          value?.toString() ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}