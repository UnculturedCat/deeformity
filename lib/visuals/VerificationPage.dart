import 'package:deeformity/Services/Authentication.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:deeformity/Shared/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VerificationPage extends StatefulWidget {
  final User user;
  final String email;
  VerificationPage(this.user, this.email);
  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  bool loading = false;
  bool verificationSent = false;
  void sendAgain() {
    setState(() {
      loading = true;
    });
    String message;
    widget.user.sendEmailVerification().catchError((error) {
      message = "Could not send verification link to your email";
      SnackBar snackBar = SnackBar(content: Text(message));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        loading = false;
      });
    }).then((value) {
      if (message.isEmpty) {
        message = "Verification link sent to " + widget.email;
        SnackBar snackBar = SnackBar(content: Text(message));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      setState(() {
        loading = false;
        verificationSent = false;
      });
    });
  }

  void toLoginPage() {
    context.read<AuthenticationService>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? Loading()
          : verificationSent
              ? Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Text(
                            "Verification link sent to " +
                                "\n" +
                                widget.email +
                                "Clink the link in your inbox and try logging in again",
                            style: TextStyle(
                              color: elementColorWhiteBackground,
                              fontSize: fontSize,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                            child: ElevatedButton(
                          onPressed: sendAgain,
                          child: Text(
                            "SEND LINK AGAIN",
                            style: TextStyle(
                              fontSize: fontSizeButton,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                              primary: Color.fromRGBO(36, 36, 36, 100)),
                        )),
                      ],
                    ),
                  ),
                )
              : Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Text(
                            "Hello, friend, you have not verified this email address." +
                                "\n" +
                                widget.email +
                                "\nGo to your inbox or possibly junk,\n AND CLICK THE DAMN LINK \n Then try signing in again",
                            style: TextStyle(
                              color: elementColorWhiteBackground,
                              fontSize: fontSize,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 15),
                          child: ElevatedButton(
                            onPressed: toLoginPage,
                            child: Text(
                              "SIGN IN",
                              style: TextStyle(
                                fontSize: fontSizeButton,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                                primary: elementColorWhiteBackground),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 15),
                          child: TextButton(
                            onPressed: sendAgain,
                            child: Text(
                              "SEND LINK AGAIN",
                              style: TextStyle(
                                fontSize: fontSizeButton,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
