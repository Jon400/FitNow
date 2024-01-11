import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String userID;
  final String fullName;
  final String email;
  final String username;
  final String role;

  User({
    this.userID,
    this.fullName,
    this.email,
    this.username,
    this.role
  });

  Map<String, Object> toJson() {
    return {
      'userID': userID == null ? '' : userID,
      'full_name': fullName == null ? '' : fullName,
      'email': email == null ? '' : email,
      'username': username == null ? '' : username,
      'role': role == null ? '' : role
    };
  }

  factory User.fromJson(Map<String, Object> doc) {
    User user = new User(
        userID: doc['userID'],
        fullName: doc['full_name'],
        username: doc['username'],
        email: doc['email'],
        role: doc['role']
    );
    return user;
  }

  factory User.fromDocument(DocumentSnapshot doc) {
    return User.fromJson(doc.data);
  }
}