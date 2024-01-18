import 'package:flutter/material.dart';

class TrainerProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
      ),
      body: Center(
        child: Text('Signed In. Role: Trainer'),
      ),
    );
  }
}
