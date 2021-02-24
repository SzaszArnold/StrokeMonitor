import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';

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
  final _auth = FirebaseAuth.instance;

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

  void loadData() {
    FirebaseFirestore.instance
        .collection('usersContact')
        .doc(_auth.currentUser.email)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        currentName = documentSnapshot.data().entries.last.value.toString();
        currentPhone = documentSnapshot.data().entries.first.value.toString();
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
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final documents = snapshot.data;
                        return Container(
                          child: Column(
                            children: [
                              Text(
                                'Current Contact Name : ${documents['name']} ',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Text(
                                'Current Contact Number: ${documents['phone']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 20,
                                ),
                              ),
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
                      if (value.isEmpty || value.length < 8) {
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
                    icon: Icon(Icons.save),
                    onPressed: () {
                      _trySave();
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
