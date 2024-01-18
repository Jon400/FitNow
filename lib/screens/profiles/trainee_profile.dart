import 'package:flutter/material.dart';

class TraineeProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Trainning Sessions'),
      ),
      body: Center(
        child: Text('Signed In. Role: Trainee'),
      ),
    );
  }
}
