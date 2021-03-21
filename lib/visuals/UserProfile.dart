import 'package:deeformity/Shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deeformity/User/UserClass.dart';
import 'package:deeformity/visuals/Settings.dart';
import 'package:deeformity/Shared/loading.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String userFirstName;
  String userLastName;
  String userLocation;
  String userOccupation;
  bool careGiver;
  bool loading = true;

  void openTrainerPage() {
    print("Open Trainer Profile");
  }

  void openPhysioPage() {
    print("Open Physio Profile");
  }

  void openSettingsPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SettingsPage();
    }));
    print("Open settings");
  }

  Widget text() => Text(
        "$userOccupation",
        style: TextStyle(fontSize: 20, color: Colors.black),
      );

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    if (userData != null) {
      userFirstName = userData.firstName;
      userLastName = userData.lastName;
      userLocation = userData.location;
      loading = false;
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Profile",
            style: TextStyle(
                color: Color.fromRGBO(21, 33, 47, 1), fontSize: fontSize),
          ),
          //backgroundColor: Color.fromRGBO(21, 33, 47, 15),
          backgroundColor: Colors.white,
          actions: [
            IconButton(
                icon: Icon(
                  Icons.settings,
                  color: Color.fromRGBO(21, 33, 47, 1),
                ),
                onPressed: openSettingsPage)
          ],
          centerTitle: true,
          automaticallyImplyLeading: false,
          shadowColor: Colors.white10,
        ),
        backgroundColor: Colors.white,
        body: Container(
          child: ListView(
            children: <Widget>[
              //Profile Picture and Information container
              Container(
                  padding: EdgeInsets.only(top: 80),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 10,
                                  color: Colors.black38,
                                  spreadRadius: 1)
                            ]),
                        child: CircleAvatar(
                          child: Text(userFirstName[0],
                              style:
                                  TextStyle(fontSize: 50, color: Colors.white)),
                          radius: 80,
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Container(
                          child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "$userFirstName $userLastName ",
                            style: TextStyle(fontSize: 30, color: Colors.black),
                          ),
                          Text(
                            "$userLocation",
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                          Text(
                            "$userOccupation",
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          )
                        ],
                      ))
                    ],
                  )),
              Container(
                padding: EdgeInsets.only(top: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    //Trainer
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        GestureDetector(
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                      color: Colors.black38)
                                ]),
                            child: CircleAvatar(
                              radius: 50,
                              child: Text("T"),
                            ),
                          ),
                          onTap: openTrainerPage,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Row(
                            children: [
                              Icon(Icons.fitness_center_rounded),
                              Text(
                                "Trainer",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.black),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        GestureDetector(
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                      color: Colors.black38)
                                ]),
                            child: CircleAvatar(
                              radius: 50,
                              child: Text("P"),
                            ),
                          ),
                          onTap: openPhysioPage,
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Row(
                              children: [
                                Icon(Icons.accessibility_new_rounded),
                                Text(
                                  "Physio",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              ],
                            )),
                      ],
                    ),
                  ],
                ),
              ),
              // Container(
              //   padding: EdgeInsets.only(top: 20, right: 10, left: 10),
              //   child: RaisedButton(
              //       child: Text(
              //         "Claim page test button",
              //         style: TextStyle(color: Colors.white),
              //       ),
              //       color: Colors.red,
              //       onPressed: () {
              //         //UserSingleton.userSingleton.bullSHit = "Profile";
              //       }),
              // ),
              // Container(
              //   padding: EdgeInsets.only(top: 20),
              //   child: RaisedButton(
              //       child: Text(
              //         "Print Page name test button",
              //         style: TextStyle(color: Colors.white),
              //       ),
              //       color: Colors.red,
              //       onPressed: () {
              //         //print(UserSingleton.userSingleton.bullSHit);
              //       }),
              // ),
              Container(
                  //add stats
                  )
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
          appBar: AppBar(
            title: Text(
              "Profile",
              style:
                  TextStyle(color: Color.fromRGBO(21, 33, 47, 1), fontSize: 20),
            ),
            //backgroundColor: Color.fromRGBO(21, 33, 47, 15),
            backgroundColor: Colors.white,
            actions: [
              IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: Color.fromRGBO(21, 33, 47, 1),
                  ),
                  onPressed: openSettingsPage)
            ],
            centerTitle: true,
            automaticallyImplyLeading: false,
            shadowColor: Colors.white10,
          ),
          backgroundColor: Colors.white,
          body: Center(child: Loading()));
    }
  }
}
