import 'package:flutter/material.dart';
import 'package:strokemonitor/widgets/profile_data_update.dart';

class ProfileDataUpdateScreen extends StatefulWidget {
  static const routeName = '/profile-data-update';
  @override
  _ProfileDataUpdateScreenState createState() =>
      _ProfileDataUpdateScreenState();
}

class _ProfileDataUpdateScreenState extends State<ProfileDataUpdateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Update'),
      ),
      backgroundColor: Color.fromRGBO(247, 137, 137, 1),
      body: ProfileDataUpdate(),
    );
  }
}
