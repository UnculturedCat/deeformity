import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Services/Authentication.dart';
import 'package:deeformity/Services/database.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:deeformity/Shared/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateUserPage extends StatefulWidget {
  final User user;
  CreateUserPage(this.user);
  @override
  _CreateUserPageState createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final formKey = GlobalKey<FormState>();
  String firstName, lastName, userName;
  QuerySnapshot allUsersSnapShot;
  bool loading = false;

  bool checkIfUsernameTaken(String username) {
    bool nameTaken = false;

    allUsersSnapShot.docs.forEach((doc) {
      String name = doc["User Name"] ?? " ";
      if (name.toUpperCase() == username.toUpperCase()) {
        nameTaken = true;
      }
    });
    return nameTaken;
  }

  void signOut() async {
    setState(() {
      loading = true;
    });
    await context.read<AuthenticationService>().signOut();
  }

  void handleDone() async {
    setState(() {
      loading = true;
    });
    //String errorMessage;
    dynamic success = false;
    final formState = formKey.currentState;
    if (formState.validate()) {
      formState.save();

      //verify email before creating user
      //Do it here. This will be the ideal implementation

      success =
          await context.read<AuthenticationService>().createNewDataBaseDocument(
                firstName: firstName,
                lastName: lastName,
                userName: userName,
                user: widget.user,
              );
    }
    if (!success) {
      setState(() => loading = false);
      SnackBar snackBar = SnackBar(
          content: Text(context.read<AuthenticationService>().errorMessage));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: DatabaseService().currentUsers,
        builder: (context, snapshot) {
          if (snapshot != null && snapshot.data != null) {
            allUsersSnapShot = snapshot.data;
          }
          return loading
              ? Loading()
              : Scaffold(
                  //appBar: AppBar(),
                  body: Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  decoration: gradientDecoration,
                  child: ListView(
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 40.0),
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          "Welcome",
                          style: TextStyle(color: Colors.white, fontSize: 30),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Form(
                        key: formKey,
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(
                                  left: 10, right: 10, top: 10, bottom: 20),
                              child: Text(
                                welcomeMessage,
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                  color: Colors.white,
                                  //fontFamily: "Romanesco",
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Container(
                              padding:
                                  EdgeInsets.only(left: 10, right: 10, top: 10),
                              child: TextFormField(
                                decoration: textInputDecoration.copyWith(
                                    hintText: "First Name"),
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                                validator: (input) =>
                                    input.isEmpty ? "Enter First Name" : null,
                                //onEditingComplete: handleDone,
                                onSaved: (input) => firstName = input,
                              ),
                            ),
                            Container(
                              padding:
                                  EdgeInsets.only(left: 10, right: 10, top: 10),
                              child: TextFormField(
                                decoration: textInputDecoration.copyWith(
                                    hintText: "Last Name"),
                                style: TextStyle(color: Colors.white),
                                onSaved: (input) => lastName = input,
                                validator: (input) =>
                                    input.isEmpty ? "Enter Last Name" : null,
                                //onEditingComplete: handleDone,
                              ),
                            ),
                            Container(
                              padding:
                                  EdgeInsets.only(left: 10, right: 10, top: 50),
                              child: TextFormField(
                                maxLength: 20,
                                decoration: textInputDecoration.copyWith(
                                    hintText: "User name"),
                                style: TextStyle(color: Colors.white),
                                onSaved: (input) => userName = input,
                                validator: (input) => input.isEmpty
                                    ? "User name"
                                    : checkIfUsernameTaken(input)
                                        ? "Username taken"
                                        : null,
                                //onEditingComplete: handleDone,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                left: 10,
                                right: 10,
                                top: 50,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  TextButton(
                                    onPressed: signOut,
                                    child: Text(
                                      "SIGN OUT",
                                      style: TextStyle(
                                          fontSize: fontSizeButton,
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: handleDone,
                                    child: Text(
                                      "I\'M DONE",
                                      style: TextStyle(
                                        fontSize: fontSizeButton,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        primary:
                                            Color.fromRGBO(36, 36, 36, 100)),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 100,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ));
        });
  }
}
