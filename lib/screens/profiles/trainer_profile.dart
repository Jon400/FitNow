import 'package:fit_now/screens/trainer_button/planning_button.dart';
import 'package:flutter/material.dart';

import '../trainer_button/ActivityTime_button.dart';
import '../trainer_button/request_button.dart';

class TrainerProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Signed In. Role: Trainer'),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.amber)
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(pageBuilder: (_, __, ___) => planning_button()
                  )
                );
              },
              child: Text("Planning"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.amber)
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        PageRouteBuilder(pageBuilder: (_, __, ___) => request_button()
                        )
                    );
                  },
                  child: Text("Requests"),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.amber)
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        PageRouteBuilder(pageBuilder: (_, __, ___) => ActivityTimeButton()
                        )
                    );
                  },
                  child: Text("Activity Time"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
