import 'package:firebase_auth/firebase_auth.dart';

class GmailLoginModel {
  bool _newUser;
  bool _isVerified;
  String _firstName;

  String get firstName => _firstName;

  set firstName(String value) {
    _firstName = value;
  }

  FirebaseUser _firebaseUser;

  FirebaseUser get getFirebaseUser => _firebaseUser;

  set setFirebaseUser(FirebaseUser value) {
    _firebaseUser = value;
  }

  bool get getIsVerified => _isVerified;

  set setVerified(bool value) {
    _isVerified = value;
  }

  bool get getNewUser => _newUser;

  set newUser(bool value) {
    _newUser = value;
  }

  String _userId;
  String _email;

  String get getEmail => _email;

  set email(String value) {
    _email = value;
  }

  String get getUserId => _userId;

  set userId(String value) {
    _userId = value;
  }


}