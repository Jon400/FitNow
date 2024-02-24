import '../../extensions/validate_email.dart';
import '../../services/auth.dart';
import '../../services/auth_exception.dart';
import '../../widgets/loading.dart';
import 'package:flutter/material.dart';

import 'reset_password.dart';

class SignInWrapper extends StatelessWidget {
  final Function toggleView;
  SignInWrapper({required this.toggleView});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 434,
            height: 939,

            child: SignIn(toggleView),
          ),
        ),
      ),
    );
  }
}

class SignIn extends StatefulWidget {
  final Function toggleView;
  SignIn(this.toggleView);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/login.png'),
          fit: BoxFit.contain,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Text(
                "Welcome Back!",
                style: TextStyle(
                  fontSize: 33.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 50.0),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      autofillHints: [AutofillHints.email],
                      decoration: InputDecoration(
                        hintText: 'Email',
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) =>
                      val!.isValidEmail() ? null : "Check your email",
                      onChanged: (val) {
                        setState(() => email = val);
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Password',
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      obscureText: true,
                      validator: (val) =>
                      val!.length < 6 ? '6 or more characters' : null,
                      onChanged: (val) {
                        setState(() => password = val);
                      },
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return ResetPassword();
                                },
                                fullscreenDialog: true,
                              ),
                            );
                          },
                        ),
                        ElevatedButton(
                          child: Text(
                            'Sign In',
                            style: TextStyle(color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:Colors.lightBlue[900]
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => loading = true);
                              try {
                                dynamic status =
                                await _auth.signInWithEmailAndPassword(
                                  email: email,
                                  password: password,
                                );
                                if (status != AuthResultStatus.successful) {
                                  setState(() => loading = false);
                                  final errorMsg = AuthExceptionHandler
                                      .generateExceptionMessage(status);
                                  _showAlertDialog(errorMsg);
                                }
                                Navigator.pop(context);
                              } catch (e) {
                                setState(() => loading = false);
                                _showAlertDialog(
                                    "There is no user record corresponding to this identifier. The user may have been deleted.");
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    Text(error),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 32.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account?',
                    style: TextStyle(fontSize: 15 ,fontWeight: FontWeight.bold)
                  ),
                  TextButton(
                    onPressed: () {
                      widget.toggleView();
                    },
                    child: Text(
                      'Join Us - it\'s Free',
                      style: TextStyle(fontSize: 15 , fontWeight: FontWeight.bold)

                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showAlertDialog(errorMsg) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Sign In Failed',
            style: TextStyle(color: Colors.black),
          ),
          content: Text(errorMsg),
        );
      },
    );
  }
}
