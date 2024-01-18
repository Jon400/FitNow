import 'package:fit_now/screens/profiles/trainer_profile.dart';
import 'package:flutter/material.dart';

import 'account/index.dart';
import 'profiles/trainee_profile.dart';

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
      body: _pageOptions[_selectedPage],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPage,
        showUnselectedLabels: false,
        onTap: (int index) {
          setState(() {
            _selectedPage = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
