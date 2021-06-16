import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileData extends StatefulWidget {
  @override
  _ProfileDataState createState() => _ProfileDataState();
}

class _ProfileDataState extends State<ProfileData> {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Form(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('userImg')
                        .doc(_auth.currentUser.email.substring(
                            0, _auth.currentUser.email.lastIndexOf('@')))
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final documents = snapshot.data;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                              width: 200,
                              height: 250,
                              child: Image.file(
                                File('${documents['img']}'),
                                fit: BoxFit.fill,
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              )),
                        ],
                      );
                    },
                  ),
                ),
                Form(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(_auth.currentUser.email.substring(
                            0, _auth.currentUser.email.lastIndexOf('@')))
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final documents = snapshot.data;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(
                              Icons.person,
                              size: 26,
                              color: Color.fromRGBO(153, 42, 35, 1.0),
                            ),
                            title: Text(
                              '${_auth.currentUser.email.substring(0, _auth.currentUser.email.lastIndexOf('@'))}',
                              style: TextStyle(
                                fontSize: 28,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.cake_outlined,
                              size: 26,
                              color: Color.fromRGBO(153, 42, 35, 1.0),
                            ),
                            title: Text(
                              '${documents['birthday']}',
                              style: TextStyle(
                                fontSize: 28,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Height: ${documents['height']}',
                                  style: TextStyle(
                                    fontSize: 28,
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Weight: ${documents['weight']}',
                                  style: TextStyle(
                                    fontSize: 28,
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.fitness_center,
                              size: 26,
                              color: Color.fromRGBO(153, 42, 35, 1.0),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  'BMI: ${(int.parse(documents['height']) / int.parse(documents['weight']) * 10).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 28,
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.help_outline_outlined,
                                    size: 26,
                                    color: Color.fromRGBO(153, 42, 35, 1.0),
                                  ),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                              title: Text('BMI Value'),
                                              content: Text(
                                                  'Below 18.5 --- Underweight\n' +
                                                      "18.5 - 24.9 --- Normal \n" +
                                                      "25.0 - 29.0 --- Owerweight\n" +
                                                      "30.0 and Above --- Obese"),
                                            ));
                                  },
                                )
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Form(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('risk')
                        .doc(_auth.currentUser.email.substring(
                            0, _auth.currentUser.email.lastIndexOf('@')))
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final documents = snapshot.data;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(
                              Icons.warning_amber_outlined,
                              size: 26,
                              color: Color.fromRGBO(153, 42, 35, 1.0),
                            ),
                            title: Text(
                              '${documents['percentage']}',
                              style: TextStyle(
                                fontSize: 28,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
