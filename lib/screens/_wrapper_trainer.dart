import 'package:fit_now/screens/profiles/trainer_profile.dart';
import 'package:flutter/material.dart';
import 'account/index.dart';


class TrainerWrapper extends StatefulWidget {
  @override
  _TrainerWrapperState createState() => _TrainerWrapperState();
}

class _TrainerWrapperState extends State<TrainerWrapper> {
  int _selectedPage = 0;
  final _pageOptions = [
    TrainerProfileScreen(),

    AccountScreen(),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _pageOptions[_selectedPage],
      bottomNavigationBar: Container( // Added container widget
        //margin: EdgeInsets.symmetric(horizontal: 10), // Added horizontal margin
        //padding: EdgeInsets.symmetric(horizontal: 10), // Added horizontal padding

        child: BottomNavigationBar(
          currentIndex: _selectedPage,
          backgroundColor: Colors.transparent, // Changed background color to transparent
          selectedItemColor: Colors.blue, // Selected item color set to blue
          unselectedItemColor: Colors.white54, // Unselected item color set to white54 for visibility
          selectedIconTheme: IconThemeData(color: Colors.blue), // Selected icon color set to blue
          showSelectedLabels: true, // Show label for selected item
          showUnselectedLabels: false, // Hide label for unselected item
          onTap: (int index) {
            setState(() {
              _selectedPage = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
              activeIcon: Icon(Icons.home, color: Colors.blue), // Active icon color set to blue
            ),

          BottomNavigationBarItem(
              icon: Icon(Icons.account_box),
              label: 'Account',
              activeIcon: Icon(Icons.account_box, color: Colors.blue), // Active icon color set to blue
            ),

          ],
        ),
      ),
    );
  }
}
