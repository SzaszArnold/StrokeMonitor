//import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'dart:async';
import 'package:sms/sms.dart';

class ContactPerson extends StatefulWidget {
  @override
  _ContactPersonState createState() => _ContactPersonState();
}

/*Based on the documentation at the link: https://flutter.dev/docs/development/ui/widgets/material
                                          https://firebase.flutter.dev/docs/firestore/usage
                                          https://pub.dev/packages/sms
                                          https://pub.dev/packages/flutter_phone_direct_caller
                                          https://firebase.flutter.dev/docs/auth/usage/
*/
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

  void _sendSMS(String address) {
    SmsSender sender = SmsSender();
    SmsMessage message = SmsMessage(
        address,
        'Hello I am ${_auth.currentUser.email}.\n' +
            'I am adding you to a monitoring application called StrokeMonitor\n' +
            'If you get a notification, call the ambulance, chances are I have a stroke!');
    message.onStateChanged.listen((state) {
      if (state == SmsMessageState.Sent) {
        print("SMS is sent!");
      } else if (state == SmsMessageState.Delivered) {
        print("SMS is delivered!");
      }
    });
    sender.sendSms(message);
  }

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
                              TextButton(
                                style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Theme.of(context).primaryColor),
                                ),
                                child: Text('Call the contact person!'),
                                onPressed: () {
                                  FlutterPhoneDirectCaller.callNumber(
                                      '${documents['phone']}');
                                },
                              ),
                              TextButton(
                                style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Theme.of(context).primaryColor),
                                ),
                                child: Text(
                                    'Notify the contact person! with message'),
                                onPressed: () {
                                  _sendSMS('${documents['phone']}');
                                },
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
