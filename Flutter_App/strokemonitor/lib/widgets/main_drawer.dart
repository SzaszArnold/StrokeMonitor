import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/*Based on the documentation at the link: https://flutter.dev/docs/development/ui/widgets/material
                                          https://firebase.flutter.dev/docs/auth/usage/
                                          https://flutter.dev/docs/cookbook/design/drawer
*/

class MainDrawer extends StatelessWidget {
  Widget buildListTile(String title, IconData icon, Function tapHandler) {
    return ListTile(
      leading: Icon(
        icon,
        size: 26,
        color: Color.fromRGBO(153, 42, 35, 1.0),
      ),
      title: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(250, 232, 230, 1.0),
        ),
        child: Text(
          title,
          key: ValueKey('nav$title'),
          style: TextStyle(
            fontFamily: 'RobotoCondensed',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onTap: tapHandler,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      key: ValueKey('drawer'),
      child: Column(
        children: <Widget>[
          Container(
            height: 120,
            width: double.infinity,
            padding: EdgeInsets.all(20),
            alignment: Alignment.centerLeft,
            color: Theme.of(context).accentColor,
            child: ListTile(
              title: Text(
                'Profile',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 30,
                    color: Colors.black),
              ),
              subtitle: Text(
                'Hi ${FirebaseAuth.instance.currentUser.email.substring(0, FirebaseAuth.instance.currentUser.email.lastIndexOf('@'))}',
                style: TextStyle(fontSize: 24, color: Colors.black),
                key: ValueKey('userText'),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          buildListTile('Profile data', Icons.person, () {
            Navigator.of(context).pushNamed('/profile-data');
          }),
          buildListTile('Contact person', Icons.contact_phone, () {
            Navigator.of(context).pushNamed('/contact-person');
          }),
          buildListTile('Risk', Icons.warning, () {
            Navigator.of(context).pushNamed('/risk');
          }),
          ListTile(
            leading: Icon(
              Icons.logout,
              size: 26,
              color: Color.fromRGBO(153, 42, 35, 1.0),
            ),
            title: Container(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(250, 232, 230, 1.0),
              ),
              child: Text(
                'Log out',
                style: TextStyle(
                  fontFamily: 'RobotoCondensed',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}
