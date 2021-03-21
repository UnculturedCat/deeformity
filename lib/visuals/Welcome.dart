import 'SignUp.dart';
import 'package:flutter/material.dart';
import 'SignIn.dart';

class WelcomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WelcomePageState();
  }
}

class WelcomePageState extends State<WelcomePage> {
  bool showSignIn = true;
  void toggleView(bool show) {
    setState(() {
      showSignIn = show;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(context) {
    if (showSignIn) {
      return SignIn(showsigninPage: toggleView);
    } else {
      return SignUpPage(showsigninPage: toggleView);
    }
  }
}
