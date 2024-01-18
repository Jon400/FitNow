import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/profile.dart';

class DatabaseService {
  final String uid;
  DatabaseService({
    required this.uid,
  });

  final CollectionReference _profileCollection =
      FirebaseFirestore.instance.collection('profiles');

  Stream<Profile> get profile {
    return _profileCollection.doc(uid).snapshots().map(_profileFromSnapshot);
  }

  Profile _profileFromSnapshot(DocumentSnapshot snapshot) {
    return Profile(
      pid: uid,
      email: (snapshot.data() as Map<String, dynamic>)?['email'],
      roleView: (snapshot.data() as Map<String, dynamic>)?['roleView'],
      firstName: (snapshot.data() as Map<String, dynamic>)?['firstName'],
      lastName: (snapshot.data() as Map<String, dynamic>)?['lastName'],
    );
  }

  Future<void> updateProfileName(String firstName, String lastName, String roleView) async {
    return await _profileCollection.doc(uid).set(
      {
        'firstName': firstName,
        'lastName': lastName,
        'roleView': roleView,
      },
      SetOptions(merge: true),
    );
  }
}
