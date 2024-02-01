// this class will represent the request model that contains, rid the description of the request
// status of the request and the timestamp of the request

import 'package:cloud_firestore/cloud_firestore.dart';

class Request {
  String rid;
  String status;
  DateTime timestamp;

  Request({
    required this.rid,
    required this.status,
    required this.timestamp});

  factory Request.fromMap(Map data) {
    return Request(
      rid: data['rid'],
      status: data['status'],
      timestamp: data['timestamp'],
    );
  }

  // fromFirestore(DocumentSnapshot doc) {
  factory Request.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
    return Request(
      rid: doc.id,
      status: data?['status'],
      timestamp: data?['timestamp'].toDate(),
    );
  }
}