import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Services/Navigator.dart';
import 'visuals/Welcome.dart';
import 'package:deeformity/Services/database.dart';

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    //final firebaseUser = context.watch<User>();
    final firebaseUser = Provider.of<User>(context);
    if (firebaseUser != null) {
      //initialize utility class here utility.initialize

      UserSingleton(user: firebaseUser);
      //Extremely dirty fix during optimization
      DatabaseService(uid: UserSingleton.userSingleton.userID)
          .addedUsersSnapShot
          .listen((addedUsersSnapShot) {
        UserSingleton.userSingleton.addedUsers = addedUsersSnapShot.docs;
      });
      return NavigatorClass();
    }
    //clear utility class here utility.clear();
    return WelcomePage();
  }
}
