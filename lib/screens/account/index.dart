import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../services/auth.dart';
import '../auth/authenticate.dart';
import '../../widgets/button.dart'; // Updated import to use the custom button widget

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView( // Wrap the Column with SingleChildScrollView
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Updated larger image with increased space
              SizedBox(
                height: 400,
                width: 500,
                child: Image.asset(
                  'assets/images/fitnow.png',
                  fit: BoxFit.contain, // Adjust the fit as needed
                ),
              ),

              SizedBox(height: 60), // Increased spacing to avoid overlap with the text

              Text(
                user == null ? 'Welcome to FitNow!' : 'Goodbye!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: user == null ? Color(0xFF454545) : Colors.red,
                ),
              ),

              SizedBox(height: 20),

              Button(
                onTap: user == null
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Authenticate()),
                  );
                }
                    : () {
                  Provider.of<AuthService>(context, listen: false).signOut();
                },
                text: user == null ? 'Sign In or Sign Up' : 'Sign Out',
                color: Color(0xFFE2C799),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
