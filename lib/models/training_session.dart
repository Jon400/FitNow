import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TrainingSession {
  final String? tid;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? sport;
  final String? spec;
  TrainingSession({
    this.tid,
    this.startTime,
    this.endTime,
    this.sport,
    this.spec,
  });

  factory TrainingSession.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    return TrainingSession(
      tid: doc.id,
      startTime: data?['startTime'].toDate(),
      endTime: data?['endTime'].toDate(),
      sport: data?['sport'],
      spec: data?['spec'],
    );
  }
}