import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileData extends StatefulWidget {
  @override
  _ProfileDataState createState() => _ProfileDataState();
}

class _ProfileDataState extends State<ProfileData> {
  final _auth = FirebaseAuth.instance;
  String _birthDate = "";
  String _height = '';
  String _weight = '';
  String _risk = '';
  var a = DateTime.now().weekday;
  void loadData() {
    print('$a');
    FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser.email
            .substring(0, _auth.currentUser.email.lastIndexOf('@')))
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {}
    });
    FirebaseFirestore.instance
        .collection('risk')
        .doc(_auth.currentUser.email
            .substring(0, _auth.currentUser.email.lastIndexOf('@')))
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        _risk = documentSnapshot.data().values.last;
        print('${documentSnapshot.data().values.last}');
      }
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Name: ${_auth.currentUser.email.substring(0, _auth.currentUser.email.lastIndexOf('@'))}',
                    style: TextStyle(
                      fontSize: 28,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'BD ${_birthDate}',
                    style: TextStyle(
                      fontSize: 28,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Height ${_height}',
                    style: TextStyle(
                      fontSize: 28,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Weight ${_weight}',
                    style: TextStyle(
                      fontSize: 28,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Risk ${_risk}',
                    style: TextStyle(
                      fontSize: 28,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FlatButton(
                    onPressed: loadData,
                    child: Text('Try Firebase'),
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
