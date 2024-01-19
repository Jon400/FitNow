import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';

import '../models/profile.dart';
import 'auth_exception.dart';
import 'database.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late AuthResultStatus _authStatus;

  Stream<AppUser?> get appUser {
    return _auth.userChanges().map(_appUserFromFirebaseUser);
  }

  AppUser? _appUserFromFirebaseUser(User? user) {
    return user != null
        ? AppUser(
            uid: user.uid,
            emailVerified: user.emailVerified,
          )
        : null;
  }

  // Future<Map<String, dynamic>?> get claims async {
  //   final user = _auth.currentUser;
  //   // get the profile from the database that matches the user uid
  //   final token = await user?.getIdTokenResult(true);
  //   print("Claims: ${token?.claims}"); // Add this line for debugging
  //   return (token?.claims);
  // }

  Future<Map<String, dynamic>?> get claims async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        // Fetch the document snapshot from Firestore
        final DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
            .collection('profiles')
            .doc(user.uid)
            .get();

        if (docSnapshot.exists) {
          // Convert the document snapshot to a Profile object
          Profile profile = Profile.fromFirestore(docSnapshot);
          return {'roleView': profile.roleView};
        } else {
          print('Document does not exist');
          return null;
        }
      } catch (e) {
        print('Error fetching profile: $e');
        return null;
      }
    } else {
      print('No current user');
      return null;
    }
  }


  Future<AuthResultStatus> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String roleView,
  }) async {
    try {
      UserCredential authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = authResult.user;
      if (user != null) {
        await DatabaseService(uid: user.uid, roleView: roleView).updateProfileName(
          firstName,
          lastName,
          roleView,
        );
        _authStatus = AuthResultStatus.successful;
      } else {
        _authStatus = AuthResultStatus.undefined;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _authStatus = AuthResultStatus.weakPassword;
      } else if (e.code == 'email-already-in-use') {
        _authStatus = AuthResultStatus.emailAlreadyExists;
      }
    } catch (e) {
      print('Login Exception: $e');
      _authStatus = AuthExceptionHandler.handleException(e);
    }
    return _authStatus;
  }

  Future resetPassword(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<AuthResultStatus> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential authResult = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = authResult.user;
      if (user != null) {
        _authStatus = AuthResultStatus.successful;
      } else {
        _authStatus = AuthResultStatus.undefined;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _authStatus = AuthResultStatus.userNotFound;
      } else if (e.code == 'wrong-password') {
        _authStatus = AuthResultStatus.wrongPassword;
      } else if (e.code == 'too-many-requests') {
        _authStatus = AuthResultStatus.tooManyRequests;
      }
    } catch (e) {
      print('Login Exception: $e');
      _authStatus = AuthExceptionHandler.handleException(e);
    }
    return _authStatus;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      notifyListeners();
      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
