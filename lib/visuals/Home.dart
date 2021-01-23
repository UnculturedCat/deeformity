import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:deeformity/visuals/Profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'ScheduleCard.dart';
import 'package:deeformity/Services/database.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/DataManager/Utility.dart';
import 'package:deeformity/AuthenticationWrapper.dart';
import 'SchedulePage.dart';
import 'package:deeformity/Shared/constants.dart';

class HomePage extends StatefulWidget {
  final String pageName = "homePage";
  HomePage();
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  DateTime selectedDate = UserSingleton.userSingleton.dateTime;

  ScheduleData scheduleData;

  void openProfilePage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ProfilePage();
    }));
  }

  void getScheduleData() {
    //Fetch the days details from the schedule database
  }

  void openSchedulePage(ActivityType activityType) {
    UserSingleton.userSingleton.selectedStringDate =
        DateFormat.yMMMd().format(selectedDate);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SchedulePage(scheduleData, activityType);
    }));
  }

  void openDatePicker(BuildContext context) async {
    final DateTime datePicked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2021),
        lastDate: DateTime(2026));

    datePicked != null && datePicked != selectedDate
        ? setState(() {
            selectedDate = datePicked;
          })
        : selectedDate = DateTime.now();
    UserSingleton.userSingleton.selectedStringDate =
        DateFormat.yMMMd().format(selectedDate);
    UserSingleton.userSingleton.dateTime =
        selectedDate; //set the selected date in the singleton
    //setState(() {});
  }

  Widget build(BuildContext context) {
    return StreamProvider<QuerySnapshot>.value(
      value: DatabaseService().schedule,
      child: Scaffold(
        //backgroundColor: Colors.white,
        body: SafeArea(
            child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 10, left: 15, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    child: Container(
                      child: Row(children: [
                        Icon(
                          CupertinoIcons.calendar,
                          size: 40,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Date",
                              style: TextStyle(
                                  color: Color.fromRGBO(24, 41, 57, 1),
                                  fontSize: 20),
                            ),
                            Text(DateFormat.yMMMd().format(selectedDate)),
                            // FlatButton(
                            //     onPressed: null,
                            //     child: Text(
                            //       DateFormat.yMMMd().format(selectedDate),
                            //       style: TextStyle(
                            //         color: Color.fromRGBO(24, 41, 57, 1),
                            //         fontSize: 15, /*fontWeight: FontWeight.bold*/
                            //       ),
                            //     )),
                          ],
                        )
                      ]),
                    ),
                    onTap: () => openDatePicker(context),
                  ),
                  CircleAvatar(
                    child: Text(
                      "U N",
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                    radius: 20,
                    //backgroundImage: AssetImage("assets\test.png"),
                  ),

                  // RaisedButton(
                  //   shape: CircleBorder(),
                  //   onPressed: () {
                  //     //openProfilePage();
                  //     print("Today: Open user Profile");
                  //   },
                  //   child: CircleAvatar(
                  //     child: Text(
                  //       "U N",
                  //       style: TextStyle(fontSize: 15, color: Colors.white),
                  //     ),
                  //     radius: 20,
                  //     //backgroundImage: AssetImage("assets\test.png"),
                  //   ),
                  // )
                  //)
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  GestureDetector(
                    child: Container(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: ScheduleCard(ActivityType.fitness)),
                    onTap: () {
                      openSchedulePage(ActivityType.fitness);
                    },
                  ),
                ],
              ),
            ),
            GestureDetector(
              child: Container(
                padding: EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: ScheduleCard(ActivityType.physio),
                    ),
                  ],
                ),
              ),
              onTap: () {
                openSchedulePage(ActivityType.physio);
              },
            ),
            // Container(
            //   padding: EdgeInsets.only(top: 20),
            //   child: RaisedButton(
            //       child: Text(
            //         "Claim page test button",
            //         style: TextStyle(color: Colors.white),
            //       ),
            //       color: Colors.red,
            //       onPressed: () {
            //         UserSingleton.userSingleton.bullSHit = "Home";
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
            //         print(UserSingleton.userSingleton.bullSHit);
            //       }),
            // ),
          ],
        )),
      ),
    );
  }
}
