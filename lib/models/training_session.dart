import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  // this function will create a new training session in the database but tid will be chosen by the database
  // the status will be pending
  // the traineeId and trainerId will be the id of the trainee and trainer who are logged in


  Future<void> createTrainingSession(String trainerId, String traineeId, DateTime startTime, DateTime endTime, String sport, String spec) async {
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
    final existingSessions = {...sessionsEndingAfterStart.docs, ...sessionsStartingBeforeEnd.docs};

    if (existingSessions.isNotEmpty) {
      // Handle the situation when the trainer is already booked
      throw Exception('The trainer is already booked');
    } else {
      // If no overlapping session, create the new session
      await firestore.collection('training_sessions').doc().set({
        'startTime': startTime,
        'endTime': endTime,
        'sport': sport,
        'spec': spec,
        'traineeId': traineeId,
        'trainerId': trainerId,
        'status': 'pending',
      });
    }
  }
}
