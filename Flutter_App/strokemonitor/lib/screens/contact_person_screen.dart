import 'package:flutter/material.dart';
import 'package:strokemonitor/widgets/contact_person.dart';

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
      backgroundColor: Color.fromRGBO(247, 137, 137, 1),
      body: Center(
        child: ContactPerson(),
      ),
    );
  }
}
