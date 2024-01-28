import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TrainingSession {
  final String? tid;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? sport;
  final String? spec;
  final String? traineeId;
  final String? trainerId;
  final String? status;

  TrainingSession({
    this.tid,
    this.startTime,
    this.endTime,
    this.sport,
    this.spec,
    this.traineeId,
    this.trainerId,
    this.status,
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

  // this function will create a new training session in the database
  Future<void> createTrainingSession(String pid, String tid, DateTime startTime, DateTime endTime, String sport, String spec) {
    return FirebaseFirestore.instance
        .collection('profiles')
        .doc(pid)
        .collection('training_sessions')
        .doc(tid)
        .set({
          'startTime': startTime,
          'endTime': endTime,
          'sport': sport,
          'spec': spec,
          'traineeId': pid,
          'trainerId': tid,
          'status': 'pending',
        });
  }

}