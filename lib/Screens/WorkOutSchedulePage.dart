import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deeformity/Screens/WorkoutDayPage.dart';

class WorkoutSchedulePage extends StatefulWidget {
  final String pageName = "WorkoutSchedulePage";
  WorkoutSchedulePage();

  @override
  State<StatefulWidget> createState() {
    return WorkoutSchedulePageState();
  }
}

class WorkoutSchedulePageState extends State<WorkoutSchedulePage>
    with AutomaticKeepAliveClientMixin {
  WorkoutSchedulePageState();

  bool largUI = false;
  String selectedSchedule = "";
  QuerySnapshot scheduleSnapShot;

  List<String> days = ["SUN", "MON", "TUE", "WED", "THUR", "FRI", "SAT"];
  List<String> exercises = [
    "Squat",
    "Bench",
    "deadlift",
    "Press",
    "Overhead press",
    "Um",
    "Uhm"
  ];

  List<String> schedules = [
    "Bulk",
    "Strenght",
    "Condition",
  ];

  Widget createWorkOutRoutineCard(String exercise) {
    return Container(
      key: Key(exercise),
      width: largUI
          ? MediaQuery.of(context).size.width / 2.2
          : MediaQuery.of(context).size.height / 7.5,
      //padding: EdgeInsets.only(left: 2, right: 2),
      child: InkWell(
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Container(
            padding: EdgeInsets.all(4),
            child: Center(
              child: Text(exercise),
            ),
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> getSchedulesFormDataBase() {
    return schedules
        .map((value) =>
            DropdownMenuItem<String>(value: value, child: Text(value)))
        .toList();
  }

  void openDay(String day) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return WorkoutDay(day);
    }));
  }

  Widget createDayRow(String day) {
    return Container(
      key: Key(day),
      child: Row(
        children: [
          Container(
            child: InkWell(
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Container(
                  height: largUI
                      ? MediaQuery.of(context).size.height / 4
                      : MediaQuery.of(context).size.height / 7.5,
                  width: largUI
                      ? MediaQuery.of(context).size.width / 2.2
                      : MediaQuery.of(context).size.height / 7.5,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromRGBO(47, 72, 100, 1),
                            Color.fromRGBO(24, 41, 57, 1)
                          ])),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          day,
                          style: cardHeaderStyle,
                        ),
                      ),
                      Container(
                        //insert Icon
                        child: Text("Targeted area"),
                      )
                    ],
                  ),
                ),
              ),
              onTap: () {
                openDay(day);
              },
            ),
          ),
          Expanded(
            child: Container(
              height: largUI
                  ? MediaQuery.of(context).size.height / 4
                  : MediaQuery.of(context).size.height / 7.5,
              child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: exercises
                      .map((exercise) => createWorkOutRoutineCard(exercise))
                      .toList()),
            ),
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    super.build(context);
    if (selectedSchedule.isEmpty) {
      selectedSchedule = schedules.first;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.white10,
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          DropdownButton<String>(
            value: selectedSchedule,
            items: getSchedulesFormDataBase(),
            onChanged: (String currentVal) {
              setState(() {
                selectedSchedule = currentVal;
              });
            },
          ),
          IconButton(
              icon: largUI
                  ? Icon(
                      Icons.zoom_out,
                      color: Color.fromRGBO(21, 33, 47, 1),
                    )
                  : Icon(
                      CupertinoIcons.zoom_in,
                      color: Color.fromRGBO(21, 33, 47, 1),
                    ),
              onPressed: () {
                setState(() {
                  largUI = !largUI;
                });
              })
        ]),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 10, left: 10, right: 10),
        child: ListView(
          children: days.map((day) => createDayRow(day)).toList(),
        ),
        // child: Column(children: [
        //   Container(
        //     padding: EdgeInsets.only(bottom: 20, left: 10, right: 10),
        //     child: Row(children: [Text("Current Schdule")]),
        //   ),
        //   Container(
        //     height: MediaQuery.of(context).size.height * 0.71,
        //     child: ListView(
        //       children: days.map((day) => createDayRow(day)).toList(),
        //     ),
        //   ),
        // ]),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class Workout {
  Workout();
}
