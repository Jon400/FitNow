import 'dart:async';

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
        .where('status', whereIn: ['pending', 'approved'])
        .snapshots()
        .map(_trainingSessionsFromSnapshot);
  }

  Stream<List<TrainingSession>> getSortedTrainingSessions() {
    StreamController<List<TrainingSession>> controller = StreamController.broadcast();

    FirebaseFirestore.instance
        .collection('training_sessions')
        .where('traineeId', isEqualTo: this.pid)
        .snapshots()
        .listen((sessionsSnapshot) async {
      List<TrainingSession> sessions = sessionsSnapshot.docs
          .map((doc) => TrainingSession.fromFirestore(doc))
          .toList();

      // Creating a list of futures to fetch the latest request for each session and map it to a timestamp
      var futures = sessions.map<Future<MapEntry<TrainingSession, DateTime?>>>((session) async {
        var requestsSnapshot = await FirebaseFirestore.instance
            .collection('training_sessions/${session.tid}/requests')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        DateTime? latestTimestamp;
        if (requestsSnapshot.docs.isNotEmpty) {
          latestTimestamp = requestsSnapshot.docs.first.data()['timestamp'].toDate();
        }

        // Return a map entry linking the session to its latest timestamp
        return MapEntry(session, latestTimestamp);
      }).toList();

      // Await all futures and then sort based on the timestamps
      var entriesWithTimestamp = await Future.wait(futures);
      // Remove sessions without any requests (if necessary) and sort the rest
      entriesWithTimestamp.sort((a, b) =>
      b.value?.compareTo(a.value ?? DateTime.fromMillisecondsSinceEpoch(0)) ?? 0);

      // Extract just the TrainingSession objects now that they're sorted
      var sortedSessions = entriesWithTimestamp.map((entry) => entry.key).toList();

      // Send the sorted list to the stream
      controller.add(sortedSessions);
    },
        onError: (error) {
          controller.addError(error); // Handle any errors
        });

    return controller.stream;
  }
}

