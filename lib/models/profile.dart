import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_now/models/training_session.dart';
import 'package:flutter/material.dart';

class Profile with ChangeNotifier {
  final String pid;
  final String roleView;
  final String firstName;
  final String lastName;


  Profile({
    required this.pid,
    required this.roleView,
    required this.firstName,
    required this.lastName,
  });

  factory Profile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    return Profile(
      pid: doc.id,
      roleView: data?['roleView'] ?? '',
      firstName: data?['firstName'] ?? '',
      lastName: (data)?['lastName'] ?? '',
    );
  }

  List<TrainingSession> _trainingSessionsFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return TrainingSession.fromFirestore(doc);
    }).toList();
  }

  Stream<List<TrainingSession>> get trainingSessions {
    // find all training sessions that that their traineeId is equal to the current user id
    return FirebaseFirestore.instance
        .collection('training_sessions')
        .where('traineeId', isEqualTo: pid)
        .snapshots()
        .map(_trainingSessionsFromSnapshot);

  }
}
