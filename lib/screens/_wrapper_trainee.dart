import 'package:fit_now/screens/search/notifications.dart';
import 'package:fit_now/screens/search/search_training.dart';
import 'package:flutter/material.dart';

import 'account/index.dart';
import 'profiles/trainee_profile.dart';

class TraineeWrapper extends StatefulWidget {
  @override
  _TraineeWrapperState createState() => _TraineeWrapperState();
}

class _TraineeWrapperState extends State<TraineeWrapper> {
  int _selectedPage = 0;
  final _pageOptions = [
    TraineeProfileScreen(),
    TraineeSearchPage(),
    NotificationsPage(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: Colors.black,
      body: _pageOptions[_selectedPage],
      bottomNavigationBar: Container( // Added container widget
        //margin: EdgeInsets.symmetric(horizontal: 16), // Added horizontal margin
        //padding: EdgeInsets.symmetric(horizontal: 10), // Added horizontal padding

        child: BottomNavigationBar(
          currentIndex: _selectedPage,
          backgroundColor: Colors.transparent, // Changed background color to transparent
          selectedItemColor: Colors.lightBlue[900], // Selected item color set to blue
          unselectedItemColor: Colors.white54, // Unselected item color set to white54 for visibility
          selectedIconTheme: IconThemeData(color: Colors.lightBlue[900]), // Selected icon color set to blue
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
              activeIcon: Icon(Icons.home, color: Colors.lightBlue[900]), // Active icon color set to blue
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              label: 'Search',
              activeIcon: Icon(Icons.search_rounded, color: Colors.lightBlue[900]), // Active icon color set to blue
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notifications',
              activeIcon: Icon(Icons.notifications, color: Colors.lightBlue[900]), // Active icon color set to blue
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_box),
              label: 'Account',
              activeIcon: Icon(Icons.account_box, color: Colors.lightBlue[900]), // Active icon color set to blue
            ),

          ],

        ),
      ),
    );
  }
}
