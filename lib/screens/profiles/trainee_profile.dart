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
    final DatabaseService databaseService = DatabaseService(uid: user!.uid, roleView: 'trainee');

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          backgroundColor: Colors.grey[500],
          title: StreamBuilder<Profile>(
            stream: databaseService.profile,
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Loading...', style: TextStyle(fontSize: 20)), // Adjusted for consistency
                  ],
                );
              } else if (profileSnapshot.hasError) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Error: ${profileSnapshot.error}', style: TextStyle(fontSize: 20)), // Adjusted for consistency
                  ],
                );
              } else if (profileSnapshot.hasData) {
                final profile = profileSnapshot.data!;
                return Container(
                  color: Colors.amber,
                  child:Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // do bold
                    Text('Hi ${profile.firstName} ${profile.lastName}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), // Adjusted for consistency
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
                    Text('No Profile Data Available', style: TextStyle(fontSize: 16)), // Adjusted for consistency
                  ],
                );
              }
            },
          ),

          bottom: TabBar(
            indicatorColor:Colors.lightBlue[900],
            labelColor: Colors.lightBlue[900],

            unselectedLabelColor: Colors.black,
            tabs: [
              Tab(text: 'Future Sessions' ),
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
            } else if (profileSnapshot.hasData && profileSnapshot.data != null) {
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

  Widget _buildSessionList(BuildContext context, Profile profile, bool isFuture) {
    return StreamBuilder<List<TrainingSession>>(
      stream: profile.trainingSessions,
      builder: (context, sessionSnapshot) {
        if (sessionSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (sessionSnapshot.hasError) {
          return Center(child: Text('Error: ${sessionSnapshot.error}'));
        } else if (sessionSnapshot.hasData) {
          if (sessionSnapshot.data!.isEmpty) {
            return Center(child: Text('No Training Sessions Found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold , color: Colors.white)));
          }
          final now = DateTime.now();
          final sessions = sessionSnapshot.data!.where((session) {
            return isFuture ? session.startTime.isAfter(now) : session.startTime.isBefore(now);
          }).toList()
            ..sort((a, b) => isFuture ? a.startTime.compareTo(b.startTime) : b.startTime.compareTo(a.startTime));

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
    final startTimeFormatted = DateFormat('MMM dd, yyyy - hh:mm a').format(session.startTime);
    final endTimeFormatted = DateFormat('MMM dd, yyyy - hh:mm a').format(session.endTime);

    return Card(
      child: ListTile(
        leading: Icon(Icons.fitness_center),
        title: StreamBuilder<Profile>(
          stream: session.getTrainer(),
          builder: (context, trainerSnapshot) {
            if (trainerSnapshot.connectionState == ConnectionState.waiting) {
              return Text('Loading...');
            } else if (trainerSnapshot.hasError) {
              return Text('Error: ${trainerSnapshot.error}');
            } else if (trainerSnapshot.hasData) {
              final trainer = trainerSnapshot.data!;
              return Text('Trainer: ${trainer.firstName} ${trainer.lastName}');
            } else {
              return Text('No Trainer Data Available');
            }
          },
        ),
        subtitle: Text('Sport: ${session.sport} \nStart Time: $startTimeFormatted \nEnd Time: $endTimeFormatted'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () => _showSessionDetails(context, session),
      ),
    );
  }

  void _showSessionDetails(BuildContext context, TrainingSession session) {
    final startTimeFormatted = DateFormat('MMM dd, yyyy - hh:mm a').format(session.startTime);
    final endTimeFormatted = DateFormat('MMM dd, yyyy - hh:mm a').format(session.endTime);

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
                  if (trainerSnapshot.connectionState == ConnectionState.waiting) {
                    return Text('Loading...');
                  } else if (trainerSnapshot.hasError) {
                    return Text('Error: ${trainerSnapshot.error}');
                  } else if (trainerSnapshot.hasData) {
                    final trainer = trainerSnapshot.data!;
                    return Text('Trainer: ${trainer.firstName} ${trainer.lastName}');
                  } else {
                    return Text('No Trainer Data Available');
                  }
                },
              ),
              Text('Sport: ${session.sport}'),
              Text('Specialization: ${session.spec}'),
              Text('Start Time: $startTimeFormatted'),
              Text('End Time: $endTimeFormatted'),
            ],
          ),
        );
      },
    );
  }
}
