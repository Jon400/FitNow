import 'package:fit_now/screens/profiles/trainer_profile.dart';
import 'package:flutter/material.dart';

import '../account/index.dart';


class request_button extends StatefulWidget {
  @override
  _request_button createState() => _request_button();
}

class _request_button extends State<request_button> {
  int _selectedPage = 0;
  final _pageOptions = [
    TrainerProfileScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Requests from trainees'),
      ),
    );
  }
}