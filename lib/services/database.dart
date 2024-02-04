import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_now/models/trainer.dart';
import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../models/sport.dart';
import '../models/training_session.dart';
import '../screens/search/search_training.dart';

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

  final CollectionReference _sportsCollection =
  FirebaseFirestore.instance.collection('sports');

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
      roleView: (snapshot.data() as Map<String, dynamic>)?['roleView'],
      firstName: (snapshot.data() as Map<String, dynamic>)?['firstName'],
      lastName: (snapshot.data() as Map<String, dynamic>)?['lastName'],
    );
  }

  Sport _sportsFromSnapshot(DocumentSnapshot snapshot) {
    return Sport(
      sid: snapshot.id,
      name: (snapshot.data() as Map<String, dynamic>)?['name'],
      specializations: (snapshot.data() as Map<String, dynamic>)?['specializations'],
    );
  }

  List<Sport> _sportsFromQuerySnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Sport.fromFirestore(doc);
    }).toList();
  }

  Future<void> updateProfileName(String firstName, String lastName,
      String roleView) async {
    return await _profileCollection.doc(uid).set(
      {
        'firstName': firstName,
        'lastName': lastName,
        'roleView': roleView,
      },
      SetOptions(merge: true),
    );
  }

  //for the trainer planning : only the approved requests
  Future<List<TrainingSession>> getApprovedTrainingSessions(String trainerId) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('training_sessions')
        .where('trainerId', isEqualTo: trainerId)
        .where('status', isEqualTo: 'approved')
        .get();

    List<TrainingSession> sessions = snapshot.docs
        .map((doc) => TrainingSession.fromFirestore(doc))
        .toList();

    return sessions;
  }


  // Stream<List<Sport>> get allSports {
  //   return _sportsCollection
  //       .snapshots()
  //       .map(_sportsFromQuerySnapshot);
  // }


  Stream<List<Sport>> get sports {
    return _sportsCollection
        .snapshots()
        .map(_sportsFromQuerySnapshot);
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

  Stream<List<TrainerProfile>> searchTrainersStream({
    DateTime? startDate,
    DateTime? endDate,
    String? sport,
    String? specialization,
  }) {
    final controller = StreamController<List<TrainerProfile>>();

    // Query for trainers by sport (if provided)
    Query query = FirebaseFirestore.instance.collection('profiles')
        .where('roleView', isEqualTo: 'trainer');
    if (sport != null) {
      query = query.where('sport', isEqualTo: sport);
    }

    // Subscribe to the Firestore query
    query.snapshots().listen((querySnapshot) async {
      List<TrainerProfile> searchedTrainers = [];

      for (var trainerDoc in querySnapshot.docs) {
        // Query the specializations subcollection of the current trainer
        QuerySnapshot specializationSnapshot = await trainerDoc.reference
            .collection('specializations')
            .get(); // Get all documents in the subcollection

        // Check if any of the documents in the subcollection have the specified specialization
        bool hasSpecialization = specialization == null || specializationSnapshot.docs.any(
              (specDoc) => specDoc['name'] == specialization,
        );

        // If the trainer has the required specialization, proceed with date filtering
        if (hasSpecialization) {
          // Query the availability subcollection for the current trainer
          QuerySnapshot availabilitySnapshot = await trainerDoc.reference
              .collection('datesAvailability')
              .get();

          // Perform date filtering in Dart code
          // Perform date and time filtering in Dart code
          var validAvailability = availabilitySnapshot.docs.where((doc) {
            var data = doc.data() as Map;
            var availStartTime = (data['startTime'] as Timestamp).toDate().toLocal();
            var availEndTime = (data['endTime'] as Timestamp).toDate().toLocal();

            // Add null checks
            if (availStartTime == null || availEndTime == null || startDate == null || endDate == null) {
              return false;
            }

            // // Check if the availability document's start time is after the search start time
            // // Check if the availability document's end time is before the search end time
            return availStartTime.isBefore(endDate) &&
                availEndTime.isAfter(startDate);


          });

          // Check if there are any availability documents that match the date and time range for the trainer
          if (validAvailability.isNotEmpty) {
            searchedTrainers.add(TrainerProfile.fromFirestore(trainerDoc));
          }
        }
      }

      // Add the filtered trainers to the stream
      controller.add(searchedTrainers);
    });

    return controller.stream;
  }

  // get TrainerProfile from trainerId
  Stream<TrainerProfile> getTrainerProfile() {
    return _profileCollection.doc(uid).snapshots().map((doc) {
      return TrainerProfile.fromFirestore(doc);
    });
  }

  Future<void> updateTrainerProfile(
      String firstName,
      String lastName,
      String description,
      String logoUrl,
      String sport,
      List<String> specializations,
      ) async {
    // Update the profile document
    await _profileCollection.doc(uid).set(
      {
        'firstName': firstName,
        'lastName': lastName,
        'roleView': 'trainer',
        'logo_url': logoUrl,
        'description': description,
        'sport': sport,
      },
      SetOptions(merge: true),
    );

    // Update the specializations subcollection
    await _profileCollection.doc(uid).collection('specializations').get().then(
          (snapshot) => snapshot.docs.forEach((doc) => doc.reference.delete()),
    );
    for (var specialization in specializations) {
      await _profileCollection.doc(uid).collection('specializations').add(
        {
          'name': specialization,
        },
      );
    }
  }
}

