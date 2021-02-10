import 'dart:async';
import '../Screens/SearhPage.dart';
import 'package:deeformity/User/UserClass.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';

class UserSingleton {
  User currentUSer;
  String selectedStringDate;
  String userID;
  UserData userData;
  SearchPage searchPage;
  DateTime dateTime = DateTime.now();
  static final UserSingleton userSingleton = UserSingleton._internal();
  factory UserSingleton({User user}) {
    userSingleton.currentUSer = user;
    userSingleton.userID = user.uid;
    return userSingleton;
  }
  UserSingleton._internal();
}
