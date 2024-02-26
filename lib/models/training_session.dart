import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_now/models/profile.dart';
import 'package:fit_now/models/request.dart';
import 'package:fit_now/models/trainer.dart';


class TrainingSession {
  final String tid;
  final DateTime startTime;
  final DateTime endTime;
  final String sport;
  final String spec;
  final String traineeId;
  final String trainerId;
  final String status;

  TrainingSession({
    required this.tid,
    required this.startTime,
    required this.endTime,
    required this.sport,
    required this.spec,
    required this.traineeId,
    required this.trainerId,
    required this.status,
  });

  factory TrainingSession.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    return TrainingSession(
      tid: doc.id,
      startTime: data?['startTime'].toDate(),
      endTime: data?['endTime'].toDate(),
      sport: data?['sport'],
      spec: data?['spec'],
      traineeId: data?['traineeId'],
      trainerId: data?['trainerId'],
      status: data?['status'],
    );
  }

  Future<TrainingSession?> createTrainingSession(String trainerId, String traineeId, DateTime startTime, DateTime endTime, String sport, String spec) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // First query: Find sessions that end after the desired start time and are either approved or pending
    final QuerySnapshot sessionsEndingAfterStart = await firestore.collection('training_sessions')
        .where('trainerId', isEqualTo: trainerId)
        .where('endTime', isGreaterThan: startTime)
        .where('status', whereIn: ['approved', 'pending'])
        .get();

    // Second query: Find sessions that start before the desired end time and are either approved or pending
    final QuerySnapshot sessionsStartingBeforeEnd = await firestore.collection('training_sessions')
        .where('trainerId', isEqualTo: trainerId)
        .where('startTime', isLessThan: endTime)
        .where('status', whereIn: ['approved', 'pending'])
        .get();

    // Combine results to check for overlap
    // take the intersection of the two sets
    final existingSessions = sessionsEndingAfterStart.docs.toSet().intersection(sessionsStartingBeforeEnd.docs.toSet());
    // final existingSessions = {...sessionsEndingAfterStart.docs, ...sessionsStartingBeforeEnd.docs};

    if (existingSessions.isNotEmpty) {
      // Handle the situation when the trainer is already booked
      throw Exception('The trainer is already booked');
    } else {
      DocumentReference sessionDocRef = await firestore.collection('training_sessions').doc();
      // If no overlapping session, create the new session
      await sessionDocRef.set({
        'startTime': startTime,
        'endTime': endTime,
        'sport': sport,
        'spec': spec,
        'traineeId': traineeId,
        'trainerId': trainerId,
        'status': 'pending',
      });
      // save it to the request collection under the current session id
      await sessionDocRef.collection('requests').doc().set({
        'status': 'pending',
        'timestamp': DateTime.now(),
      });
      return TrainingSession(
        tid: sessionDocRef.id,
        startTime: startTime,
        endTime: endTime,
        sport: sport,
        spec: spec,
        traineeId: traineeId,
        trainerId: trainerId,
        status: 'pending',
      );
    }
  }

  // delete training session from the database, (changes the status to deleted)
  Future<void> deleteTrainingSession() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection('training_sessions').doc(tid).update({
      'status': 'deleted'
    });
  }

  // this function will stream out all requests that are associated with the training session
  // the requests will be streamed out in a list of request objects
  Stream<List<Request>> streamRequests() {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    return firestore
        .collection('training_sessions')
        .doc(tid)
        .collection('requests')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Request.fromFirestore(doc)).toList());
  }

  // Stream get the Trainer
  Stream<TrainerProfile> getTrainer() {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // where the tainerId is equal to the trainerId of the training session
    return firestore
        .collection('profiles')
        .doc(trainerId)
        .snapshots()
        .map((DocumentSnapshot doc) => TrainerProfile.fromFirestore(doc));
  }

  // Stream get the Trainee
  Stream<Profile> getTrainee() {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return firestore
        .collection('profiles')
        .doc(traineeId)
        .snapshots()
        .map((DocumentSnapshot doc) => Profile.fromFirestore(doc));
  }

  // stream to get last update according to the last request
  Stream<Request> getLatestRequest() {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    return firestore
        .collection('training_sessions')
        .doc(tid)
        .collection('requests')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) => Request.fromFirestore(snapshot.docs.first));
  }

  // approve training session
   Future<void> approveTrainingSession() async {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      // update the status of the training session to approved
      await firestore.collection('training_sessions').doc(tid).update({
        'status': 'approved'
      });
      // update the status of the request to approved
      await firestore.collection('training_sessions').doc(tid).collection('requests').doc().set(
        {
          'status': 'approved',
          'timestamp': DateTime.now(),
        }
      );
      return;
    }

    // cancel training session
    Future<void> cancelTrainingSession() async {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      // update the status of the training session to cancelled
      await firestore.collection('training_sessions').doc(tid).update({
        'status': 'cancelled'
      });
      // update the status of the request to cancelled
      await firestore.collection('training_sessions').doc(tid).collection('requests').doc().set(
        {
          'status': 'cancelled',
          'timestamp': DateTime.now(),
        }
      );
      return;
    }
}
