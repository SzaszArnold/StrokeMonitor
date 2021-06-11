import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:strokemonitor/screens/auth_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:strokemonitor/screens/contact_person_screen.dart';
import 'package:strokemonitor/screens/main_screen.dart';
import 'package:strokemonitor/screens/profile_data_update_screen.dart';
import 'package:strokemonitor/screens/stroke_risk_screen.dart';
import 'package:strokemonitor/screens/profile_data_screen.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import 'package:strokemonitor/widgets/contact_person.dart';
import 'package:strokemonitor/widgets/profile_data_update.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterBackgroundService.initialize(onStart);
  runApp(MyApp());
}

//*---------
void onStart() {
  WidgetsFlutterBinding.ensureInitialized();
  final service = FlutterBackgroundService();
  service.onDataReceived.listen((event) {
    if (event["action"] == "setAsForeground") {
      service.setForegroundMode(true);
      return;
    }
  });
  service.setForegroundMode(true);
  Timer.periodic(Duration(seconds: 30), (timer) async {
    if (!(await service.isServiceRunning())) timer.cancel();
    service.setNotificationInfo(
      title: "Monitoring...",
      content:
          "Last updated at ${DateTime.now().hour}:${DateTime.now().minute}",
    );

    service.sendData(
      {"current_date": DateTime.now().toIso8601String()},
    );
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StrokeMonitor',
      theme: ThemeData(
        primaryColor: Color.fromRGBO(153, 42, 35, 1.0),
        accentColor: Color.fromRGBO(153, 42, 35, 1.0),
        accentColorBrightness: Brightness.dark,
        buttonTheme: ButtonTheme.of(context).copyWith(
          buttonColor: Color.fromRGBO(153, 42, 35, 1.0),
          textTheme: ButtonTextTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (ctx, userSnapshot) {
                if (userSnapshot.hasData) {
                  return MainScreen();
                } else {
                  return AuthScreen();
                }
              },
            ),
        StrokeRiskScreen.routeName: (contex) => StrokeRiskScreen(),
        ProfileDataScreen.routeName: (context) => ProfileDataScreen(),
        ContactPersonScreen.routeName: (context) => ContactPersonScreen(),
        ProfileDataUpdateScreen.routeName: (context) =>
            ProfileDataUpdateScreen(),
      },
    );
  }
}
