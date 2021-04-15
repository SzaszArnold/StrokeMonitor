import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:strokemonitor/widgets/auth/auth_form.dart';
import 'package:intl/intl.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;
  void _submitAuthForm(
    String email,
    String password,
    DateTime birthday,
    String gender,
    String height,
    String weight,
    bool isLogin,
  ) async {
    UserCredential authResult;
    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser.email
              .substring(0, _auth.currentUser.email.lastIndexOf('@')))
          .set({
        'birthday': DateFormat.yMd().format(birthday),
        'gender': gender,
        'height': height,
        'weight': weight,
      });
      FirebaseFirestore.instance
          .collection('risk')
          .doc(_auth.currentUser.email
              .substring(0, _auth.currentUser.email.lastIndexOf('@')))
          .set({
        'percentage': "",
        'score': 0,
      });
      FirebaseFirestore.instance
          .collection('usersContact')
          .doc(_auth.currentUser.email
              .substring(0, _auth.currentUser.email.lastIndexOf('@')))
          .set({
        'name': "Ambulance",
        'phone': 112,
      });
    } on PlatformException catch (err) {
      var message = 'An error occured, please check your credentials!';
      if (err.message != null) {
        message = err.message;
      }
      Text(message);
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("StrokeMonitor"),
      ),
      backgroundColor: Color.fromRGBO(212, 125, 119, 1.0),
      body: AuthForm(
        _submitAuthForm,
        _isLoading,
      ),
    );
  }
}
