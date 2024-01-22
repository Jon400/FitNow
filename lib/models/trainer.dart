import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_now/models/profile.dart';
import 'package:flutter/material.dart';

class TrainerProfile extends Profile {
  final String logoUrl;
  final String description;
  final String sport;
  final List<String> specializations;

  TrainerProfile({
    required super.pid,
    required super.email,
    required super.roleView,
    required super.firstName,
    required super.lastName,
    required this.logoUrl,
    required this.description,
    required this.sport,
    required this.specializations,
  });

  factory TrainerProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    return TrainerProfile(
      pid: doc.id,
      email: data?['email'] ?? '',
      roleView: data?['roleView'] ?? '',
      firstName: data?['firstName'] ?? 'Guest',
      lastName: data?['lastName'] ?? '',
      logoUrl: data?['logoUrl'] ?? '',
      description: data?['description'] ?? '',
      sport: data?['sport'] ?? '',
      specializations: (data?['specializations'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}