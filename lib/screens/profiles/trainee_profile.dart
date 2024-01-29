import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../models/app_user.dart';
import '../../models/profile.dart';
import '../../models/training_session.dart';
import '../../services/database.dart';


class TraineeProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the current user's UID
    final user = Provider.of<AppUser?>(context);

    // Create an instance of DatabaseService with the logged-in user's UID
    final DatabaseService databaseService = DatabaseService(
        uid: user!.uid,
        roleView: 'trainee'
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('My Training Sessions'),
      ),
      body: StreamBuilder<Profile>(
        stream: databaseService.profile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data != null) {
            final profile = snapshot.data!;
            return StreamBuilder<List<TrainingSession>>(
              stream: profile.trainingSessions, // Assuming this is a Stream<List<TrainingSession>>
              builder: (context, sessionSnapshot) {
                if (sessionSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (sessionSnapshot.hasError) {
                  return Center(child: Text('Error: ${sessionSnapshot.error}'));
                } else if (sessionSnapshot.hasData) {
                  if (sessionSnapshot.data!.isEmpty) {
                    return Center(child: Text('No Training Sessions Found'));
                  }
                  return ListView.builder(
                    itemCount: sessionSnapshot.data!.length,
                    itemBuilder: (context, index) {
                      TrainingSession session = sessionSnapshot.data![index];
                      return Card(
                        child: ListTile(
                          leading: Icon(Icons.fitness_center),
                          title: Text('Session ID: ${session.tid}'),
                          subtitle: Text('Sport: ${session.sport}'),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Show an additional tile in the row with the session details
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Container(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Session ID: ${session.tid}'),
                                      Text('Sport: ${session.sport}'),
                                      Text('Specialization: ${session.spec}'),
                                      Text('Start Time: ${session.startTime}'),
                                      Text('End Time: ${session.endTime}'),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: Text('No Training Sessions Available'));
                }
              },
            );
          } else {
            return Center(child: Text('No Profile Data Available'));
          }
        },
      ),
    );
  }
}
