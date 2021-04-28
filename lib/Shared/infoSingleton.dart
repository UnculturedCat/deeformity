import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../Screens/SearhPage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserSingleton {
  User currentUSer;
  String selectedStringDate;
  String userID;
  SearchPage searchPage;
  DocumentSnapshot userDataSnapShot;
  List<QueryDocumentSnapshot> addedUsers = [];
  DateTime dateTime = DateTime.now();
  static FirebaseAnalytics analytics = new FirebaseAnalytics();
  static final UserSingleton userSingleton = UserSingleton._internal();
  factory UserSingleton({User user}) {
    userSingleton.currentUSer = user;
    userSingleton.userID = user.uid;
    return userSingleton;
  }
  UserSingleton._internal();
}
