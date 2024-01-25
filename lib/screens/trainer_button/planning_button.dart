import 'package:fit_now/screens/profiles/trainer_profile.dart';
import 'package:flutter/material.dart';

import '../account/index.dart';


class planning_button extends StatefulWidget {
  @override
  _planning_button createState() => _planning_button();
}

class _planning_button extends State<planning_button> {
  int _selectedPage = 0;
  final _pageOptions = [
    TrainerProfileScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Planning'),
      ),
    );
  }
}
