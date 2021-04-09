import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Services/database.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:deeformity/visuals/AddExercisePage.dart';
import 'package:flutter/material.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:deeformity/visuals/ExerciseList.dart';

class WorkoutDay extends StatefulWidget {
  final DaysOfTheWeek dayEnum;
  final QueryDocumentSnapshot scheduleDoc;
  final WorkoutSplits workoutSplit;
  WorkoutDay(
      {@required this.dayEnum,
      @required this.scheduleDoc,
      @required this.workoutSplit});
  @override
  State<StatefulWidget> createState() {
    return WorkoutDayState();
  }
}

class WorkoutDayState extends State<WorkoutDay> {
  String date = UserSingleton.userSingleton.selectedStringDate;
  String pageTitle;
  String category;
  WorkoutSplits workoutSplit;
  // void updateSchedule() async {
  //   await DatabaseService(uid: UserSingleton.userSingleton.currentUSer.uid)
  //       .updateSchedule();
  // }
  WorkoutDayState();

  @override
  void initState() {
    workoutSplit = widget.workoutSplit;
    super.initState();
  }

  void openCreateExercisePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return AddExercisePage(
              dayEnum: widget.dayEnum, scheduleDoc: widget.scheduleDoc);
        },
      ),
    );
  }

  void updateSchedule() async {
    String day = widget.dayEnum.index.toString();
    await DatabaseService(uid: UserSingleton.userSingleton.userID)
        .updateScheduleField(
            field: "Split.$day",
            value: workoutSplit.index,
            doc: widget.scheduleDoc);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.white24,
        iconTheme: IconThemeData(color: elementColorWhiteBackground),
        title: Text(
          convertDayToString(widget.dayEnum),
          style: pageHeaderStyle,
        ),
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.scheduleDoc.data()["Creator Id"] ==
                        UserSingleton.userSingleton.userID
                    ? DropdownButton<WorkoutSplits>(
                        value: workoutSplit,
                        items: dropDownWorkOutSplits,
                        onChanged: (value) {
                          setState(() {
                            workoutSplit = value;
                            updateSchedule();
                          });
                        },
                      )
                    : Container(
                        child: Text(
                          convertWorkoutSplitsToString(workoutSplit),
                          style: TextStyle(fontSize: fontSize),
                        ),
                      ),
                Text(
                  " day",
                  style: TextStyle(fontSize: fontSize),
                ),
              ],
            ),
          ),
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
      ),
    );
  }
}
