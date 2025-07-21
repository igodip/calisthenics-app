
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

var serviceUuid = Uuid.parse("12345678-1234-5678-1234-56789abcdef0");
var characteristicUuid = Uuid.parse("abcdef01-1234-5678-1234-56789abcdef0");

class BLEGraph extends StatefulWidget {
  final FlutterReactiveBle ble;
  const BLEGraph({super.key, required this.ble});

  @override
  _BLEGraphState createState() => _BLEGraphState();
}

class _BLEGraphState extends State<BLEGraph> {
  List<FlSpot> zData = [];
  double xValue = 0;
  static const maxPoints = 100;
  int pushUpCount = 0;

  bool goingDown = false;
  DateTime lastPushUpTime = DateTime.now();
  final double downThreshold = 13000;
  final double upThreshold = 16000;
  final Duration debounce = Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();
    widget.ble.initialize().then((_) => scanAndConnect());
  }

  void scanAndConnect() {
    widget.ble.scanForDevices(withServices: []).listen((device) {
      if (device.name == "CALI_MPU") {
        widget.ble.connectToDevice(id: device.id).listen((_) {});
        final char = QualifiedCharacteristic(
          deviceId: device.id,
          serviceId: serviceUuid,
          characteristicId: characteristicUuid,
        );
        widget.ble.subscribeToCharacteristic(char).listen((data) {
          final line = String.fromCharCodes(data);
          parseAndHandle(line);
        });
      }
    });
  }

  void parseAndHandle(String line) {
    try {
      final match = RegExp(r"\[([-0-9]+),([-0-9]+),([-0-9]+)").firstMatch(line);
      if (match != null) {
        final z = double.parse(match.group(3)!);
        detectPushUp(z);

        setState(() {
          zData.add(FlSpot(xValue, z));
          xValue += 1;
          if (zData.length > maxPoints) zData.removeAt(0);
        });
      }
    } catch (_) {}
  }

  void detectPushUp(double z) {
    final now = DateTime.now();
    if (!goingDown && z < downThreshold) {
      goingDown = true;
    } else if (goingDown && z > upThreshold) {
      if (now.difference(lastPushUpTime) > debounce) {
        pushUpCount++;
        lastPushUpTime = now;
      }
      goingDown = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Push-Up Tracker"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Text(
            "Push-Ups: $pushUpCount",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: LineChart(
                LineChartData(
                  minX: xValue - maxPoints.toDouble(),
                  maxX: xValue,
                  minY: 8000,
                  maxY: 18000,
                  gridData: FlGridData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: zData,
                      isCurved: true,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}