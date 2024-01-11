import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fit_now/ui/screens/home/welcome.dart';
import 'package:fit_now/ui/screens/home/home.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class RootScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<auth.User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return new Container(
            color: Colors.white,
          );
        } else {
          if (snapshot.hasData) {
            return new MainScreen(
              firebaseUser: snapshot.data ?? auth.FirebaseAuth.instance.currentUser!,
            );
          } else {
            return WelcomeScreen();
          }
        }
      },
    );
  }
}