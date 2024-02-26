import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/app_user.dart';
import '../../models/profile.dart';
import '../../models/training_session.dart';
import '../../services/database.dart';

class TraineeProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);
    final DatabaseService databaseService =
        DatabaseService(uid: user!.uid, roleView: 'trainee');

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: StreamBuilder<Profile>(
            stream: databaseService.profile,
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Loading...',
                        style: TextStyle(
                            fontSize: 20)), // Adjusted for consistency
                  ],
                );
              } else if (profileSnapshot.hasError) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Error: ${profileSnapshot.error}',
                        style: TextStyle(
                            fontSize: 20)), // Adjusted for consistency
                  ],
                );
              } else if (profileSnapshot.hasData) {
                final profile = profileSnapshot.data!;
                return Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // do bold
                      Text('Hi ${profile.firstName} ${profile.lastName}',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight:
                                  FontWeight.bold)), // Adjusted for consistency
                      // do a litle spacing
                      SizedBox(height: 3),
                    ],
                  ),
                );
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('No Profile Data Available',
                        style: TextStyle(
                            fontSize: 16)), // Adjusted for consistency
                  ],
                );
              }
            },
          ),
          bottom: TabBar(
            indicatorColor: Colors.lightBlue[900],
            labelColor: Colors.lightBlue[900],
            unselectedLabelColor: Colors.black,
            tabs: [
              Tab(text: 'Future Sessions'),
              Tab(text: 'Past Sessions'),
            ],
          ),
        ),
        body: StreamBuilder<Profile>(
          stream: databaseService.profile,
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (profileSnapshot.hasError) {
              return Center(child: Text('Error: ${profileSnapshot.error}'));
            } else if (profileSnapshot.hasData &&
                profileSnapshot.data != null) {
              final profile = profileSnapshot.data!;
              return TabBarView(
                children: [
                  _buildSessionList(context, profile, true),
                  _buildSessionList(context, profile, false),
                ],
              );
            } else {
              return Center(child: Text('No Profile Data Available'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildSessionList(
      BuildContext context, Profile profile, bool isFuture) {
    return StreamBuilder<List<TrainingSession>>(
      stream: profile.trainingSessions,
      builder: (context, sessionSnapshot) {
        if (sessionSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (sessionSnapshot.hasError) {
          return Center(child: Text('Error: ${sessionSnapshot.error}'));
        } else if (sessionSnapshot.hasData) {
          if (sessionSnapshot.data!.isEmpty) {
            return Center(
                child: Text('No Training Sessions Found',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)));
          }
          final now = DateTime.now();
          final sessions = sessionSnapshot.data!.where((session) {
            return isFuture
                ? session.startTime.isAfter(now)
                : session.startTime.isBefore(now);
          }).toList()
            ..sort((a, b) => isFuture
                ? a.startTime.compareTo(b.startTime)
                : b.startTime.compareTo(a.startTime));

          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              TrainingSession session = sessions[index];
              return _buildSessionItem(context, session);
            },
          );
        } else {
          return Center(child: Text('No Training Sessions Available'));
        }
      },
    );
  }

  Widget _buildSessionItem(BuildContext context, TrainingSession session) {
    final startTimeFormatted =
        DateFormat('MMM dd, yyyy - hh:mm a').format(session.startTime);
    final endTimeFormatted =
        DateFormat('MMM dd, yyyy - hh:mm a').format(session.endTime);
    bool isPending = session.status == "pending";

    return Opacity(
      opacity: isPending
          ? 0.5
          : 1.0, // Optionally reduce opacity for pending sessions
      child: Card(
        color: isPending
            ? Colors.grey.shade800
            : Colors.white, // Grey out pending sessions
        child: Stack(
          children: [
            ListTile(
              leading: Icon(Icons.fitness_center,
                  color: isPending ? Colors.grey : Colors.black),
              title: StreamBuilder<Profile>(
                stream: session.getTrainer(),
                builder: (context, trainerSnapshot) {
                  if (trainerSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Text('Loading...');
                  } else if (trainerSnapshot.hasError) {
                    return Text('Error: ${trainerSnapshot.error}');
                  } else if (trainerSnapshot.hasData) {
                    final trainer = trainerSnapshot.data!;
                    return Text(
                        'Trainer: ${trainer.firstName} ${trainer.lastName}',
                        style: TextStyle(
                            color: isPending ? Colors.grey : Colors.black));
                  } else {
                    return Text('No Trainer Data Available',
                        style: TextStyle(
                            color: isPending ? Colors.grey : Colors.black));
                  }
                },
              ),
              subtitle: Text(
                'Sport: ${session.sport} \nStart Time: $startTimeFormatted \nEnd Time: $endTimeFormatted',
                style: TextStyle(color: isPending ? Colors.grey : Colors.black),
              ),
              trailing: Icon(Icons.arrow_forward_ios,
                  color: isPending ? Colors.grey : Colors.black),
              onTap: () => _showSessionDetails(context, session),
            ),
            if (isPending)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: Colors.grey,
                  child: Text('PENDING',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSessionDetails(BuildContext context, TrainingSession session) {
    final startTimeFormatted =
        DateFormat('MMM dd, yyyy - hh:mm a').format(session.startTime);
    final endTimeFormatted =
        DateFormat('MMM dd, yyyy - hh:mm a').format(session.endTime);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<Profile>(
                stream: session.getTrainer(),
                builder: (context, trainerSnapshot) {
                  if (trainerSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Text('Loading...');
                  } else if (trainerSnapshot.hasError) {
                    return Text('Error: ${trainerSnapshot.error}');
                  } else if (trainerSnapshot.hasData) {
                    final trainer = trainerSnapshot.data!;
                    return Text(
                        'Trainer: ${trainer.firstName} ${trainer.lastName}');
                  } else {
                    return Text('No Trainer Data Available');
                  }
                },
              ),
              Text('Sport: ${session.sport}'),
              Text('Specialization: ${session.spec}'),
              Text('Start Time: $startTimeFormatted'),
              Text('End Time: $endTimeFormatted'),
              Text('Status: ${session.status}'),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop(); // This closes the dialog immediately.
                  _deleteTrainingSession(
                      context, session); // Then, call your delete function.
                },
                // do here a red pretty button
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                ),
                child: Text("Delete Training Session"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteTrainingSession(
      BuildContext context, TrainingSession session) async {
    // Show pop-up to confirm deletion
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Delete Training Session'),
          content:
              Text('Are you sure you want to delete this training session?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Dismiss the dialog and return false for cancellation
                Navigator.of(dialogContext).pop(false);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // close the dialog and return true for confirmation
                Navigator.of(dialogContext).pop(true);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    // If deletion is confirmed
    if (confirmDelete ?? false) {
      // The ?? false handles nulls, ensuring a boolean value.
      try {
        await session
            .deleteTrainingSession(); // Assuming this is an async operation
        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Training session successfully deleted."),
          backgroundColor: Colors.green,
        ));
      } catch (error) {
        // Handle errors, for example, showing an error message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to delete the training session."),
          backgroundColor: Colors.red,
        ));
      }
    }
  }
}
