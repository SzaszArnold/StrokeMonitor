import 'package:flutter/material.dart';
import 'package:bezier_chart/bezier_chart.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:strokemonitor/models/fitbit_day_model.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

const List<DataPoint<dynamic>> data = [];

class Chart extends StatefulWidget {
  @override
  _ChartState createState() => _ChartState();
}

/*Based on the documentation at the link: https://flutter.dev/docs/development/ui/widgets/material
                                          https://pub.dev/packages/http
                                          https://pub.dev/packages/shared_preferences
                                          https://dev.fitbit.com/build/reference/web-api/oauth2/
                                          https://dev.fitbit.com/build/reference/web-api/heart-rate/
                                          https://dev.fitbit.com/build/reference/web-api/user/
                                          https://pub.dev/packages/syncfusion_flutter_charts
                                          https://pub.dev/packages/flutter_web_auth
                                          https://pub.dev/packages/numberpicker
*/
class _ChartState extends State<Chart> {
  String _status = '';
  String _token = '';
  String typeDay = 'day';
  String typeHour = 'day';
  int _currentValue = 0;
  Future authenticate() async {
    await _loadToken();
    if (_token == '') {
      final url =
          'https://www.fitbit.com/oauth2/authorize?response_type=token&client_id=22C65Z&redirect_uri=https%3A%2F%2Fredirecthoststrokemonitor.web.app%2F&scope=activity%20heartrate%20location%20nutrition%20profile%20settings%20sleep%20social%20weight&expires_in=604800';
      final callbackUrlScheme = 'token';

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
    typeDay = 'day';
    typeHour = "";
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

  Future _getFitbitHour() async {
    typeHour = "hour";
    final response = await http.get(
      'https://api.fitbit.com/1/user/-/activities/heart/date/today/today/1min.json',
      headers: {HttpHeaders.authorizationHeader: _token},
    );
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      fitbitData = [];
      for (var i in jsonResponse['activities-heart-intraday']['dataset']) {
        if (DateTime.parse('1998-01-01 ' + "${i['time']}").hour ==
            _currentValue)
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

  List<FitbitData> fitbitData = [];
  Future _getFitbitLastSevenDay() async {
    typeDay = 'week';
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
                    width: 10,
                  ),
                  Text(
                    'Select filter: ',
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
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
                  NumberPicker(
                    haptics: true,
                    itemHeight: 25,
                    value: _currentValue,
                    minValue: 0,
                    maxValue: 23,
                    itemWidth: 30,
                    onChanged: (value) => setState(() => _currentValue = value),
                  ),
                  IconButton(
                      tooltip: "Show selected hour",
                      icon: Icon(
                        Icons.hourglass_bottom_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        print(_currentValue);
                        _getFitbitHour();
                      })
                ],
              ),
            ),
            Container(
              child: typeDay == "day"
                  ? Container(
                      child: typeHour == "hour"
                          ? Container(
                              height: MediaQuery.of(context).size.height / 1.5,
                              child: SfCartesianChart(
                                title: ChartTitle(
                                    text: 'Heart rate selected hour'),
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
                                          borderWidth: 2,
                                          borderColor:
                                              Theme.of(context).primaryColor),
                                      dataSource: fitbitData,
                                      color: Theme.of(context).primaryColor,
                                      xAxisName: "Date",
                                      name: 'BPM',
                                      yAxisName: 'BPM',
                                      xValueMapper: (FitbitData data, _) =>
                                          data.date.minute.toString(),
                                      yValueMapper: (FitbitData data, _) =>
                                          data.value)
                                ],
                              ),
                            )
                          : Container(
                              height: MediaQuery.of(context).size.height / 1.5,
                              child: SfCartesianChart(
                                title: ChartTitle(
                                    text: 'Heart rate today in every hour'),
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
                                          borderColor:
                                              Theme.of(context).primaryColor),
                                      dataSource: fitbitData,
                                      color: Theme.of(context).primaryColor,
                                      xAxisName: "Date",
                                      name: 'BPM',
                                      yAxisName: 'BPM',
                                      xValueMapper: (FitbitData data, _) =>
                                          data.date.hour.toString(),
                                      yValueMapper: (FitbitData data, _) =>
                                          data.value)
                                ],
                              ),
                            ))
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
