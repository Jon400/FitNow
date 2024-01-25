// this class will contain the sport name and array of specializations

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Sport extends ChangeNotifier {
  final String sid;
  final String name;
  final List<String> specializations;

  Sport({
    required this.sid,
    required this.name,
    required this.specializations,
  });

  factory Sport.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return Sport(
      sid: doc.id,
      name: data?['name'],
      // convert dynamic to List<String>
      specializations: (data?['specializations'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  // getters for sport name and specializations
  String get sportName => name;
  List<String> get sportSpecializations => specializations;
}