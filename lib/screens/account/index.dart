import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../services/auth.dart';

import '../auth/authenticate.dart';

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FitNow Home'),
      ),
      body: Column(
        children: [
          // Add your logo image here
          Image.asset(
            'assets/images/logo.jpg',
            height: 500, // Adjust the height as needed
            width: 500, // Adjust the width as needed
          ),
          Expanded(
            child: ListView(
              children: ListTile.divideTiles(
                context: context,
                tiles: [
                  signInSignOutTile(context),
                ],
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }

  signInSignOutTile(context) {
    final user = Provider.of<AppUser?>(context);
    final AuthService _auth = AuthService();

    if (user == null) {
      return ListTile(
        title:  const Text(
          ' Sign In or Sign Up',
          style: TextStyle(
            fontSize: 20,

          ),
        ),
        leading: Icon(Icons.login),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Authenticate()),
          );
        },
      );
    } else {
      return ListTile(
        leading: Icon(Icons.logout),
        title: Text(
          'Sign Out',
        ),
        onTap: () async {
          await _auth.signOut();
        },
      );
    }
  }
}

