import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ContactPerson extends StatefulWidget {
  @override
  _ContactPersonState createState() => _ContactPersonState();
}

class _ContactPersonState extends State<ContactPerson> {
  final _formKey = GlobalKey<FormState>();
  String _name = "";
  String _phone = "";
  final _auth = FirebaseAuth.instance;

  void _trySave() {
    FirebaseFirestore.instance
        .collection('usersContact')
        .doc(_auth.currentUser.email)
        .set({
      'name': _name,
      'phone': _phone,
    });
  }

  @override
  Widget build(BuildContext context) {
    String currentPhone = "Not yet!";
    String currentName = "Not yet!";
    FirebaseFirestore.instance
        .collection('usersContact')
        .doc(_auth.currentUser.email)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print(documentSnapshot.data().entries.last.value);
        currentName = documentSnapshot.data().entries.last.value;
        currentPhone = documentSnapshot.data().entries.first.value;
      }
    });

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
                  Container(
                    child: Column(
                      children: [
                        Text(
                          'Current Contact Name : $currentName ',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          'Current Contact Number: $currentPhone',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                      setState(() {
                        _phone = value;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.save),
                    onPressed: () {
                      print(_phone);
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
