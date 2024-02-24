import 'package:flutter/material.dart';

import '../../extensions/validate_email.dart';
import '../../services/auth.dart';
import '../../services/auth_exception.dart';
import '../../widgets/loading.dart';

enum Role { trainee, trainer }

class SignUpWrapper extends StatelessWidget {
  final Function toggleView;
  SignUpWrapper({required this.toggleView});

  @override
  Widget build(BuildContext context) {
     return Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: 437, height: 926,
              child: SignUp(toggleView),
            ),
          ),
        ),
      );
    }
  }


class SignUp extends StatefulWidget {
  final Function toggleView;
  SignUp(this.toggleView);
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  String email = '';
  String password = '';
  String error = '';
  String firstName = '';
  String lastName = '';
  String role = '';

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/register.png'),
          fit: BoxFit.cover,
        ),
      ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 80),
                  child: Text('Create your Account',
                       style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        )),
                ),
                const SizedBox(height: 50.0),
                Form(
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
                            borderRadius: BorderRadius.circular(8.0),
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
                            borderRadius: BorderRadius.circular(8.0),
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
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'First / Given Name',
                          fillColor: Colors.grey.shade100,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        validator: (val) =>
                            val!.length < 2 ? 'We need this for your Reservations' : null,
                        onChanged: (val) {
                          setState(() => firstName = val);
                        },
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Last Name or Initial',
                          fillColor: Colors.grey.shade100,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        validator: (val) =>
                            val!.length < 1 ? 'Don\'t be shy!' : null,
                        onChanged: (val) {
                          setState(() => lastName = val);
                        },
                      ),
                      // adding here a drop down menu for role with two
                      // choices: trainee and trainer
                      SizedBox(height: 20.0),
                      DropdownButtonFormField(
                        decoration: InputDecoration(
                          hintText: 'Role',
                          fillColor: Colors.grey.shade100,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        value: Role.trainee.name, // default value
                        items: [
                          DropdownMenuItem(
                            child: Text("Trainee"),
                            value: Role.trainee.name,
                          ),
                          DropdownMenuItem(
                            child: Text("Trainer"),
                            value: Role.trainer.name,
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            role = value.toString();
                          });
                        },
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              widget.toggleView();
                            },
                            child: Text(
                              'Sign in instead',

                            ),
                          ),
                          ElevatedButton(
                              child: Text(
                                'Continue',
                                style: TextStyle(color: Colors.black),
                              ),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightBlue[900],
                              ),
                             onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() => loading = true);
                                  dynamic status =
                                      await _auth.registerWithEmail(
                                        email: email,
                                        password: password,
                                        firstName: firstName,
                                        lastName: lastName,
                                        roleView: role,
                                  );
                                  if (status != AuthResultStatus.successful) {
                                    setState(() => loading = false);
                                    final errorMsg = AuthExceptionHandler
                                        .generateExceptionMessage(status);
                                    _showAlertDialog(errorMsg);
                                  } else {
                                    Navigator.popUntil(
                                        context, (route) => route.isFirst);
                                    // setState(() => loading = false);
                                  }
                                }
                              }),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  _showAlertDialog(errorMsg) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Registration Failed',
              style: TextStyle(color: Colors.black),
            ),
            content: Text(errorMsg),
          );
        });
  }
}
