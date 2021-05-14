import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Services/database.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:deeformity/visuals/AddedUsersList.dart';
import 'package:deeformity/visuals/ExercisePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deeformity/visuals/WorkoutDayPage.dart';
import 'package:deeformity/visuals/AboutSchedule.dart';

enum Pages { about, schedule }

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
  bool signalFromDropDown = false;
  bool creatingSchedule = false;
  bool editingDescription = false;
  bool updateSchedule = false;
  QueryDocumentSnapshot selectedSchedule;
  QuerySnapshot _exercisesSnapshot;
  String scheduleToCreate;
  String scheduleDescription;
  List<QueryDocumentSnapshot> _exercisesForTheDay = [];
  List<QueryDocumentSnapshot> _schedulesExercises = [];
  List<QueryDocumentSnapshot> schedules;
  Pages currentPage = Pages.schedule;
  AboutSchedulePage aboutPage;

  final _formkey = GlobalKey<FormState>();
  DocumentSnapshot scheduleCreator;
  InkWell creatorUserCard;

  @override
  void initState() {
    if (mounted) {
      DatabaseService(uid: UserSingleton.userSingleton.userID)
          .addedSchedules
          .listen(
        (schedulesSnapshot) {
          bool initializeSelectedSchedule = true;
          schedules = [];
          schedules = schedulesSnapshot.docs;
          if (selectedSchedule != null) {
            schedules.forEach((schedule) {
              if (schedule.id == selectedSchedule.id) {
                selectedSchedule = schedule;
                initializeSelectedSchedule = false;
              }
            });
          }
          if (initializeSelectedSchedule && schedules.isNotEmpty) {
            selectedSchedule = schedules[0];
            aboutPage = AboutSchedulePage(selectedSchedule);
          }
        },
      );
    }
    super.initState();
  }

  void openExerciseCard(QueryDocumentSnapshot doc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ExercisePage(doc);
        },
      ),
    );
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
          width: largUI
              ? MediaQuery.of(context).size.width / 2.2
              : MediaQuery.of(context).size.height / 7.5,
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
                  fontSize: largUI
                      ? MediaQuery.of(context).size.height * 0.02
                      : MediaQuery.of(context).size.height * 0.017,
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

  void openDay(DaysOfTheWeek dayEnum, WorkoutSplits workoutSplit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return WorkoutDay(
            dayEnum: dayEnum,
            scheduleDoc: selectedSchedule,
            workoutSplit: workoutSplit,
          );
        },
      ),
    );
  }

  void addScheduleToDataBase() async {
    if (_formkey.currentState.validate()) {
      _formkey.currentState.save();

      await DatabaseService(uid: UserSingleton.userSingleton.userID)
          .createSchedule(scheduleToCreate, daysFocusDefaults);
      setState(() {
        creatingSchedule = false;
      });
    }
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
            doc.data()["Schedule Id"] == selectedSchedule.id) {
          _exercisesForTheDay.add(doc);
          exerciseAvailable = true;
        }
      });
    }
    return exerciseAvailable;
  }

  Widget createDayRow(String day, DaysOfTheWeek dayEnum) {
    WorkoutSplits workoutSplit = WorkoutSplits.values[
        selectedSchedule.data()["Split"][dayEnum.index.toString()] ??
            WorkoutSplits.rest];
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      key: Key(day),
      child: Column(
        children: [
          // InkWell(
          //   child: Card(
          //     elevation: 10,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.all(
          //         Radius.circular(10),
          //       ),
          //     ),
          //     child: Container(
          //       height: largUI
          //           ? MediaQuery.of(context).size.height / 4
          //           : MediaQuery.of(context).size.height / 7.5,
          //       width: largUI
          //           ? MediaQuery.of(context).size.width / 2.2
          //           : MediaQuery.of(context).size.height / 7.5,
          //       decoration: BoxDecoration(
          //         borderRadius: BorderRadius.all(
          //           Radius.circular(10),
          //         ),
          //         gradient: LinearGradient(
          //           begin: Alignment.topCenter,
          //           end: Alignment.bottomCenter,
          //           colors: [
          //             Color.fromRGBO(47, 72, 100, 1),
          //             Color.fromRGBO(24, 41, 57, 1),
          //           ],
          //         ),
          //       ),
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Container(
          //             padding: EdgeInsets.only(top: 4),
          //             child: Text(
          //               day,
          //               style: largUI
          //                   ? cardHeaderStyle
          //                   : cardHeaderStyle.copyWith(
          //                       fontSize:
          //                           MediaQuery.of(context).size.height * 0.02),
          //               textAlign: TextAlign.center,
          //             ),
          //           ),
          //           Container(
          //             //insert Icon
          //             child: Text(
          //               convertWorkoutSplitsToString(workoutSplit),
          //               style: TextStyle(
          //                 color: Colors.white,
          //                 fontSize: fontSizeBody,
          //               ),
          //               textAlign: TextAlign.center,
          //             ),
          //           )
          //         ],
          //       ),
          //     ),
          //   ),
          //   onTap: () {
          //     openDay(dayEnum, workoutSplit);
          //   },
          // ),
          InkWell(
            child: Container(
              padding: EdgeInsets.only(top: 4, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    day.toUpperCase() + "| ",
                    style: largUI
                        ? cardHeaderStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            color: elementColorWhiteBackground)
                        : cardHeaderStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            color: elementColorWhiteBackground,
                            fontSize:
                                MediaQuery.of(context).size.height * 0.02),
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
                  height: largUI
                      ? MediaQuery.of(context).size.height / 4
                      : MediaQuery.of(context).size.height / 7.5,
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

  Widget createScheduleButton({bool popContext = false}) {
    return TextButton(
      onPressed: () {
        if (popContext) Navigator.pop(context);
        setState(
          () {
            creatingSchedule = true;
          },
        );
      },
      child: Text(
        "New Schedule",
        // style: TextStyle(color: Color.fromRGBO(66, 133, 244, 40)),
        //style: headerActionButtonStyle,
        //
      ),
    );
  }

  Widget createDrawer() {
    // FocusScopeNode currentFocus = FocusScope.of(context);
    // if (!currentFocus.hasPrimaryFocus) {
    //   currentFocus.unfocus();
    // }
    return Container(
      width: MediaQuery.of(context).size.width * 0.55,
      //height: MediaQuery.of(context).size.height * 0.45,

      child: Drawer(
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(47, 72, 100, 1),
                Color.fromRGBO(24, 41, 57, 1),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            //padding: EdgeInsets.zero,
            children: [
              // Container(
              //   child: Divider(
              //     color: Colors.white,
              //   ),
              // ),
              Flexible(
                child: Container(
                  padding: EdgeInsets.only(bottom: 30),
                  child: Text(
                    "REPLEE",
                    style: TextStyle(
                      decorationThickness: 3,
                      //decorationColor: elementColorWhiteBackground,
                      decoration: TextDecoration.combine(
                        [
                          //TextDecoration.lineThrough,
                          //TextDecoration.overline,
                          //TextDecoration.underline
                        ],
                      ),
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.height * 0.04,
                      fontWeight: FontWeight.bold,
                      fontFamily: "ZenDots",
                    ),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              InkWell(
                child: Container(
                  padding: EdgeInsets.all(6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        CupertinoIcons.floppy_disk,
                        color: Colors.white,
                        size: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(
                            "New Schedule",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.02,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    creatingSchedule = true;
                  });
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Container(
                child: Divider(
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              InkWell(
                child: Container(
                  padding: EdgeInsets.all(6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.offline_share,
                        color: Colors.white,
                        size: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(
                            "Share Schedule",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.02,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: shareSchedule,
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                child: Divider(
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                child: selectedSchedule.data()["Creator Id"] ==
                        UserSingleton.userSingleton.userID
                    ? InkWell(
                        child: Container(
                          padding: EdgeInsets.all(6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                CupertinoIcons.delete,
                                color: Colors.redAccent,
                                size: MediaQuery.of(context).size.height * 0.02,
                              ),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(left: 20),
                                  child: Text(
                                    "Delete Schedule",
                                    style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize:
                                            MediaQuery.of(context).size.height *
                                                0.02),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        onTap: selectedSchedule.data()["Creator Id"] ==
                                UserSingleton.userSingleton.userID
                            ? deleteSchedule
                            : null,
                      )
                    : SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void shareSchedule() {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(top: 50),
          height: MediaQuery.of(context).size.height * 0.85,
          child: AddedUsers(
            sharingItem: true,
            schedule: selectedSchedule,
            schedulesExercises: _schedulesExercises,
          ),
        );
      },
    );
  }

  void deleteSchedule() {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("Warning"),
          content: Text("Are you sure you want permanently delete " +
              selectedSchedule.data()["Name"] +
              "?"),
          actions: [
            CupertinoActionSheetAction(
              child: Text(
                "Yes",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                await DatabaseService(uid: UserSingleton.userSingleton.userID)
                    .deleteSchedule(selectedSchedule, _schedulesExercises);
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

  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder<QuerySnapshot>(
      stream: DatabaseService(uid: UserSingleton.userSingleton.userID).routines,
      builder: (context, routinesSnapshot) {
        if (routinesSnapshot != null && routinesSnapshot.hasData) {
          _exercisesSnapshot = routinesSnapshot.data;
          _schedulesExercises = [];
          _exercisesSnapshot.docs.forEach(
            (exerciseDoc) {
              if (exerciseDoc.data()["Schedule Id"] == selectedSchedule.id) {
                _schedulesExercises.add(exerciseDoc);
              }
            },
          );
        }
        return GestureDetector(
          child: Scaffold(
            appBar: AppBar(
              actionsIconTheme:
                  IconThemeData(color: elementColorWhiteBackground),
              backgroundColor: Colors.white,
              shadowColor: Colors.white24,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  schedules == null ||
                          schedules
                              .isEmpty //check if user has saved any schedules
                      ? SizedBox()
                      : DropdownButton<QueryDocumentSnapshot>(
                          value: selectedSchedule,
                          items: schedules
                              .map(
                                (value) =>
                                    DropdownMenuItem<QueryDocumentSnapshot>(
                                  value: value,
                                  child: Text(
                                      value.data()["Name"] ?? "Error Name"),
                                ),
                              )
                              .toList(),
                          onChanged: (QueryDocumentSnapshot currentVal) {
                            setState(
                              () {
                                selectedSchedule = currentVal;
                                aboutPage = AboutSchedulePage(currentVal);
                              },
                            );
                          },
                        ),
                ],
              ),
            ),
            backgroundColor: Colors.white,
            endDrawer:
                schedules == null || schedules.isEmpty ? null : createDrawer(),
            body: schedules == null || schedules.isEmpty
                ? creatingSchedule
                    ? Center(
                        child: Form(
                          key: _formkey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.75,
                                child: TextFormField(
                                  decoration: textInputDecorationWhite.copyWith(
                                    prefixIcon: Icon(CupertinoIcons.tags),
                                    hintStyle: TextStyle(
                                      fontSize: fontSizeInputHint,
                                    ),
                                    hintText: "Name schedule",
                                  ),
                                  onSaved: (input) => scheduleToCreate = input,
                                  validator: (input) =>
                                      input.isEmpty ? "Enter a name" : null,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 10),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: themeColor),
                                  child:
                                      Container(child: Text("Create Schedule")),
                                  onPressed: addScheduleToDataBase,
                                ),
                              ),
                              Container(
                                child: TextButton(
                                  child: Text("Cancel"),
                                  onPressed: () {
                                    setState(() {
                                      creatingSchedule = false;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                child: Text(
                                  "Whoops, you have no schedule. \nTap on \"New Schedule\" to create a schedule or request a schedule from another user",
                                  style: TextStyle(
                                    color: elementColorWhiteBackground,
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 20),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Color.fromRGBO(47, 72, 100, 1),
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    child: Text(
                                      "New Schedule",
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.019),
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      creatingSchedule = true;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                : creatingSchedule
                    ? Center(
                        child: Form(
                          key: _formkey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.75,
                                child: TextFormField(
                                  decoration: textInputDecorationWhite.copyWith(
                                    prefixIcon: Icon(CupertinoIcons.tags),
                                    hintStyle: TextStyle(
                                      fontSize: fontSizeInputHint,
                                    ),
                                    hintText: "Name schedule",
                                  ),
                                  onSaved: (input) => scheduleToCreate = input,
                                  validator: (input) =>
                                      input.isEmpty ? "Enter a name" : null,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 10),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: themeColor),
                                  child:
                                      Container(child: Text("Create Schedule")),
                                  onPressed: addScheduleToDataBase,
                                ),
                              ),
                              Container(
                                child: TextButton(
                                  child: Text("Cancel"),
                                  onPressed: () {
                                    setState(() {
                                      creatingSchedule = false;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  child: TextButton(
                                    child: Text(
                                      "Schedule",
                                      style: TextStyle(
                                          fontSize:
                                              currentPage != Pages.schedule
                                                  ? 15
                                                  : fontSize,
                                          color: currentPage != Pages.schedule
                                              ? Colors.grey
                                              : themeColor),
                                    ),
                                    onPressed: () {
                                      setState(
                                        () {
                                          currentPage = Pages.schedule;
                                        },
                                      );
                                    },
                                  ),
                                ),
                                VerticalDivider(
                                  //width: 30,
                                  color: Colors.black26,
                                ),
                                Container(
                                  child: TextButton(
                                    child: Text("About",
                                        style: TextStyle(
                                            fontSize: currentPage != Pages.about
                                                ? 15
                                                : fontSize,
                                            color: currentPage != Pages.about
                                                ? Colors.grey
                                                : themeColor)),
                                    onPressed: () {
                                      setState(
                                        () {
                                          currentPage = Pages.about;
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              color: Colors.grey[50],
                              padding:
                                  EdgeInsets.only(top: 10, left: 20, right: 20),
                              child: currentPage == Pages.schedule
                                  ? ListView(
                                      children: DaysOfTheWeek.values
                                          .map(
                                            (day) => createDayRow(
                                                convertDayToString(day), day),
                                          )
                                          .toList(),
                                    )
                                  : aboutPage,
                            ),
                          ),
                        ],
                      ),
            floatingActionButton: currentPage == Pages.schedule
                ? IconButton(
                    iconSize: 45,
                    icon: largUI
                        ? Icon(
                            Icons.zoom_out,
                            color: themeColor,
                          )
                        : Icon(
                            CupertinoIcons.zoom_in,
                            color: themeColor,
                          ),
                    onPressed: () {
                      setState(() {
                        largUI = !largUI;
                      });
                    },
                  )
                : null,
            // floatingActionButton: Container(
            //   child: ElevatedButton(
            //     style: ElevatedButton.styleFrom(
            //       primary: Color.fromRGBO(47, 72, 100, 1),
            //       elevation: 5,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //     ),
            //     child: Container(
            //       padding: EdgeInsets.all(5),
            //       child: Text(
            //         "New Schedule",
            //         style: TextStyle(
            //             fontSize: MediaQuery.of(context).size.height * 0.019),
            //       ),
            //     ),
            //     onPressed: () {},
            //   ),
            // ),
          ),
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class Workout {
  Workout();
}
