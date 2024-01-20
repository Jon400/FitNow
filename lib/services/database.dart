import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/profile.dart';
import '../models/training_session.dart';

class DatabaseService {
  final String uid;
  final String roleView;
  DatabaseService({
    required this.uid,
    required this.roleView,
  });

  final CollectionReference _profileCollection =
      FirebaseFirestore.instance.collection('profiles');

  final CollectionReference _trainingSessionCollection =
      FirebaseFirestore.instance.collection('training_sessions');

  Stream<Profile> get profile {
    return _profileCollection.doc(uid).snapshots().map(_profileFromSnapshot);
  }

  List<TrainingSession> _trainingSessionsFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return TrainingSession.fromFirestore(doc);
    }).toList();
  }

  Profile _profileFromSnapshot(DocumentSnapshot snapshot) {
    return Profile(
      pid: uid,
      email: (snapshot.data() as Map<String, dynamic>)?['email'],
      roleView: (snapshot.data() as Map<String, dynamic>)?['roleView'],
      firstName: (snapshot.data() as Map<String, dynamic>)?['firstName'],
      lastName: (snapshot.data() as Map<String, dynamic>)?['lastName'],
    );
  }

  Future<void> updateProfileName(String firstName, String lastName, String roleView) async {
    return await _profileCollection.doc(uid).set(
      {
        'firstName': firstName,
        'lastName': lastName,
        'roleView': roleView,
      },
      SetOptions(merge: true),
    );
  }

  Stream<List<TrainingSession>> get trainingSessions {
    // find all training sessions inside user's profile
    // take the training session id in the field tid
    // find all training sessions with the tid
    // return the list of training sessions
    return _profileCollection
        .doc(uid)
        .collection('training_sessions')
        .snapshots()
        .asyncMap((snapshot) async {
      List<TrainingSession> trainingSessions = [];
      for (var doc in snapshot.docs) {
        var tid = doc.data()['tid'];
        var trainingSession = await _trainingSessionCollection.doc(tid).get();
        trainingSessions.add(TrainingSession.fromFirestore(trainingSession));
      }
      return trainingSessions;
    });
}

    Future<void> addTrainingSession(String tid) async {
      return await _profileCollection
          .doc(uid)
          .collection('training_sessions')
          .doc(tid)
          .set(
        {
          'tid': tid,
        },
        SetOptions(merge: true),
      );
    }

    Future<void> removeTrainingSession(String tid) async {
      return await _profileCollection
          .doc(uid)
          .collection('training_sessions')
          .doc(tid)
          .delete();
    }
  }
