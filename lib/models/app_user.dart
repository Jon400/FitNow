import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppUser with ChangeNotifier {
  final String uid;
  final bool emailVerified;

  AppUser({
    required this.uid,
    required this.emailVerified,
  });


}
