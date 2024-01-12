import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Profile with ChangeNotifier {
  final String uid;
  final String email;
  final String market;
  final String roleView;
  final String firstName;
  final String lastName;
  final String photoUrl;

  Profile({
    required this.uid,
    required this.email,
    required this.market,
    required this.roleView,
    required this.firstName,
    required this.lastName,
    required this.photoUrl,
  });

  factory Profile.fromFirestore(DocumentSnapshot doc) {
    Object? data = doc.data();

    return Profile(
      uid: doc.id,
      email: (data as Map<String, dynamic>)?['email'] ?? '',
      market: (data)?['market'] ?? '',
      roleView: (data)?['roleView'] ?? '',
      firstName: data['firstName'] ?? 'Guest',
      lastName: data['lastName'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
    );
  }
}
