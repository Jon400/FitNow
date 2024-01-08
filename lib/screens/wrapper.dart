import 'package:flutter/material.dart';
import 'package:fit_now/screens/authenticate/sign_in.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key, required this.onSignOut}) : super(key: key);

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return SignIn(onSignIn: () {  },);
  }
}