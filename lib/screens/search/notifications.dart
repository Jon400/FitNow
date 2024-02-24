import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/app_user.dart';
import '../../models/profile.dart';
import '../../models/training_session.dart';
import '../../models/request.dart';
import '../../services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Needed for Firestore operations

// Assuming TrainerProfile model exists and has a method to construct from Firestore
// You might need to adjust imports or paths based on your project structure

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
        ),
        body: const Center(child: Text('User not found')),
      );
    }
    final DatabaseService databaseService = DatabaseService(uid: user.uid, roleView: 'trainee');

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.amber ,
      ),
      body: StreamBuilder<Profile>(
        stream: databaseService.profile,
        builder: (context, profileSnapshot) {
          if (profileSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (profileSnapshot.hasError) {
            return Center(child: Text('Error: ${profileSnapshot.error}'));
          } else if (profileSnapshot.hasData) {
            final profile = profileSnapshot.data!;
            return StreamBuilder<List<TrainingSession>>(
              stream: profile.getSortedTrainingSessions(),
              builder: (context, sessionSnapshot) {
                if (sessionSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (sessionSnapshot.hasError) {
                  return Center(child: Text('Error: ${sessionSnapshot.error}'));
                } else if (sessionSnapshot.hasData && sessionSnapshot.data!.isNotEmpty) {
                  final sessions = sessionSnapshot.data!;
                  return ListView.builder(
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      // Fetch trainer profile based on trainerId
                      return StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance.collection('profiles').doc(session.trainerId).snapshots(),
                        builder: (context, trainerSnapshot) {
                          if (!trainerSnapshot.hasData) {
                            return ListTile(title: Text("Loading trainer info..."));
                          }
                          // Parse the trainer's profile data
                          var trainerData = trainerSnapshot.data!.data() as Map<String, dynamic>;
                          String trainerName = "${trainerData['firstName']} ${trainerData['lastName']}";

                          // Determine background color based on index
                          Color backgroundColor = index.isEven ? Colors.grey[400]! : Colors.blue[200]!;

                          return Container(
                             margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(10),
                            ),





                            child: ExpansionTile(
                              title: Text('Session with Trainer $trainerName in ${session.sport}'),
                              // Format the date and time more pretty
                              subtitle: Text(
                                'Start Time: ${DateFormat('dd MMM yyyy, hh:mm a').format(session.startTime)} - ${DateFormat('hh:mm a').format(session.endTime)}',
                              ),
                              children: [
                                StreamBuilder<List<Request>>(
                                  stream: session.streamRequests(),
                                  builder: (context, requestSnapshot) {
                                    if (requestSnapshot.connectionState == ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    } else if (requestSnapshot.hasError) {
                                      return Text('Error: ${requestSnapshot.error}');
                                    } else if (requestSnapshot.hasData && requestSnapshot.data!.isNotEmpty) {
                                      final requests = requestSnapshot.data!;
                                      requests.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sorting by timestamp
                                      return Column(
                                        children: requests.map((request) => ListTile(
                                          title: Text('Request to ${request.status}'),
                                          // do the formatting of the timestamp here more pretty
                                          subtitle: Text(
                                            'Timestamp: ${DateFormat('dd MMM yyyy, hh:mm a').format(request.timestamp)}',
                                          ),
                                        )).toList(),
                                      );
                                    }
                                    return const ListTile(
                                      title: Text('No requests found for this session'),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No Training Sessions Found'));
                }
              },
            );
          } else {
            return const Center(child: Text('Profile not available'));
          }
        },
      ),
    );
  }
}
