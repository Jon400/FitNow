import 'package:fit_now/screens/profiles/trainer_profile.dart';
import 'package:fit_now/screens/trainer_button/planning_button.dart';
import 'package:flutter/material.dart';

import 'account/index.dart';
import 'profiles/trainee_profile.dart';
import 'trainer_button/ActivityTime_button.dart';
import 'trainer_button/request_button.dart';

class TrainerWrapper extends StatefulWidget {
  @override
  _TrainerWrapperState createState() => _TrainerWrapperState();
}

class _TrainerWrapperState extends State<TrainerWrapper> {
  int _selectedPage = 0;
  final _pageOptions = [
    TrainerProfileScreen(),
    ActivityTimeButton(),
    planning_button(),
    request_button(),
    AccountScreen(),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: _pageOptions[_selectedPage],
      bottomNavigationBar: Container( // Added container widget
        margin: EdgeInsets.symmetric(horizontal: 10), // Added horizontal margin
        padding: EdgeInsets.symmetric(horizontal: 10), // Added horizontal padding
        decoration: const BoxDecoration( // Added decoration
          color: Colors.black, // Set background color to black
          borderRadius: BorderRadius.all(Radius.circular(25)), // Set border radius

        ),
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
              icon: Icon(Icons.access_time),
              label: 'Work-Time',
              activeIcon: Icon(Icons.access_time, color: Colors.blue), // Active icon color set to blue
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Planning',
              activeIcon: Icon(Icons.calendar_today, color: Colors.blue), // Active icon color set to blue
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.request_page),
              label: 'Requests',
              activeIcon: Icon(Icons.request_page, color: Colors.blue), // Active icon color set to blue
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
