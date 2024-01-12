import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/app_user.dart';

import 'screens/nav_wrapper.dart';

import 'services/auth.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(PreLauncher());
}

class PreLauncher extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RBAC',
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // MaterialApp provides the necessary Directionality context here
            return Center(
              // print the reason for the error in the console with small text
              child: Text('ERROR'),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (_) => AuthService(),
                ),
                StreamProvider<AppUser?>.value(
                  value: AuthService().appUser,
                  initialData: AppUser(uid: 'null', emailVerified: false),
                ),
              ],
              builder: (context, child) {
                return NavWrapper();
              },
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
