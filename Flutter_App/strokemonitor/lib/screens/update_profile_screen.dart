import 'package:flutter/material.dart';

class UpdateProfileScreen extends StatefulWidget {
  static const routeName = '/update-profile';
  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update profile'),
      ),
      backgroundColor: Color.fromRGBO(247, 137, 137, 1),
      body: Center(
        child: Text('profile update'),
      ),
    );
  }
}
