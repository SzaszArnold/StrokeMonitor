import 'package:bezier_chart/bezier_chart.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:strokemonitor/models/sample_data.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;
import 'dart:io';
import 'package:flutter/services.dart';

final _databaseReference = FirebaseDatabase.instance.reference();
List<SampleData> list = [];
const List<DataPoint<dynamic>> data = [];

class ChartsScreen extends StatefulWidget {
  @override
  _ChartsScreenState createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  String _status = '';
  String _token = '';
  Future authenticate() async {
    await _loadToken();
    if (_token == '') {
      final url =
          'https://www.fitbit.com/oauth2/authorize?response_type=token&client_id=22C65Z&redirect_uri=https%3A%2F%2Fredirecthoststrokemonitor.web.app%2F&scope=activity%20heartrate%20location%20nutrition%20profile%20settings%20sleep%20social%20weight&expires_in=604800000000';
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

  void _getFitbitToday() async {
    final response = await http.get(
      'https://api.fitbit.com/1/user/-/activities/heart/date/today/1d.json',
      headers: {HttpHeaders.authorizationHeader: _token},
    );
    if (response.statusCode == 200) {
      Map<dynamic, dynamic> jsonResponse = convert.jsonDecode(response.body);
      print('Data, ${jsonResponse['activities-heart']}!');
    } else {
      if (response.statusCode == 401) {
        _nullToken();
      }
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  void _getFitbitLastHour() async {
    int stop = DateTime.now().hour;
    int start = stop - 1;
    final response = await http.get(
      'https://api.fitbit.com/1/user/-/activities/heart/date/today/today/5min/time/$start:00/$stop:00.json',
      headers: {HttpHeaders.authorizationHeader: _token},
    );
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      print('$jsonResponse');
    } else {
      if (response.statusCode == 401) {
        _nullToken();
      }
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  void _getFitbitLastSevenDay() async {
    final response = await http.get(
      'https://api.fitbit.com/1/user/-/activities/heart/date/today/7d.json',
      headers: {HttpHeaders.authorizationHeader: _token},
    );
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      print('$jsonResponse');
    } else {
      if (response.statusCode == 401) {
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
    String dropdownValue = 'Hour';
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            RaisedButton(
              child: Text('hour'),
              onPressed: () {
                this._getFitbitLastHour();
              },
            ),
            RaisedButton(
              child: Text('day'),
              onPressed: () {
                this._getFitbitToday();
              },
            ),
            RaisedButton(
              child: Text('7day'),
              onPressed: () {
                this._getFitbitLastSevenDay();
              },
            ),
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
                  DropdownButton<String>(
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
                    items: <String>['Hour', 'Day', 'Week']
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
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text(
                "Bar",
                style: TextStyle(
                  fontSize: 28,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Container(
                height: 100,
                width: double.infinity,
                child: Image.network(
                  'https://static.thenounproject.com/png/2339094-200.png',
                  fit: BoxFit.fitHeight,
                ),
              ),
              onTap: () => _onTap(
                context,
                sample1(context),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ListTile(
              title: Text(
                "Line",
                style: TextStyle(
                  fontSize: 28,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Container(
                height: 100,
                width: double.infinity,
                child: Image.network(
                  'https://icons.iconarchive.com/icons/iconsmind/outline/512/Line-Chart-icon.png',
                  fit: BoxFit.fitHeight,
                ),
              ),
              onTap: () => _onTap(
                context,
                sample1(context),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ListTile(
              title: Text(
                "Column",
                style: TextStyle(
                  fontSize: 28,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Container(
                height: 100,
                width: double.infinity,
                child: Image.network(
                  'https://cdn.onlinewebfonts.com/svg/img_63775.png',
                  fit: BoxFit.fitHeight,
                ),
              ),
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
