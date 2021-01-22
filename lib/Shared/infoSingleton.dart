import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_auth/firebase_auth.dart';

class UserSingleton {
  User currentUSer;
  String selectedDate;
  String userID;
  DateTime dateTime = DateTime.now();
  static final UserSingleton userSingleton = UserSingleton._internal();
  factory UserSingleton({User user}) {
    userSingleton.currentUSer = user;
    userSingleton.userID = user.uid;
    return userSingleton;
  }
  UserSingleton._internal();
}
