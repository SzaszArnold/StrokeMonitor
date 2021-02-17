import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:strokemonitor/screens/auth_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:strokemonitor/screens/chart_screen.dart';
import 'package:strokemonitor/screens/main_screen.dart';
import 'package:strokemonitor/screens/stroke_risk_screen.dart';
import 'package:strokemonitor/widgets/stroke_risk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StrokeMonitor',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        accentColor: Colors.blueAccent,
        accentColorBrightness: Brightness.dark,
        buttonTheme: ButtonTheme.of(context).copyWith(
          buttonColor: Colors.blue,
          textTheme: ButtonTextTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: StrokeRiskScreen(),
      /* StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, userSnapshot) {
          if (userSnapshot.hasData) {
            return MainScreen();
          } else {
            return AuthScreen();
          }
        },
      ),*/
    );
  }
}
