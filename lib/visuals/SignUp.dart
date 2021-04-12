import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Services/database.dart';
import 'package:deeformity/Shared/loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Services/Authentication.dart';
//import 'Welcome.dart';
import 'package:deeformity/Shared/constants.dart';

class SignUpPage extends StatefulWidget {
  final Function showsigninPage;
  SignUpPage({this.showsigninPage});
  State<StatefulWidget> createState() {
    return SignUpPageState();
  }
}

class SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();
  String firstName, lastName, email, password, repeatedPassword, userName;
  String location = dropDownLocations.first.value;
  bool loading = false;
  QuerySnapshot allUsersSnapShot;

  @override
  void dispose() {
    super.dispose();
  }

  void handlCancelled() {
    //Navigator.pop(context);
    widget.showsigninPage(true);
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
      //Do it here

      success = await context.read<AuthenticationService>().signUp(
            email: email,
            password: password,
            userName: userName,
            lastName: lastName,
            firstName: firstName,
          );
    }
    if (!success) {
      setState(() => loading = false);
      showErrorMessage(context.read<AuthenticationService>().errorMessage);
    }
  }

  // void navigateToHomeScreen() async {
  //   // setState(() { //do not call setState here because the parent widget, WelcomePage(), has been disposed of.
  //   //   loading = false;
  //   // });
  //   //await context.read<AuthenticationService>().signOut();
  //   //Navigator.pop(context);
  //   //widget.showsigninPage(true);
  //   print("Sign up Success");
  // }

  void showErrorMessage(String errorMessage) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text("Error"),
            content: Text(errorMessage),
            actions: [
              CupertinoActionSheetAction(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void getAllCurrentlyTakenNames() {}

  bool checkIfUsernameTaken(String username) {
    bool nameTaken = false;
    allUsersSnapShot.docs.forEach((doc) {
      if (doc.data()["User Name"] ?? " " == username) {
        nameTaken = true;
      }
    });
    return nameTaken;
  }

  Widget build(context) {
    return StreamBuilder<QuerySnapshot>(
        stream: DatabaseService().addedSchedules,
        builder: (context, snapshot) {
          if (snapshot != null && snapshot.data != null) {
            allUsersSnapShot = snapshot.data;
          }

          return loading
              ? Loading()
              : GestureDetector(
                  child: Scaffold(
                    // appBar: AppBar(
                    //   backgroundColor: Color.fromRGBO(21, 33, 47, 15),
                    //   title: Text(
                    //     "Create Profile",
                    //     style: TextStyle(color: Colors.white, fontSize: 20),
                    //   ),
                    // ),
                    //backgroundColor: Color.fromRGBO(21, 33, 47,100),
                    //body: SafeArea(
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
                              "Create Profile",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 30),
                            ),
                          ),
                          SizedBox(height: 20.0),
                          Form(
                            key: formKey,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, top: 10),
                                  child: TextFormField(
                                    decoration: textInputDecoration.copyWith(
                                        hintText: "First Name"),
                                    style: TextStyle(color: Colors.white),
                                    validator: (input) => input.isEmpty
                                        ? "Enter First Name"
                                        : null,
                                    //onEditingComplete: handleDone,
                                    onSaved: (input) => firstName = input,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, top: 10),
                                  child: TextFormField(
                                    decoration: textInputDecoration.copyWith(
                                        hintText: "Last Name"),
                                    style: TextStyle(color: Colors.white),
                                    onSaved: (input) => lastName = input,
                                    validator: (input) => input.isEmpty
                                        ? "Enter Last Name"
                                        : null,
                                    //onEditingComplete: handleDone,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, top: 50),
                                  child: TextFormField(
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
                                // Container(
                                //   padding:
                                //       EdgeInsets.only(left: 10, right: 10, top: 10),
                                //   // child: TextFormField(
                                //   //   decoration: textInputDecoration.copyWith(
                                //   //       hintText: "Repeat Password"),
                                //   //   style: TextStyle(color: Colors.white),
                                //   //   obscureText: true,
                                //   //   onSaved: (input) => repeatedPassword = input,
                                //   //   //validator: (input){},
                                //   // ),
                                //   child: Row(
                                //     mainAxisAlignment: MainAxisAlignment.start,
                                //     children: [
                                //       Container(
                                //         padding: EdgeInsets.only(left: 5),
                                //         child: Text(
                                //           "Location:",
                                //           style: TextStyle(color: Colors.white),
                                //         ),
                                //       ),
                                //       Container(
                                //         padding: EdgeInsets.only(left: 10, right: 10),
                                //         child: DropdownButton<String>(
                                //           icon: Icon(Icons.location_pin),
                                //           iconEnabledColor: Colors.redAccent,
                                //           iconSize: 20.0,
                                //           value: location,
                                //           dropdownColor:
                                //               Color.fromRGBO(24, 41, 57, 1),
                                //           style: TextStyle(color: Colors.white),
                                //           items: dropDownLocations,
                                //           onChanged: (String currentVal) {
                                //             setState(() {
                                //               location = currentVal;
                                //             });
                                //           },
                                //         ),
                                //       )
                                //     ],
                                //   ),
                                // ),
                                // Container(
                                //   child: Divider(
                                //     color: Colors.white,
                                //   ),
                                // ),
                                Container(
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, top: 50),
                                  child: TextFormField(
                                    decoration: textInputDecoration.copyWith(
                                        hintText: "Email"),
                                    style: TextStyle(color: Colors.white),
                                    onSaved: (input) => email = input,
                                    validator: (input) =>
                                        input.isEmpty ? "Enter Email" : null,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, top: 10),
                                  child: TextFormField(
                                    decoration: textInputDecoration.copyWith(
                                        hintText: "Password"),
                                    style: TextStyle(color: Colors.white),
                                    obscureText: true,
                                    onSaved: (input) => password = input,
                                    onChanged: (input) {
                                      setState(() {
                                        password = input;
                                      });
                                    },
                                    validator: (input) =>
                                        input.isEmpty ? "Enter Password" : null,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, top: 10),
                                  child: TextFormField(
                                    decoration: textInputDecoration.copyWith(
                                        hintText: "Repeat Password"),
                                    style: TextStyle(color: Colors.white),
                                    obscureText: true,
                                    onSaved: (input) => password = input,
                                    validator: (input) => input != password
                                        ? "Does not match provided password"
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                              left: 10,
                              right: 10,
                              top: 50,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                TextButton(
                                    onPressed: handlCancelled,
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                          fontSize: fontSizeButton,
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal),
                                    )),
                                ElevatedButton(
                                  onPressed: handleDone,
                                  child: Text(
                                    "DONE",
                                    style: TextStyle(
                                      fontSize: fontSizeButton,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      primary: Color.fromRGBO(36, 36, 36, 100)),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 100,
                          )
                        ],
                      ),
                    ),
                    //),
                  ),
                  onTap: () {
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                  },
                );
        });
  }
}
