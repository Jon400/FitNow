import 'package:fit_now/models/app_user.dart';
import 'package:fit_now/screens/profiles/trainer_profile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../models/training_session.dart';
import '../account/index.dart';


class request_button extends StatefulWidget {
  @override
  _request_button createState() => _request_button();
}

class _request_button extends State<request_button> {
  int _selectedPage = 0;
  final _pageOptions = [
    TrainerProfileScreen(),
    AccountScreen(),
  ];

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
              var trainingSession = TrainingSession.fromFirestore(documents[index] as DocumentSnapshot);
              return Card( // Utilisation d'un Card pour une meilleure présentation
                child: ListTile(
                  title: Text('${trainingSession.sport} - ${trainingSession.spec}'),
                  subtitle: Text('Status: ${trainingSession.status} - Start: ${trainingSession.startTime} - End: ${trainingSession.endTime}'),
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
            },
          );
        },
      ),
    );
  }

  void _approveRequest(String sessionId, BuildContext context) {
    FirebaseFirestore.instance.collection('training_sessions').doc(sessionId).update({
      'status': 'approved'
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Request Approved"),
        backgroundColor: Colors.green,
      ));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Approval error"),
        backgroundColor: Colors.red,
      ));
    });
  }

  void _cancelRequest(String sessionId, BuildContext context) {
    FirebaseFirestore.instance.collection('training_sessions').doc(sessionId).update({
      'status': 'cancelled'
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Request canceled"),
        backgroundColor: Colors.red,
      ));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Approval error"),
        backgroundColor: Colors.red,
      ));
    });
  }

}