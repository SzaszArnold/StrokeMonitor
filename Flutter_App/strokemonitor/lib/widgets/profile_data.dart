import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: NetworkImage(
                                      'https://www.kindpng.com/picc/m/78-785827_user-profile-avatar-login-account-male-user-icon.png'),
                                  fit: BoxFit.fill),
                            ),
                          ),
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
                          ListTile(
                            leading: Icon(
                              Icons.height,
                              size: 26,
                              color: Color.fromRGBO(153, 42, 35, 1.0),
                            ),
                            title: Text(
                              'Height: ${documents['height']}',
                              style: TextStyle(
                                fontSize: 28,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.line_weight,
                              size: 26,
                              color: Color.fromRGBO(153, 42, 35, 1.0),
                            ),
                            title: Text(
                              'Weight: ${documents['weight']}',
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
