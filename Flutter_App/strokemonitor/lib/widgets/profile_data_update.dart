import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileDataUpdate extends StatefulWidget {
  @override
  _ProfileDataUpdateState createState() => _ProfileDataUpdateState();
}

class _ProfileDataUpdateState extends State<ProfileDataUpdate> {
  final _auth = FirebaseAuth.instance;
  String _height;
  String _weight;
  String _birthday;
  String _gender;
  File imageFile;
  _getFromGallery() async {
    PickedFile pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  _getFromCamera() async {
    PickedFile pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  Future _trySavePic() async {
    FirebaseFirestore.instance
        .collection('userImg')
        .doc(_auth.currentUser.email
            .substring(0, _auth.currentUser.email.lastIndexOf('@')))
        .set({
      'img': imageFile.path,
    });
  }

  Future _trySaveData() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser.email
            .substring(0, _auth.currentUser.email.lastIndexOf('@')))
        .set({
      'birthday': _birthday,
      'gender': _gender,
      'height': _height,
      'weight': _weight,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Form(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(_auth.currentUser.email.substring(
                            0, _auth.currentUser.email.lastIndexOf('@')))
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final documents = snapshot.data;
                      _birthday = documents['birthday'];
                      _gender = documents['gender'];
                      _height = documents['height'];
                      _weight = documents['weight'];
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            child: imageFile != null
                                ? Container(
                                    width: 200,
                                    height: 200,
                                    child: Image.file(
                                      imageFile,
                                      fit: BoxFit.fill,
                                    ),
                                  )
                                : Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: NetworkImage(
                                              'https://www.kindpng.com/picc/m/78-785827_user-profile-avatar-login-account-male-user-icon.png'),
                                          fit: BoxFit.fill),
                                    ),
                                  ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                        style: ButtonStyle(
                                          foregroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Theme.of(context)
                                                      .primaryColor),
                                        ),
                                        onPressed: () {
                                          _getFromGallery();
                                        },
                                        child: Icon(Icons.photo)),
                                    TextButton(
                                      style: ButtonStyle(
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Theme.of(context).primaryColor),
                                      ),
                                      onPressed: () {
                                        _getFromCamera();
                                      },
                                      child: Icon(Icons.camera_alt),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Weight must be a value!';
                              }
                              return null;
                            },
                            initialValue: _weight,
                            decoration: InputDecoration(
                              labelText: 'Weight:',
                              labelStyle: TextStyle(
                                fontSize: 28,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            obscureText: false,
                            onChanged: (value) {
                              _weight = value;
                            },
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Height must be a value!';
                              }
                              return null;
                            },
                            initialValue: _height,
                            decoration: InputDecoration(
                              labelText: 'Height:',
                              labelStyle: TextStyle(
                                fontSize: 28,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            obscureText: false,
                            onChanged: (value) {
                              _height = value;
                            },
                          ),
                          TextButton(
                              style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Theme.of(context).primaryColor),
                              ),
                              onPressed: () {
                                print('Height: $_height');
                                _trySavePic();
                                _trySaveData();
                              },
                              child: Icon(Icons.save))
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
