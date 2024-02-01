import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_user.dart';
import '../../models/profile.dart';
import '../../models/training_session.dart';
import '../../models/request.dart';
import '../../services/database.dart';

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
      appBar: AppBar(
        title: const Text('Notifications'),
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
              stream: profile.trainingSessions,
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
                      return ExpansionTile(
                        title: Text('Session with Trainer ${session.trainerId} in ${session.sport}'),
                        subtitle: Text('${session.startTime} - ${session.endTime}'),
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
                                    subtitle: Text('${request.timestamp}'),
                                  )).toList(),
                                );
                              }
                              return const ListTile(
                                title: Text('No requests found for this session'),
                              );
                            },
                          ),
                        ],
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
