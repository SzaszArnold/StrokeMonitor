import 'package:flutter/material.dart';
import 'package:strokemonitor/widgets/stroke_risk.dart';

class StrokeRiskScreen extends StatefulWidget {
  @override
  _StrokeRiskScreenState createState() => _StrokeRiskScreenState();
}

class _StrokeRiskScreenState extends State<StrokeRiskScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('StrokeMonitor'),
      ),
      backgroundColor: Colors.lightBlueAccent,
      body: StrokeRisk(),
    );
  }
}
