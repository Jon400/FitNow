import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../services/auth.dart';
import '../auth/authenticate.dart';
import '../../widgets/button.dart';

// Updated import to use the custom button widget

class AccountScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<AppUser?>(context);

    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/screen.png'),
          fit: BoxFit.cover,
        ),

      ),

      child: Scaffold(

        backgroundColor: Colors.transparent,

        body: Column(

          children: [
            SizedBox(height: 260),

            Text(
              user == null ? 'Welcome to FitNow!' : 'Do you want to sign out?',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 300),
            Button(
              onTap: user == null
                  ? () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Authenticate()
                    )
                );
              }
                  : () {
                Provider.of<AuthService>(context, listen: false).signOut();
              },
              text: user == null ? 'Get started' : 'Sign Out',
              color: Colors.amber,
            ),
          ],
        ),
      ),
    );

  }

}