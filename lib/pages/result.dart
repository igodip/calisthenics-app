import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mrx_charts/mrx_charts.dart';

class HistogramBin {
  final String range;
  final int frequency;

  HistogramBin({required this.range, required this.frequency});
}

class HistogramChart extends StatelessWidget {

  const HistogramChart({super.key});

  @override
  Widget build(BuildContext context) {
    // Convert bins to BarData
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Histogram Chart')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Chart(
          layers: [
            ChartAxisLayer(
              settings: ChartAxisSettings(
                x: ChartAxisSettingsAxis(
                  frequency: 1.0,
                  max: 13.0,
                  min: 7.0,
                  textStyle: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                y: ChartAxisSettingsAxis(
                  frequency: 100.0,
                  max: 300.0,
                  min: 0.0,
                  textStyle: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              labelX: (value) => value.toInt().toString(),
              labelY: (value) => value.toInt().toString(),
            ),
            ChartBarLayer(
              items: List.generate(
                13 - 7 + 1,
                (index) => ChartBarDataItem(
                  color: colorScheme.secondary,
                  value: Random().nextInt(280) + 20,
                  x: index.toDouble() + 7,
                ),
              ),
              settings: const ChartBarSettings(
                thickness: 8.0,
                radius: BorderRadius.all(Radius.circular(4.0)),
              ),
            ),
          ]
        )
      ),
    );
  }
}

class BarData {
  final String id;
  final double value;
  final Color color;

  BarData({
    required this.id,
    required this.value,
    required this.color,
  });
}