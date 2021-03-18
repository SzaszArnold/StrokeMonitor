import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'dart:async';

class Monitor extends StatefulWidget {
  @override
  _MonitorState createState() => _MonitorState();
}

class _MonitorState extends State<Monitor> {
  String currentPhone = "Not yet!";
  String value = "no";
  bool timerFlag = true;
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
              databaseReference.child('arnoldszasz06data').once().then(
                (DataSnapshot snapshot) {
                  String currentValue = snapshot.value['arni'];
                  print(currentValue);
                  setState(
                    () {
                      value = '${snapshot.value['arni']}';
                    },
                  );
                },
              );
              if (int.parse(value) >= 160) {
                print(currentPhone);
                timerFlag = false;
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
