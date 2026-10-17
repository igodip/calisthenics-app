import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class WorkoutPlanPdfPage extends StatelessWidget {
  const WorkoutPlanPdfPage({
    required this.data,
    required this.title,
    super.key,
  });

  final Uint8List data;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PdfViewer.data(data, sourceName: title),
    );
  }
}
