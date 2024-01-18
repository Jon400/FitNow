import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Profile with ChangeNotifier {
  final String pid;
  final String email;
  final String roleView;
  final String firstName;
  final String lastName;

  Profile({
    required this.pid,
    required this.email,
    required this.roleView,
    required this.firstName,
    required this.lastName,
  });



  factory Profile.fromFirestore(DocumentSnapshot doc) {
    Object? data = doc.data();

    return Profile(
      pid: doc.id,
      email: (data as Map<String, dynamic>)?['email'] ?? '',
      roleView: (data)?['roleView'] ?? '',
      firstName: data['firstName'] ?? 'Guest',
      lastName: data['lastName'] ?? '',
    );
  }
}
