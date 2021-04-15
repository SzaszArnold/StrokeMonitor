import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AuthForm extends StatefulWidget {
  AuthForm(this.submitFunction, this.isLoading);
  final bool isLoading;
  final void Function(
    String email,
    String password,
    DateTime birthday,
    String gender,
    String height,
    String weight,
    bool isLogin,
  ) submitFunction;

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  String _userEmail = '';
  String _userPassword = '';
  DateTime _userBirthDay;
  String _userGender = '';
  String _userHeight = '';
  String _userWeight = '';
  String select;
  final List<String> genderList = ["Male", "Female"];
  Map<int, String> mappedGender = ["Male", "Female"].asMap();
  void _trySubmit() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      _formKey.currentState.save();
      widget.submitFunction(
        _userEmail,
        _userPassword,
        _userBirthDay,
        _userGender,
        _userHeight,
        _userWeight,
        _isLogin,
      );
    }
  }

  void _pressentDataPicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1800),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.red,
            accentColor: Colors.red,
          ),
          child: child,
        );
      },
    ).then(
      (pickedDate) {
        if (pickedDate == null) {
          return;
        }
        setState(() {
          _userBirthDay = pickedDate;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    key: ValueKey('email'),
                    validator: (value) {
                      if (value.isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email address.';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email address',
                    ),
                    onSaved: (value) {
                      _userEmail = value;
                    },
                  ),
                  TextFormField(
                    key: ValueKey('password'),
                    validator: (value) {
                      if (value.isEmpty || value.length < 8) {
                        return 'Password must be at least 8 characters long.';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                    ),
                    obscureText: true,
                    onSaved: (value) {
                      _userPassword = value;
                    },
                  ),
                  if (!_isLogin)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextFormField(
                          key: ValueKey('height'),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a valid height.';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Height',
                          ),
                          onSaved: (value) {
                            _userHeight = value;
                          },
                        ),
                        TextFormField(
                          key: ValueKey('weight'),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a valid weight.';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Weight',
                          ),
                          onSaved: (value) {
                            _userWeight = value;
                          },
                        ),
                        StatefulBuilder(
                          builder: (_, StateSetter setState) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Gender : ',
                                style: TextStyle(fontWeight: FontWeight.w400),
                              ),
                              ...mappedGender.entries.map(
                                (MapEntry<int, String> mapEntry) => Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio(
                                      activeColor:
                                          Theme.of(context).primaryColor,
                                      groupValue: select,
                                      value: genderList[mapEntry.key],
                                      onChanged: (value) => setState(
                                        () {
                                          select = value;
                                          _userGender = value;
                                          print(_userGender);
                                        },
                                      ),
                                    ),
                                    Text(mapEntry.value)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          key: ValueKey('birthday'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment
                                .center, //Center Row contents horizontally,
                            crossAxisAlignment: CrossAxisAlignment
                                .center, //Center Row contents vertically,
                            children: <Widget>[
                              Text(
                                _userBirthDay == null
                                    ? 'No Birthdate Chosen!'
                                    : 'Birthdate: ' +
                                        DateFormat.yMd().format(_userBirthDay),
                              ),
                              FlatButton(
                                  onPressed: () {
                                    _pressentDataPicker();
                                  },
                                  child: Icon(
                                    Icons.calendar_today,
                                    color: Theme.of(context).primaryColor,
                                  ))
                            ],
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 12),
                  if (widget.isLoading) CircularProgressIndicator(),
                  if (!widget.isLoading)
                    RaisedButton(
                      key: Key('button'),
                      child: Text(_isLogin ? 'Login' : 'Signup'),
                      onPressed: _trySubmit,
                    ),
                  if (!widget.isLoading)
                    // ignore: deprecated_member_use
                    FlatButton(
                      textColor: Theme.of(context).primaryColor,
                      child: Text(_isLogin
                          ? 'Create new account'
                          : 'I already have an account'),
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
