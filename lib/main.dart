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

class PreLauncher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeFirebase(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            home: Center(child: Text('ERROR: ${snapshot.error}')),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }

        return MaterialApp(
          home: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Future<FirebaseApp> _initializeFirebase() async {
    if (kIsWeb) {
      return await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: "AIzaSyARiDEvk9IQibCX3wKmN6LuP5K7VGWxN88",
          authDomain: "fitnow-bfc20.firebaseapp.com",
          projectId: "fitnow-bfc20",
          storageBucket: "fitnow-bfc20.appspot.com",
          messagingSenderId: "440181801904",
          appId: "1:440181801904:web:7a3f597fd6ca8ffc4d4c75",
          measurementId: "G-91XQCMDGEM",
        ),
      );
    } else {
      return await Firebase.initializeApp();
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        StreamProvider<AppUser?>.value(
          value: AuthService().appUser,
          initialData: AppUser(uid: 'null', emailVerified: false),
        ),
      ],
      child: MaterialApp(
        title: 'FitNow',
        debugShowCheckedModeBanner: false,
        home: NavWrapper(),

      ),
    );
  }
}