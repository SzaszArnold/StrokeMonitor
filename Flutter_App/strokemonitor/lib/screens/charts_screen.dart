import 'package:bezier_chart/bezier_chart.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:strokemonitor/models/sample_data.dart';

final _databaseReference = FirebaseDatabase.instance.reference();
List<SampleData> list = [];
const List<DataPoint<dynamic>> data = [];

class ChartsScreen extends StatefulWidget {
  @override
  _ChartsScreenState createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  void readData() {
    _databaseReference
        .child('arnoldszasz06data')
        .once()
        .then((DataSnapshot snapshot) {
      for (var value in snapshot.value.values) {
        if (value['value'] != null) {
          list.add(SampleData(value: double.tryParse(value['value'])));
        }
      }
    });
  }

  void seee() {
    print(list.length);
    for (var value in list) {
      if (value != null) {
        print(value.value);
        data.add(DataPoint(value: value.value));
      }
    }
  }

  _onTap(BuildContext context, Widget widget) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(),
          body: widget,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Charts'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlatButton(
              onPressed: readData,
              child: Text('try'),
            ),
            FlatButton(
              onPressed: seee,
              child: Text('try2'),
            ),
            ListTile(
              title: Text("Line"),
              subtitle: Text("Number Chart"),
              onTap: () => _onTap(
                context,
                sample1(context),
              ),
            ),
            ListTile(
              title: Text("Bar"),
              subtitle: Text("Number Chart"),
              onTap: () => _onTap(
                context,
                sample1(context),
              ),
            ),
            ListTile(
              title: Text("Column"),
              subtitle: Text("Number Chart"),
              onTap: () => _onTap(
                context,
                sample1(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//SAMPLE CUSTOM VALUES
Widget sample1(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.black54,
          Colors.black87,
          Colors.black87,
          Colors.black,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          "Bezier Chart - Numbers",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        Center(
          child: Card(
            elevation: 12,
            child: Container(
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width * 0.9,
              child: BezierChart(
                bezierChartScale: BezierChartScale.CUSTOM,
                selectedValue: 30,
                xAxisCustomValues: const [0, 5, 10, 15, 20, 25, 30, 35],
                footerValueBuilder: (double value) {
                  return "${formatAsIntOrDouble(value)}\ndays";
                },
                series: const [
                  BezierLine(
                    label: "m",
                    data: const [
                      DataPoint<double>(value: 10, xAxis: 0),
                      DataPoint<double>(value: 130, xAxis: 5),
                      DataPoint<double>(value: 50, xAxis: 10),
                      DataPoint<double>(value: 150, xAxis: 15),
                      DataPoint<double>(value: 75, xAxis: 20),
                      DataPoint<double>(value: 0, xAxis: 25),
                      DataPoint<double>(value: 5, xAxis: 30),
                      DataPoint<double>(value: 45, xAxis: 35),
                    ],
                  ),
                ],
                config: BezierChartConfig(
                  startYAxisFromNonZeroValue: false,
                  bubbleIndicatorColor: Colors.white.withOpacity(0.9),
                  footerHeight: 40,
                  verticalIndicatorStrokeWidth: 3.0,
                  verticalIndicatorColor: Colors.black26,
                  showVerticalIndicator: true,
                  verticalIndicatorFixedPosition: false,
                  displayYAxis: true,
                  stepsYAxis: 10,
                  backgroundGradient: LinearGradient(
                    colors: [
                      Colors.red[300],
                      Colors.red[400],
                      Colors.red[400],
                      Colors.red[500],
                      Colors.red,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  snap: true,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
