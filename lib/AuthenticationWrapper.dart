import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Services/Navigator.dart';
import 'visuals/Welcome.dart';

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
      return NavigatorClass();
    }
    //clear utility class here utility.clear();
    return WelcomePage();
  }
}
