import 'package:flutter/material.dart';

class ContactPersonScreen extends StatefulWidget {
  static const routeName = '/contact-person';
  @override
  _ContactPersonScreenState createState() => _ContactPersonScreenState();
}

class _ContactPersonScreenState extends State<ContactPersonScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Person'),
      ),
      backgroundColor: Colors.lightBlueAccent,
      body: Center(
        child: Text('contact'),
      ),
    );
  }
}
