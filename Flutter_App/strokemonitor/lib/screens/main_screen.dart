import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 1,
        itemBuilder: (ctx, index) => Container(
          padding: EdgeInsets.all(8),
          child: Text('Works!'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          FirebaseFirestore.instance
              .collection('test/WmsaOuCowO8CkhRmzAkj/test')
              .snapshots()
              .listen((data) {
            data.docs.forEach((element) {
              print(element['text']);
            });
          });
        },
      ),
    );
  }
}
