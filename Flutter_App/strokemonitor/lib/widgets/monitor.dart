import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'dart:async';
import 'package:sms/sms.dart';
import 'package:flutter/services.dart';

class Monitor extends StatefulWidget {
  @override
  _MonitorState createState() => _MonitorState();
}

class _MonitorState extends State<Monitor> {
  String currentPhone = "0749091739";
  String value = "no";
  bool timerFlag = true;
  bool sentSMS;
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
        FutureBuilder<String>(
            future: _future,
            builder: (context, snapshot) {
              databaseReference.child('arnoldszasz06').once().then(
                (DataSnapshot snapshot) {
                  String currentValue = snapshot.value['data'];
                  print(currentValue);
                  setState(
                    () {
                      value = '${snapshot.value['data']}';
                    },
                  );
                },
              );
              if (int.parse(value) >= 140) {
                HapticFeedback.heavyImpact();
                print(currentPhone);
                timerFlag = false;
                // _sendSMS(currentPhone);
                // FlutterPhoneDirectCaller.callNumber('$currentPhone');
                return Center(
                  child: Column(
                    children: [
                      Icon(Icons.warning),
                    ],
                  ),
                );
              } else {
                timerFlag = true;
                return Text('');
              }
            }),
      ],
    );
  }
}
