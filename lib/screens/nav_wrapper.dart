import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../services/auth.dart';

import '_wrapper_trainer.dart';
import '_wrapper_home.dart';
import '_wrapper_trainee.dart';

class NavWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);
    if (user == null) {
      return HomeWrapper();
    } else {
      return BaseWrapper();
    }
  }
}

class BaseWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _getRole() async {
      final token = await Provider.of<AuthService>(context).claims;
      final String roleClaim = token?['roleView'];
      final String role = roleClaim ?? 'trainee';
      return role;
    }

    return Consumer<AuthService>(
      builder: (context, auth, child) {
        return FutureBuilder(
          future: _getRole(),
          builder: (context, snapshot) {
            switch (snapshot.data) {
              case 'trainee':
                return TraineeWrapper();
                break;
              case 'trainer':
                return TrainerWrapper();
                break;
              default:
                return TraineeWrapper();
                break;
            }
          },
        );
      },
    );
  }
}
