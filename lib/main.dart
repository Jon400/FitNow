import 'package:flutter/material.dart';
import 'package:fit_now/ui/screens/home/root.dart';
import 'package:fit_now/ui/screens/authenticate/sign_in.dart';
import 'package:fit_now/ui/screens/authenticate/sign_up.dart';
import 'package:fit_now/ui/screens/home/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

void main() async{
  FirebaseFirestore.instance.settings;
  SharedPreferences.getInstance().then((prefs) {
    runApp(MyApp(prefs: prefs));
  });
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  MyApp({required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forest Village GT',
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        '/root': (BuildContext context) => new RootScreen(),
        '/signin': (BuildContext context) => new SignInScreen(),
        '/signup': (BuildContext context) => new SignUpScreen(),
        '/main': (BuildContext context) => new MainScreen(firebaseUser: auth.FirebaseAuth.instance.currentUser!),
      },
      theme: ThemeData(
        primaryColor: Colors.white,
        primarySwatch: Colors.grey,
      ),
      home: _handleCurrentScreen(),
    );
  }

  Widget _handleCurrentScreen() {
    bool seen = (prefs.getBool('seen') ?? false);
    if (seen) {
      return new RootScreen();
    } else {
      return RootScreen();
    }
  }
}