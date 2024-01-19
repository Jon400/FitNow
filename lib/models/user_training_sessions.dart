import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class  UserTrainingSessions {
  final String? uid;
  final String? tid;

  UserTrainingSessions({
    this.uid,
    this.tid,
  });

  factory UserTrainingSessions.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    return UserTrainingSessions(
      uid: doc.id,
      tid: data?['tid'],
    );
  }
}
