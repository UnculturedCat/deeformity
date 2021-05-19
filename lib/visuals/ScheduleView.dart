import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Services/database.dart';
import 'package:deeformity/Shared/constants.dart';
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
    scheduleDoc = widget.selectedSchedule;
    super.initState();
    DatabaseService(uid: widget.selectedSchedule.data()["Creator Id"])
        .particularUserSchedule(widget.selectedSchedule.id)
        .listen((event) {
      if (mounted) {
        setState(() {
          scheduleDoc = event; //get latest snapshot from schedule Creator.
        });
      }
    });
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
        elevation: 5,
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
                      convertWorkoutSplitsToString(workoutSplit),
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
    return StreamBuilder<QuerySnapshot>(
        stream:
            DatabaseService(uid: widget.selectedSchedule.data()["Creator Id"])
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
        });
  }
}
