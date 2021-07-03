import 'package:flutter/material.dart';
import 'package:strokemonitor/widgets/profile_data.dart';

class ProfileDataScreen extends StatefulWidget {
  static const routeName = '/profile-data';
  @override
  _ProfileDataScreenState createState() => _ProfileDataScreenState();
}

/*Based on the documentation at the link: https://flutter.dev/docs/cookbook/navigation/named-routes */
class _ProfileDataScreenState extends State<ProfileDataScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile data'),
        actions: [
          IconButton(
            icon: const Icon(Icons.update),
            tooltip: 'Update',
            onPressed: () {
              Navigator.of(context).pushNamed('/profile-data-update');
            },
          ),
        ],
      ),
      backgroundColor: Color.fromRGBO(250, 232, 230, 1.0),
      body: ProfileData(),
    );
  }
}
