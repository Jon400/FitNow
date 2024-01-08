import 'package:flutter/material.dart';

// for sign in with Email and Password
class SignIn extends StatelessWidget {
  const SignIn({Key? key, required this.onSignIn}) : super(key: key);

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: onSignIn,
          child: const Text('Sign In'),
        ),
      ),
    );
  }
}
