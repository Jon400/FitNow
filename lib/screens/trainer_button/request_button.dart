import 'package:fit_now/models/app_user.dart';
import 'package:fit_now/screens/profiles/trainer_profile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../models/profile.dart';
import '../../models/training_session.dart';
import '../../services/database.dart';
import '../account/index.dart';
import 'package:intl/intl.dart';

class request_button extends StatefulWidget {
  @override
  _RequestButtonState createState() => _RequestButtonState();
}

class _RequestButtonState extends State<request_button> {
  @override
  Widget build(BuildContext context) {
    AppUser? appUser = Provider.of<AppUser?>(context);
    if (appUser == null) {
      return Center(child: Text('No users logged in'));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Requests from trainees'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('training_sessions')
            .where('trainerId', isEqualTo: appUser.uid)
            .orderBy('startTime')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          var documents = snapshot.data?.docs ?? [];
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var doc = documents[index];
              var trainingSession = TrainingSession.fromFirestore(doc as DocumentSnapshot);
              return StreamBuilder<Profile>(
                stream: DatabaseService(uid: trainingSession.traineeId, roleView: '').profile,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Profile traineeProfile = snapshot.data!;
                    return Card(
                      child: ListTile(
                        title: Text('From: ${traineeProfile.firstName} ${traineeProfile.lastName}'),
                        subtitle: Text('${trainingSession.sport} - ${trainingSession.spec}\n${DateFormat('HH:mm').format(trainingSession.startTime)}-${DateFormat('HH:mm').format(trainingSession.endTime)}, ${DateFormat('dd MMM yyyy').format(trainingSession.endTime)}\nStatus : ${trainingSession.status}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check_circle, color: Colors.green),
                              onPressed: () => _approveRequest(trainingSession.tid, context),
                            ),
                            IconButton(
                              icon: Icon(Icons.cancel, color: Colors.red),
                              onPressed: () => _cancelRequest(trainingSession.tid, context),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  void _approveRequest(String sessionId, BuildContext context) {
    TrainingSession trainingSession = TrainingSession(tid: sessionId, startTime: DateTime.now(), endTime: DateTime.now(), sport: 'sport', spec: 'spec', traineeId: 'traineeId', trainerId: 'trainerId', status: 'status');
    // wait untill trainingsession.approveRequest is done, if it is done, show snackbar'
    trainingSession.approveTrainingSession().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Request Approved"),
        backgroundColor: Colors.green,
      ));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Approval error"),
        backgroundColor: Colors.orange,
      ));
    });
  }

  void _cancelRequest(String sessionId, BuildContext context) {
    TrainingSession trainingSession = TrainingSession(tid: sessionId,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        sport: 'sport',
        spec: 'spec',
        traineeId: 'traineeId',
        trainerId: 'trainerId',
        status: 'status');
    // wait untill trainingsession.approveRequest is done, if it is done, show snackbar'
    trainingSession.cancelTrainingSession().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Request canceled"),
        backgroundColor: Colors.red,
      ));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Cancellation error"),
        backgroundColor: Colors.orange,
      ));
    });
  }
}
