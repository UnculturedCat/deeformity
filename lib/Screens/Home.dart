import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:deeformity/Screens/Profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../visuals/ScheduleCard.dart';
import 'package:deeformity/Services/database.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/DataManager/Utility.dart';
import 'package:deeformity/AuthenticationWrapper.dart';
import 'package:deeformity/Shared/constants.dart';

class HomePage extends StatefulWidget {
  final String pageName = "homePage";
  HomePage();
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
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
    // Navigator.push(context, MaterialPageRoute(builder: (context) {
    //   return SchedulePage(scheduleData, activityType);
    // }));
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
    setDateInSingleton();
    //setState(() {});
  }

  void setDateInSingleton() {
    UserSingleton.userSingleton.selectedStringDate =
        DateFormat.yMMMd().format(selectedDate);
    UserSingleton.userSingleton.dateTime =
        selectedDate; //set the selected date in the singleton
  }

  Widget createTodayViewButton() {
    bool isToday = DateFormat.yMMMd().format(selectedDate) ==
        DateFormat.yMMMd().format(DateTime.now());
    return isToday
        ? SizedBox()
        : FlatButton(
            onPressed: () {
              setState(() {
                selectedDate = DateTime.now();
                setDateInSingleton();
              });
            },
            child: Text(
              "VIEW TODAY",
              style: TextStyle(fontSize: fontSizeButton, color: Colors.white),
            ),
          );
  }

  List<String> days = ["SUN", "MON", "TUE", "WED", "THUR", "FRI", "SAT"];

  Widget createDayRow(String day) {
    return Container(
      child: Row(
        children: [
          Container(
            child: SizedBox(
              height: 100,
              width: 100,
              child: Text(day),
            ),
          ),
          // Expanded(
          //   child: Container(
          //     height: 200,
          //     child: ListView(
          //       scrollDirection: Axis.horizontal,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    super.build(context);
    return StreamProvider<QuerySnapshot>.value(
      value: DatabaseService().schedule,
      child: Scaffold(
        // appBar: PreferredSize(
        //   preferredSize: Size(double.infinity, 1),
        //   child: AppBar(),
        // ),
        appBar: AppBar(
          //backgroundColor: Color.fromRGBO(24, 41, 57, 1),
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    //colors: [Colors.lightBlue, Colors.blueGrey]
                    colors: [
                  Color.fromRGBO(47, 72, 100, 1),
                  Color.fromRGBO(24, 41, 57, 1)
                ])),
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                ),
                Container(
                  padding: EdgeInsets.only(top: 10, left: 15, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        child: Container(
                          child: Row(children: [
                            Icon(
                              CupertinoIcons.calendar_today,
                              size: 40,
                              color: Colors.white,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Date",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                Text(
                                  DateFormat.yMMMd().format(selectedDate),
                                  style: TextStyle(color: Colors.white),
                                ),
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
                      // CircleAvatar(
                      //   child: Text(
                      //     "U N",
                      //     style: TextStyle(fontSize: 15, color: Colors.white),
                      //   ),
                      //   radius: 20,
                      //   //backgroundImage: AssetImage("assets\test.png"),
                      // ),
                      createTodayViewButton()
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
                )
              ],
            ),
          ),
        ),
        //backgroundColor: Colors.white,
        body: SafeArea(
            child: Column(
          children: [
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
            Divider(),
            Container(
                height: 200,
                padding: EdgeInsets.only(top: 20),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: days.map((day) => createDayRow(day)).toList(),
                )),
          ],
        )),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
