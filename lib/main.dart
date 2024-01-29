import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/app_user.dart';
import 'screens/nav_wrapper.dart';
import 'services/auth.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(PreLauncher());
}

class PreLauncher extends StatefulWidget {
  @override
  _PreLauncherState createState() => _PreLauncherState();
}

class _PreLauncherState extends State<PreLauncher> {
  late final Future<FirebaseApp> _initialization;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    if (kIsWeb) {
      _initialization = Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyARiDEvk9IQibCX3wKmN6LuP5K7VGWxN88",
            authDomain: "fitnow-bfc20.firebaseapp.com",
            projectId: "fitnow-bfc20",
            storageBucket: "fitnow-bfc20.appspot.com",
            messagingSenderId: "440181801904",
            appId: "1:440181801904:web:7a3f597fd6ca8ffc4d4c75",
            measurementId: "G-91XQCMDGEM",
        ),
      );
    }
    else {
      _initialization = Firebase.initializeApp();
    }
  }

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
              // Print the reason for the error in the console with small text
              child: Text('ERROR: ${snapshot.error}'),
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
