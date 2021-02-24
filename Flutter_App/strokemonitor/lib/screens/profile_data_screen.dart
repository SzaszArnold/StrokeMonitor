import 'package:flutter/material.dart';
import 'package:strokemonitor/widgets/profile_data.dart';

class ProfileDataScreen extends StatefulWidget {
  static const routeName = '/profile-data';
  @override
  _ProfileDataScreenState createState() => _ProfileDataScreenState();
}

class _ProfileDataScreenState extends State<ProfileDataScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile data'),
      ),
      backgroundColor: Color.fromRGBO(247, 137, 137, 1),
      body: ProfileData(),
    );
  }
}
