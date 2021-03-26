import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:deeformity/Screens/Profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:deeformity/Services/database.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
        : TextButton(
            onPressed: () {
              setState(() {
                selectedDate = DateTime.now();
                setDateInSingleton();
              });
            },
            child: Text(
              "VIEW TODAY",
              style: TextStyle(
                  fontSize: fontSizeButton, color: elementColorWhiteBackground),
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
      value: DatabaseService().routines,
      child: Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Colors.white,
        //   title: Container(
        //     padding: EdgeInsets.only(top: 10, left: 15, right: 15),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       children: [
        //         InkWell(
        //           child: Container(
        //             child: Row(children: [
        //               Icon(
        //                 CupertinoIcons.calendar_today,
        //                 size: 40,
        //                 color: elementColorWhiteBackground,
        //               ),
        //               Column(
        //                 crossAxisAlignment: CrossAxisAlignment.start,
        //                 children: [
        //                   Text(
        //                     "Date",
        //                     style: TextStyle(
        //                         color: elementColorWhiteBackground,
        //                         fontSize: 20),
        //                   ),
        //                   Text(
        //                     DateFormat.yMMMd().format(selectedDate),
        //                     style:
        //                         TextStyle(color: elementColorWhiteBackground),
        //                   ),
        //                 ],
        //               )
        //             ]),
        //           ),
        //           onTap: () => openDatePicker(context),
        //         ),
        //         createTodayViewButton()
        //       ],
        //     ),
        //   ),
        // ),
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
                          CupertinoIcons.calendar_today,
                          size: 40,
                          color: elementColorWhiteBackground,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Date",
                              style: TextStyle(
                                  color: elementColorWhiteBackground,
                                  fontSize: 20),
                            ),
                            Text(
                              DateFormat.yMMMd().format(selectedDate),
                              style:
                                  TextStyle(color: elementColorWhiteBackground),
                            ),
                          ],
                        )
                      ]),
                    ),
                    onTap: () => openDatePicker(context),
                  ),
                  createTodayViewButton()
                ],
              ),
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
