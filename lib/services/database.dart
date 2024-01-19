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

  final CollectionReference _userTrainingSessionsCollection =
      FirebaseFirestore.instance.collection('user_training_sessions');

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

  Future<void> linkUserToSession(String uid, String tid) async {
    await _userTrainingSessionsCollection.doc(uid).set(
      {
        'tid': tid,
      },
      SetOptions(merge: true),
    );
  }

  Stream<List<TrainingSession>> get trainingSessions {
    // find all user_training_sessions documents where docid == uid
    // for each document, get the tid
    // find all training_sessions documents where docid == tid
    // return the list of training_sessions documents
    return _userTrainingSessionsCollection.doc(uid).snapshots().asyncMap(
      (snapshot) async {
        List<TrainingSession> sessions = [];
        if (snapshot.exists) {
          String tid = (snapshot.data() as Map<String, dynamic>)?['tid'];
          await _trainingSessionCollection.doc(tid).get().then(
            (snapshot) {
              sessions.add(TrainingSession.fromFirestore(snapshot));
            },
          );
        }
        return sessions;
      },
    );
  }

}
