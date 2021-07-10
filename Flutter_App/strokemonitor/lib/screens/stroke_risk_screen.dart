import 'package:flutter/material.dart';
import 'package:strokemonitor/widgets/stroke_risk.dart';

class StrokeRiskScreen extends StatefulWidget {
  static const routeName = '/risk';
  @override
  _StrokeRiskScreenState createState() => _StrokeRiskScreenState();
}

class _StrokeRiskScreenState extends State<StrokeRiskScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stroke Risk'),
      ),
      backgroundColor: Color.fromRGBO(247, 137, 137, 1),
      body: StrokeRisk(),
    );
  }
}
