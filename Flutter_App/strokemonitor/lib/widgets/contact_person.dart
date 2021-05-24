//import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'dart:async';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:sms/sms.dart';

class ContactPerson extends StatefulWidget {
  @override
  _ContactPersonState createState() => _ContactPersonState();
}

class _ContactPersonState extends State<ContactPerson> {
  final _formKey = GlobalKey<FormState>();
  String _name = "999";
  String _phone = "111";
  String currentPhone = "Not yet!";
  String currentName = "Not yet!";
  String value = "no";
  final _auth = FirebaseAuth.instance;
  final databaseReference = FirebaseDatabase.instance.reference();
  void readData() {
    databaseReference.child('arnoldszasz06data').once().then(
      (DataSnapshot snapshot) {
        print('Data : ${snapshot.value['arni']}');
      },
    );
  }

  void test() async {
    var url =
        Uri.https('www.googleapis.com', '/books/v1/volumes', {'q': '{http}'});

    // Await the http get response, then decode the json-formatted response.
    // var response = await http.get(url);
    final response = await http.get(
      'https://api.fitbit.com/1/user/-/activities/heart/date/today/1d/1sec/time/00:00/00:01.json',
      headers: {
        HttpHeaders.authorizationHeader:
            "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyMkM2NVoiLCJzdWIiOiI4WFRRVzkiLCJpc3MiOiJGaXRiaXQiLCJ0eXAiOiJhY2Nlc3NfdG9rZW4iLCJzY29wZXMiOiJyc29jIHJzZXQgcmFjdCBybG9jIHJ3ZWkgcmhyIHJudXQgcnBybyByc2xlIiwiZXhwIjoxNjE3NjIxNTg4LCJpYXQiOjE2MTcwMjE2NDh9.d5spA4ia9y4NES_f2G0y8THN16BkJMAdeMlFhanQqw4"
      },
    );
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      print('$jsonResponse');
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  void _incrementCounter(String address) {
    SmsSender sender = SmsSender();
    SmsMessage message = SmsMessage(address, 'I am in danger, help me!');
    message.onStateChanged.listen((state) {
      if (state == SmsMessageState.Sent) {
        print("SMS is sent!");
      } else if (state == SmsMessageState.Delivered) {
        print("SMS is delivered!");
      }
    });
    sender.sendSms(message);
  }

/*
  AudioPlayer audioPlayer = AudioPlayer();
  play() async {
    int result = await audioPlayer.play(
        'https://media.geeksforgeeks.org/wp-content/uploads/20190531135120/beep.mp3');
    if (result == 1) {
      // success
    }
  }*/

  Future<String> _future;
  @override
  void initState() {
    super.initState();
    setUpTimedFetch();
  }

  setUpTimedFetch() {
    Timer.periodic(Duration(milliseconds: 60000), (timer) {
      setState(() {
        _future = Future.value(timer.tick.toString());
      });
    });
  }

  void _trySave() {
    FocusScope.of(context).unfocus();
    _formKey.currentState.save();
    FirebaseFirestore.instance
        .collection('usersContact')
        .doc(_auth.currentUser.email
            .substring(0, _auth.currentUser.email.lastIndexOf('@')))
        .set({
      'name': _name,
      'phone': _phone,
    });
  }

  @override
  Widget build(BuildContext context) {
    test();
    return Center(
      child: Card(
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  /*  FutureBuilder<String>(
                    future: _future,
                    builder: (context, snapshot) {
                      databaseReference.child('arnoldszasz06data').once().then(
                        (DataSnapshot snapshot) {
                          String currentValue = snapshot.value['arni'];
                          print(currentValue);
                          // play();
                          /*setState(
                            () {
                              value = '${snapshot.value['arni']}';
                            },
                          );*/
                        },
                      );

                      return Center(
                        child: Text('${value}'),
                      );
                    },
                  ),*/
                  StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('usersContact')
                          .doc(_auth.currentUser.email.substring(
                              0, _auth.currentUser.email.lastIndexOf('@')))
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final documents = snapshot.data;
                        return Container(
                          child: Column(
                            children: [
                              Center(
                                child: FlatButton(
                                  child: Text('Phone Call'), // 0741903889
                                  onPressed: () {
                                    _incrementCounter(documents['phone']);
                                    /*    FlutterPhoneDirectCaller.callNumber(
                                        '${documents['phone']}');*/
                                  },
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.contact_phone_rounded),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    '${documents['name']}',
                                    key: ValueKey('contactName'),
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.phone),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      '${documents['phone']}',
                                      key: ValueKey('contactPhone'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ]),
                              SizedBox(
                                height: 12,
                              ),
                            ],
                          ),
                        );
                      }),
                  TextFormField(
                    key: ValueKey('name'),
                    validator: (value) {
                      if (value.isEmpty || value.length < 4) {
                        return 'Name must be at least 4 characters long.';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Name',
                    ),
                    obscureText: false,
                    onSaved: (value) {
                      _name = value;
                    },
                  ),
                  TextFormField(
                    key: ValueKey('phone'),
                    validator: (value) {
                      if (value.isEmpty || value.length < 10) {
                        return 'Phone number must be at least 10 characters long.';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Phone number',
                    ),
                    obscureText: false,
                    onSaved: (value) {
                      setState(
                        () {
                          _phone = value;
                        },
                      );
                    },
                  ),
                  IconButton(
                    key: ValueKey('saveContact'),
                    icon: Icon(Icons.save),
                    onPressed: () {
                      setState(() {
                        _trySave();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
