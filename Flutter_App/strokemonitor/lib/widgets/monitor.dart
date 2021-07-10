import 'dart:convert';
import 'dart:io';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:sms/sms.dart';
import 'package:flutter/services.dart';

class Monitor extends StatefulWidget {
  @override
  _MonitorState createState() => _MonitorState();
}

/*Based on the documentation at the link: https://flutter.dev/docs/development/ui/widgets/material
                                          https://pub.dev/packages/http
                                          https://firebase.flutter.dev/docs/firestore/usage
                                          https://pub.dev/packages/sms
                                          https://pub.dev/packages/flutter_phone_direct_caller
                                          https://firebase.flutter.dev/docs/auth/usage/
                                          https://pub.dev/packages/flutter_background_service
                                          https://pub.dev/packages/shared_preferences
*/
class _MonitorState extends State<Monitor> {
  String currentPhone = "0749091739";
  String value = "no";
  bool timerFlag = true;
  bool sentSMS;
  String _token = "";
  String _uid = "";
  final _auth = FirebaseAuth.instance;
  final databaseReference = FirebaseDatabase.instance.reference();
  Future<String> _future;
  @override
  void initState() {
    super.initState();
    if (timerFlag) {
      setUpTimedFetch();
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

  Future _loadUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _uid = (prefs.getString('uid') ?? "");
    });
  }

  void _nullUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('uid', "");
  }

  Future _sendSMS(String address) async {
    print('entered');
    SmsSender sender = SmsSender();
    SmsMessage message = SmsMessage(
        address,
        'I am in danger, my current pulse is $value\n' +
            'Please call the ambulance!');
    message.onStateChanged.listen(
      (state) {
        if (state == SmsMessageState.Sent) {
          print("SMS is sent!");
        } else if (state == SmsMessageState.Delivered) {
          print("SMS is delivered!");
        }
      },
    );
    sender.sendSms(message);
  }

  setUpTimedFetch() {
    Timer.periodic(Duration(milliseconds: 60000), (timer) {
      setState(() {
        _future = Future.value(timer.tick.toString());
      });
    });
  }

  Future _getUserUID() async {
    await _loadToken();
    await _loadUID();
    if (_uid == '') {
      final response = await http.get(
        'https://api.fitbit.com/1/user/-/profile.json',
        headers: {HttpHeaders.authorizationHeader: _token},
      );
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        print(jsonResponse['user']['encodedId']);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('uid', "${jsonResponse['user']['encodedId']}");
      } else {
        if (response.statusCode == 401) {
          _nullToken();
          _nullUID();
        }
        print('Request failed with status: ${response.statusCode}.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _getUserUID();
    return Column(
      children: [
        StreamBuilder<Map<String, dynamic>>(
          stream: FlutterBackgroundService().onDataReceived,
          builder: (context, snapshot) {
            return FutureBuilder<String>(
              future: _future,
              builder: (context, snapshot) {
                databaseReference.child('$_uid').once().then(
                  (DataSnapshot snapshot) {
                    String currentValue = snapshot.value['data'];
                    print(currentValue);
                    if (int.parse(currentValue) >= 160) {
                      HapticFeedback.heavyImpact();
                      print(currentPhone);
                      timerFlag = false;
                      print('send sms');
                      _sendSMS(currentPhone);
                      // FlutterPhoneDirectCaller.callNumber('$currentPhone');
                      return Center(
                        child: Column(
                          children: [
                            Icon(Icons.warning),
                          ],
                        ),
                      );
                    }
                  },
                );
                return Text('');
              },
            );
          },
        ),
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('usersContact')
              .doc(_auth.currentUser.email
                  .substring(0, _auth.currentUser.email.lastIndexOf('@')))
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Text(''),
              );
            }
            final documents = snapshot.data;
            currentPhone = documents['phone'];
            return Text('');
          },
        ),
      ],
    );
  }
}
