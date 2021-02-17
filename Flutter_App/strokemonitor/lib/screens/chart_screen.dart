import 'package:flutter/material.dart';
import 'package:strokemonitor/widgets/chart.dart';

class ChartScreen extends StatefulWidget {
  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('StrokeMonitor'),
      ),
      backgroundColor: Colors.lightBlueAccent,
      body: MyChart(),
    );
  }
}
