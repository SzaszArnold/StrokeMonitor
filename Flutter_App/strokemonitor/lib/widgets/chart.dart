import 'package:flutter/material.dart';
import 'package:bezier_chart/bezier_chart.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:strokemonitor/models/fitbit_day_model.dart';
import 'package:strokemonitor/models/sample_data.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

final _databaseReference = FirebaseDatabase.instance.reference();
List<SampleData> list = [];
const List<DataPoint<dynamic>> data = [];

class Chart extends StatefulWidget {
  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  String _status = '';
  String _token = '';
  String type = 'day';
  Future authenticate() async {
    await _loadToken();
    if (_token == '') {
      final url =
          'https://www.fitbit.com/oauth2/authorize?response_type=token&client_id=22C65Z&redirect_uri=https%3A%2F%2Fredirecthoststrokemonitor.web.app%2F&scope=activity%20heartrate%20location%20nutrition%20profile%20settings%20sleep%20social%20weight&expires_in=604800';
      final callbackUrlScheme = 'foobar';

      try {
        final result = await FlutterWebAuth.authenticate(
            url: url, callbackUrlScheme: callbackUrlScheme);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token',
            "Bearer ${result.substring(result.indexOf('=') + 1, result.indexOf('&'))}");
        setState(() {
          _status =
              result.substring(result.indexOf('=') + 1, result.indexOf('&'));
        });
      } on PlatformException catch (e) {
        setState(() {
          _status = 'Got error: $e';
        });
      }
    }
  }

  Future _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = (prefs.getString('token') ?? "");
    });
  }

  void _nullToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('token', "");
  }

  Future _getFitbitToday() async {
    type = 'day';
    final response = await http.get(
      'https://api.fitbit.com/1/user/-/activities/heart/date/today/today/5min.json',
      headers: {HttpHeaders.authorizationHeader: _token},
    );
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      fitbitData = [];
      for (var i in jsonResponse['activities-heart-intraday']['dataset']) {
        if (DateTime.parse('1998-01-01 ' + "${i['time']}").minute == 0)
          fitbitData.add(FitbitData(
              DateTime.parse('1998-01-01 ' + "${i['time']}"), i['value']));
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Succes!')));
    } else {
      if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authorization required!')));
        _nullToken();
      }
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Future _getFitbitLastHour() async {
    int stop = DateTime.now().hour;
    int start = stop - 1;
    final response = await http.get(
      'https://api.fitbit.com/1/user/-/activities/heart/date/today/today/5min/time/$start:00/$stop:00.json',
      headers: {HttpHeaders.authorizationHeader: _token},
    );
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      print('$jsonResponse');
    } else {
      if (response.statusCode == 401) {
        _nullToken();
      }
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  List<FitbitData> fitbitData = [];
  Future _getFitbitLastSevenDay() async {
    type = 'week';
    final response = await http.get(
      'https://api.fitbit.com/1/user/-/activities/heart/date/today/7d.json',
      headers: {HttpHeaders.authorizationHeader: _token},
    );
    if (response.statusCode == 200) {
      fitbitData = [];
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      jsonResponse.forEach((key, value) {
        fitbitData.add(FitbitData(DateTime.parse("${value[0]['dateTime']}"),
            value[0]['value']['restingHeartRate']));
        fitbitData.add(FitbitData(DateTime.parse("${value[1]['dateTime']}"),
            value[1]['value']['restingHeartRate']));
        fitbitData.add(FitbitData(DateTime.parse("${value[2]['dateTime']}"),
            value[2]['value']['restingHeartRate']));
        fitbitData.add(FitbitData(DateTime.parse("${value[3]['dateTime']}"),
            value[3]['value']['restingHeartRate']));
        fitbitData.add(FitbitData(DateTime.parse("${value[4]['dateTime']}"),
            value[4]['value']['restingHeartRate']));
        fitbitData.add(FitbitData(DateTime.parse("${value[5]['dateTime']}"),
            value[5]['value']['restingHeartRate']));
        fitbitData.add(FitbitData(DateTime.parse("${value[6]['dateTime']}"),
            value[6]['value']['restingHeartRate']));
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Succes!')));
    } else {
      if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authorization required!')));
        _nullToken();
      }
      print('Request failed with status: ${response.statusCode}.');
    }
  }

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
    authenticate();
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              alignment: Alignment.center,
              child: Row(
                children: [
                  SizedBox(
                    width: 15,
                  ),
                  Text(
                    'Select filter: ',
                    style: TextStyle(
                      fontSize: 28,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  /* DropdownButton<String>(
                    value: dropdownValue,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                        //for (var value in list) print('${value.value}');
                      });
                    },
                    items: <String>['Day', 'Week']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 28,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),*/
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      onPrimary: Colors.white,
                    ),
                    child: Text('Day'),
                    onPressed: () {
                      _getFitbitToday();
                    },
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      onPrimary: Colors.white,
                    ),
                    child: Text('Week'),
                    onPressed: () {
                      _getFitbitLastSevenDay();
                    },
                  ),
                ],
              ),
            ),
            Container(
              child: type == "day"
                  ? Container(
                      height: MediaQuery.of(context).size.height / 1.5,
                      child: SfCartesianChart(
                        title: ChartTitle(text: 'Resting heart rate'),
                        enableAxisAnimation: true,
                        primaryXAxis: CategoryAxis(),
                        tooltipBehavior: TooltipBehavior(enable: true),
                        enableSideBySideSeriesPlacement: true,
                        legend: Legend(
                          isVisible: true,
                        ),
                        series: <LineSeries<FitbitData, String>>[
                          LineSeries<FitbitData, String>(
                              enableTooltip: true,
                              markerSettings: MarkerSettings(
                                  isVisible: true,
                                  height: 5,
                                  width: 5,
                                  shape: DataMarkerType.circle,
                                  borderWidth: 3,
                                  borderColor: Theme.of(context).primaryColor),
                              dataSource: fitbitData,
                              color: Theme.of(context).primaryColor,
                              xAxisName: "Date",
                              name: 'BPM',
                              yAxisName: 'BPM',
                              xValueMapper: (FitbitData data, _) =>
                                  data.date.hour.toString(),
                              yValueMapper: (FitbitData data, _) => data.value)
                        ],
                      ),
                    )
                  : Container(
                      height: MediaQuery.of(context).size.height / 1.5,
                      child: SfCartesianChart(
                        title: ChartTitle(text: 'Resting heart rate'),
                        enableAxisAnimation: true,
                        primaryXAxis: CategoryAxis(),
                        tooltipBehavior: TooltipBehavior(enable: true),
                        enableSideBySideSeriesPlacement: true,
                        legend: Legend(
                          isVisible: true,
                        ),
                        series: <LineSeries<FitbitData, String>>[
                          LineSeries<FitbitData, String>(
                              enableTooltip: true,
                              markerSettings: MarkerSettings(
                                  isVisible: true,
                                  height: 5,
                                  width: 5,
                                  shape: DataMarkerType.circle,
                                  borderWidth: 3,
                                  borderColor: Theme.of(context).primaryColor),
                              dataSource: fitbitData,
                              color: Theme.of(context).primaryColor,
                              xAxisName: "Date",
                              name: 'BPM',
                              yAxisName: 'BPM',
                              xValueMapper: (FitbitData data, _) =>
                                  data.date.day.toString(),
                              yValueMapper: (FitbitData data, _) => data.value)
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
