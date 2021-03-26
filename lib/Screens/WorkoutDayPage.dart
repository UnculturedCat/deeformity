import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:deeformity/visuals/AddExercisePage.dart';
import 'package:flutter/material.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:deeformity/visuals/ExerciseList.dart';

class WorkoutDay extends StatefulWidget {
  final DaysOfTheWeek dayEnum;
  final QueryDocumentSnapshot scheduleDoc;
  WorkoutDay({@required this.dayEnum, @required this.scheduleDoc});
  @override
  State<StatefulWidget> createState() {
    return WorkoutDayState();
  }
}

class WorkoutDayState extends State<WorkoutDay> {
  String date = UserSingleton.userSingleton.selectedStringDate;
  String pageTitle;
  String category;
  WorkoutDayState();
  // void updateSchedule() async {
  //   await DatabaseService(uid: UserSingleton.userSingleton.currentUSer.uid)
  //       .updateSchedule();
  // }

  void openCreateExercisePage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddExercisePage(
          dayEnum: widget.dayEnum, scheduleDoc: widget.scheduleDoc);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          convertDayToString(widget.dayEnum),
          style: pageHeaderStyle,
        ),
        backgroundColor: Color.fromRGBO(21, 33, 47, 15),
      ),
      body: Center(
          //padding: EdgeInsets.all(40),
          child: ListView(
        children: [
          Container(
            padding: EdgeInsets.only(top: 20),
            child: ExerciseList(
              dayEnum: widget.dayEnum,
              scheduleDoc: widget.scheduleDoc,
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 20, right: 20, left: 20),
            child: FloatingActionButton.extended(
                label: Text(
                  "Add exercise",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSizeButton,
                  ),
                ),
                backgroundColor: Color.fromRGBO(27, 98, 49, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                ),
                onPressed: () {
                  openCreateExercisePage();
                }),
          ),
        ],
      )),
    );
  }
}
