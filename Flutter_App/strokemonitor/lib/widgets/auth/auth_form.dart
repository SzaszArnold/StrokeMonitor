import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  AuthForm(this.submitFunction, this.isLoading);
  final bool isLoading;
  final void Function(
    String email,
    String password,
    String birthday,
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
  String _userBirthDay = '';
  String _userGender = '';
  String _userHeight = '';
  String _userWeight = '';

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
                          key: ValueKey('birthday'),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a valid date.';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.datetime,
                          decoration: InputDecoration(
                            labelText: 'Birthday',
                          ),
                          onSaved: (value) {
                            _userBirthDay = value;
                          },
                        ),
                        TextFormField(
                          key: ValueKey('gender'),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a valid gender.';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.datetime,
                          decoration: InputDecoration(
                            labelText: 'Gender',
                          ),
                          onSaved: (value) {
                            _userGender = value;
                          },
                        ),
                        TextFormField(
                          key: ValueKey('height'),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a valid height.';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.datetime,
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
                          keyboardType: TextInputType.datetime,
                          decoration: InputDecoration(
                            labelText: 'Weight',
                          ),
                          onSaved: (value) {
                            _userWeight = value;
                          },
                        ),
                      ],
                    ),
                  SizedBox(height: 12),
                  if (widget.isLoading) CircularProgressIndicator(),
                  if (!widget.isLoading)
                    RaisedButton(
                      child: Text(_isLogin ? 'Login' : 'Signup'),
                      onPressed: _trySubmit,
                    ),
                  if (!widget.isLoading)
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
