import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Services/database.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ExercisePage.dart';
import 'WorkoutDayPage.dart';

class ScheduleViewPage extends StatefulWidget {
  final DocumentSnapshot selectedSchedule;
  ScheduleViewPage({@required this.selectedSchedule});
  @override
  _ScheduleViewPageState createState() => _ScheduleViewPageState();
}

class _ScheduleViewPageState extends State<ScheduleViewPage> {
  DocumentSnapshot scheduleDoc;
  List<QueryDocumentSnapshot> _exercisesForTheDay = [];
  List<QueryDocumentSnapshot> _schedulesExercises = [];
  QuerySnapshot _exercisesSnapshot;
  @override
  void initState() {
    super.initState();
    initializeListener(true);
  }

  void initializeListener(bool firstTime) async {
    if (!firstTime) {
      await DatabaseService(uid: scheduleDoc.data()["Creator Id"])
          .particularUserSchedule(widget.selectedSchedule.id)
          .listen((event) {})
          .cancel();
    }
    DatabaseService(uid: widget.selectedSchedule.data()["Creator Id"])
        .particularUserSchedule(widget.selectedSchedule.id)
        .listen((event) {
      scheduleDoc = null;
      if (mounted) {
        setState(() {
          scheduleDoc = event; //get latest snapshot from schedule Creator.
        });
      }
    });
  }

  @override
  void dispose() {
    DatabaseService(uid: widget.selectedSchedule.data()["Creator Id"])
        .particularUserSchedule(widget.selectedSchedule.id)
        .listen((event) {})
        .cancel();
    super.dispose();
  }

  void openExerciseCard(QueryDocumentSnapshot doc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ExercisePage(
            documentSnapshot: doc,
            key: Key(doc.id),
          );
        },
      ),
    );
  }

  void openDay(DaysOfTheWeek dayEnum, WorkoutSplits workoutSplit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return WorkoutDay(
            dayEnum: dayEnum,
            scheduleDoc: widget.selectedSchedule,
            workoutSplit: workoutSplit,
          );
        },
      ),
    );
  }

  bool checkForTheDaysExercise(
    QuerySnapshot exercisesSnapshot,
    DaysOfTheWeek dayEnum,
  ) {
    _exercisesForTheDay = [];
    bool exerciseAvailable = false;
    if ((exercisesSnapshot != null && exercisesSnapshot.docs != null) &&
        exercisesSnapshot.docs.isNotEmpty) {
      exercisesSnapshot.docs.forEach((doc) {
        List<int> days = List<int>.from(doc.data()["Days"]) ??
            []; //get list of days that this exercise should occur

        if (days.contains(dayEnum.index) &&
            doc.data()["Schedule Id"] == widget.selectedSchedule.id) {
          _exercisesForTheDay.add(doc);
          exerciseAvailable = true;
        }
      });
    }
    return exerciseAvailable;
  }

  Widget createExerciseCard(QueryDocumentSnapshot doc, DaysOfTheWeek dayEnum) {
    return InkWell(
      child: Card(
        key: Key(doc.id),
        color: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: Container(
          width: MediaQuery.of(context).size.height / 7.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            // gradient: LinearGradient(
            //   begin: Alignment.topCenter,
            //   end: Alignment.bottomCenter,
            //   colors: [
            //     Color.fromRGBO(47, 72, 100, 1),
            //     Color.fromRGBO(24, 41, 57, 1),
            //   ],
            // ),
          ),
          padding: EdgeInsets.all(4),
          child: Center(
            child: Text(
              doc.data()["Name"] ?? "Error name",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.017,
                  color: elementColorWhiteBackground,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
      onLongPress: () {},
      onTap: () {
        openExerciseCard(doc);
      },
    );
  }

  void unFollowSchedule() {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("Warning"),
          content: Text("Are you sure you want permanently unfollow " +
              widget.selectedSchedule.data()["Name"] +
              "?"),
          actions: [
            CupertinoActionSheetAction(
              child: Text(
                "Yes",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                await DatabaseService(uid: UserSingleton.userSingleton.userID)
                    .deleteSchedule(
                        doc: widget.selectedSchedule,
                        exercises: _schedulesExercises);
                Navigator.pop(context);
              },
            ),
            CupertinoActionSheetAction(
              child: Text("No"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget createDayRow(String day, DaysOfTheWeek dayEnum) {
    WorkoutSplits workoutSplit = WorkoutSplits.values[
        scheduleDoc.data()["Split"][dayEnum.index.toString()] ??
            WorkoutSplits.rest];
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      key: Key(day),
      child: Column(
        children: [
          InkWell(
            child: Container(
              padding: EdgeInsets.only(top: 4, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    day.toUpperCase() + "| ",
                    style: cardHeaderStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        color: elementColorWhiteBackground,
                        fontSize: MediaQuery.of(context).size.height * 0.02),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    //insert Icon
                    child: Text(
                      convertWorkoutSplitsToString(workoutSplit) + " Day",
                      style: TextStyle(
                        color: elementColorWhiteBackground,
                        fontSize: fontSizeBody,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
            onTap: () {
              openDay(dayEnum, workoutSplit);
            },
          ),
          // Container(
          //   padding: EdgeInsets.only(left: 20, right: 20),
          //   child: ElevatedButton(
          //     style:
          //         ElevatedButton.styleFrom(primary: Colors.white, elevation: 5),
          //     onPressed: () {
          //       openDay(dayEnum, workoutSplit);
          //     },
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Text(
          //           day.toUpperCase() + "| ",
          //           style: largUI
          //               ? cardHeaderStyle.copyWith(
          //                   fontWeight: FontWeight.bold,
          //                   color: elementColorWhiteBackground)
          //               : cardHeaderStyle.copyWith(
          //                   fontWeight: FontWeight.bold,
          //                   color: elementColorWhiteBackground,
          //                   fontSize:
          //                       MediaQuery.of(context).size.height * 0.02),
          //           textAlign: TextAlign.center,
          //         ),
          //         Container(
          //           //insert Icon
          //           child: Text(
          //             convertWorkoutSplitsToString(workoutSplit),
          //             style: TextStyle(
          //               color: elementColorWhiteBackground,
          //               fontSize: fontSizeBody,
          //             ),
          //             textAlign: TextAlign.center,
          //           ),
          //         )
          //       ],
          //     ),
          //   ),
          // ),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: MediaQuery.of(context).size.height / 7.5,
                  child: (_exercisesSnapshot != null &&
                              _exercisesSnapshot.docs.isNotEmpty) &&
                          checkForTheDaysExercise(_exercisesSnapshot, dayEnum)
                      ? ListView(
                          clipBehavior: Clip.none,
                          scrollDirection: Axis.horizontal,
                          children: _exercisesForTheDay
                              .map(
                                (doc) => createExerciseCard(doc, dayEnum),
                              )
                              .toList(),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                left: 2,
                                right: 2,
                              ),
                              child: Icon(Icons.wb_sunny_outlined),
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                left: 2,
                                right: 2,
                              ),
                              child: Text(
                                "No exercises for the day",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (scheduleDoc != null && scheduleDoc.id != widget.selectedSchedule.id) {
      initializeListener(false);
    }
    return scheduleDoc != null && scheduleDoc.data() != null
        ? StreamBuilder<QuerySnapshot>(
            stream: DatabaseService(
                    uid: widget.selectedSchedule.data()["Creator Id"])
                .routines(scheduleId: widget.selectedSchedule.id),
            builder: (context, routinesSnapshot) {
              if (routinesSnapshot != null && routinesSnapshot.hasData) {
                _exercisesSnapshot = routinesSnapshot.data;
                _schedulesExercises = [];
                _exercisesSnapshot.docs.forEach(
                  (exerciseDoc) {
                    if (exerciseDoc.data()["Schedule Id"] ==
                        widget.selectedSchedule.id) {
                      _schedulesExercises.add(exerciseDoc);
                    }
                  },
                );
              }
              return ListView(
                children: DaysOfTheWeek.values
                    .map(
                      (day) => createDayRow(convertDayToString(day), day),
                    )
                    .toList(),
              );
            })
        : Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image,
                    color: Colors.black38,
                    size: fontSize,
                  ),
                  Column(
                    children: [
                      Container(
                        child: Text(
                          "Creator seems to have deleted this schedule",
                          style: TextStyle(
                            color: Colors.black38,
                            fontSize: fontSize,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: themeColor,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          "Unfollow Schedule",
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.019),
                        ),
                      ),
                      onPressed: unFollowSchedule,
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
