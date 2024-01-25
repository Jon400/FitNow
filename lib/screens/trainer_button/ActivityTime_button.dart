import 'package:fit_now/screens/profiles/trainer_profile.dart';
import 'package:flutter/material.dart';

import '../account/index.dart';


class ActivityTime_button extends StatefulWidget {
  @override
  _ActivityTime_button createState() => _ActivityTime_button();
}

class _ActivityTime_button extends State<ActivityTime_button> {
  int _selectedPage = 0;
  final _pageOptions = [
    TrainerProfileScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setting of my activity time'),
      ),
    );
  }
}