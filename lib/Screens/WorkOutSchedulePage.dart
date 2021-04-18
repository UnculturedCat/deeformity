import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Services/database.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:deeformity/visuals/AddedUsersList.dart';
import 'package:deeformity/visuals/ExercisePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deeformity/visuals/WorkoutDayPage.dart';
import 'package:deeformity/Shared/UserCardCreator.dart';
import 'package:deeformity/User/otherProfile.dart';

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

  final _formkey = GlobalKey<FormState>();
  final _discriptionFormKey = GlobalKey<FormState>();
  DocumentSnapshot scheduleCreator;
  InkWell creatorUserCard;

  @override
  void initState() {
    if (mounted) {
      DatabaseService(uid: UserSingleton.userSingleton.userID)
          .addedSchedules
          .listen((schedulesSnapshot) {
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
          getScheduleCreatorCard();
        }
      });
    }
    super.initState();
  }

  void openExerciseCard(QueryDocumentSnapshot doc) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ExercisePage(doc);
    }));
  }

  Widget createExerciseCard(QueryDocumentSnapshot doc, DaysOfTheWeek dayEnum) {
    return Container(
      color: Colors.white,
      key: Key(doc.id),
      width: largUI
          ? MediaQuery.of(context).size.width / 2.2
          : MediaQuery.of(context).size.height / 7.5,
      child: InkWell(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            padding: EdgeInsets.all(4),
            child: Center(
              child: Text(doc.data()["Name"] ?? "Error name"),
            ),
          ),
        ),
        onLongPress: () {},
        onTap: () {
          openExerciseCard(doc);
        },
      ),
    );
  }

  void openDay(DaysOfTheWeek dayEnum, WorkoutSplits workoutSplit) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return WorkoutDay(
        dayEnum: dayEnum,
        scheduleDoc: selectedSchedule,
        workoutSplit: workoutSplit,
      );
    }));
  }

  void addScheduleToDataBase() async {
    if (_formkey.currentState.validate()) {
      _formkey.currentState.save();

      await DatabaseService(uid: UserSingleton.userSingleton.userID)
          .createSchedule(scheduleToCreate, daysFocusDefaults);
    }
  }

  void openCreatorCard(DocumentSnapshot doc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return OtherUserProfile(doc);
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
                        child: Text(day,
                            style: largUI
                                ? cardHeaderStyle
                                : cardHeaderStyle.copyWith(fontSize: 20)),
                      ),
                      Container(
                        //insert Icon
                        child: Text(
                          convertWorkoutSplitsToString(workoutSplit),
                          style: TextStyle(
                              color: Colors.white, fontSize: fontSizeBody),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              onTap: () {
                openDay(dayEnum, workoutSplit);
              },
            ),
          ),
          Expanded(
            child: Container(
              height: largUI
                  ? MediaQuery.of(context).size.height / 4
                  : MediaQuery.of(context).size.height / 7.5,
              child: (_exercisesSnapshot != null &&
                          _exercisesSnapshot.docs.isNotEmpty) &&
                      checkForTheDaysExercise(_exercisesSnapshot, dayEnum)
                  ? ListView(
                      scrollDirection: Axis.horizontal,
                      children: _exercisesForTheDay
                          .map((doc) => createExerciseCard(doc, dayEnum))
                          .toList(),
                    )
                  : ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Row(
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
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget createScheduleButton({bool popContext = false}) {
    return TextButton(
      onPressed: () {
        if (popContext) Navigator.pop(context);
        setState(() {
          creatingSchedule = true;
        });
      },
      child: Text(
        "New Schedule",
        // style: TextStyle(color: Color.fromRGBO(66, 133, 244, 40)),
        //style: headerActionButtonStyle,
      ),
    );
  }

  Widget createDrawer() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.55,
      //height: MediaQuery.of(context).size.height * 0.45,
      child: Drawer(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            //padding: EdgeInsets.zero,
            children: [
              Container(
                child: Divider(
                  color: Colors.black26,
                ),
              ),
              InkWell(
                child: Container(
                  padding: EdgeInsets.all(6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.floppy_disk, color: Colors.blue),
                      Text(
                        "New Schedule",
                        style: TextStyle(
                            color: elementColorWhiteBackground,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
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
              Container(
                child: Divider(
                  color: Colors.black26,
                ),
              ),
              InkWell(
                child: Container(
                  padding: EdgeInsets.all(6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.offline_share, color: Colors.blue),
                      Text(
                        "Share Schedule",
                        style: TextStyle(
                            color: elementColorWhiteBackground,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                onTap: shareSchedule,
              ),
              Container(
                child: Divider(
                  color: Colors.black26,
                ),
              ),
              InkWell(
                child: Container(
                  padding: EdgeInsets.all(6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.delete,
                        color: Colors.redAccent,
                      ),
                      Text(
                        "Delete Schedule",
                        style: TextStyle(color: Colors.redAccent, fontSize: 15),
                      )
                    ],
                  ),
                ),
                onTap: deleteSchedule,
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
        });
  }

  Future getScheduleCreatorCard() async {
    String creatorId = selectedSchedule.data()["Creator Id"];
    await DatabaseService(uid: UserSingleton.userSingleton.userID)
        .getParticularUserDoc(creatorId)
        .then((value) {
      setState(() {
        scheduleCreator = value;
        creatorUserCard = InkWell(
          child: UserCardCreator(
            userDoc: value,
          ),
          onTap: () {
            openCreatorCard(value);
          },
        );
        //signalFromDropDown = false;
      });
    });
  }

  void setSelectedScheduleDescription() async {
    if (_discriptionFormKey.currentState.validate()) {
      _discriptionFormKey.currentState.save();
      if (scheduleDescription.isNotEmpty) {
        await DatabaseService(uid: UserSingleton.userSingleton.userID)
            .updateScheduleField(
                field: "Description",
                value: scheduleDescription,
                doc: selectedSchedule);
        updateSchedule = true;
      }
    }
    setState(() {
      editingDescription = false;
    });
  }

  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder<QuerySnapshot>(
      stream: DatabaseService(uid: UserSingleton.userSingleton.userID).routines,
      builder: (context, routinesSnapshot) {
        if (routinesSnapshot != null && routinesSnapshot.hasData) {
          _exercisesSnapshot = routinesSnapshot.data;
          _schedulesExercises = [];
          _exercisesSnapshot.docs.forEach((exerciseDoc) {
            if (exerciseDoc.data()["Schedule Id"] == selectedSchedule.id) {
              _schedulesExercises.add(exerciseDoc);
            }
          });
        }
        return GestureDetector(
          child: Scaffold(
            appBar: AppBar(
              actionsIconTheme:
                  IconThemeData(color: elementColorWhiteBackground),
              backgroundColor: Colors.white,
              shadowColor: Colors.white24,
              title: creatingSchedule //check if user clicked create schedule
                  ? Form(
                      key: _formkey,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.5,
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
                            child: TextButton(
                              child: Text("Done"),
                              onPressed: () {
                                addScheduleToDataBase();
                                setState(() {
                                  creatingSchedule = false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        schedules == null ||
                                schedules
                                    .isEmpty //check if user has saved any schedules
                            ? Container(
                                child: createScheduleButton(),
                              )
                            : DropdownButton<QueryDocumentSnapshot>(
                                value: selectedSchedule,
                                items: schedules
                                    .map(
                                      (value) => DropdownMenuItem<
                                          QueryDocumentSnapshot>(
                                        value: value,
                                        child: Text(value.data()["Name"] ??
                                            "Error Name"),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (QueryDocumentSnapshot currentVal) {
                                  setState(
                                    () {
                                      selectedSchedule = currentVal;
                                      getScheduleCreatorCard();
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
                ? Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: Text(
                              "Whoops, you have no schedule. \nTap on \"New Schedule\" to create a schedule. \n You can also save a schedule from another user",
                              style: TextStyle(
                                color: elementColorWhiteBackground,
                                fontSize: fontSize,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 10),
                        child: Column(
                          children: [
                            Text("Created by"),
                            selectedSchedule.data()["Creator Id"] ==
                                    UserSingleton.userSingleton.userID
                                ? Text("You")
                                : creatorUserCard == null
                                    ? Text("Fetching Creator")
                                    : creatorUserCard,
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: editingDescription
                            ? Row(
                                //crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.70,
                                    child: Form(
                                      key: _discriptionFormKey,
                                      child: TextFormField(
                                        maxLines: null,
                                        minLines: 3,
                                        decoration:
                                            textInputDecorationWhite.copyWith(
                                                hintText: "Description",
                                                hintStyle: TextStyle(
                                                    fontSize:
                                                        fontSizeInputHint)),
                                        onSaved: (input) =>
                                            scheduleDescription = input,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: setSelectedScheduleDescription,
                                    child: Text("Done"),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      selectedSchedule.data()["Description"] ??
                                          "No schedule Description",
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(
                                        color: elementColorWhiteBackground,
                                        fontSize: fontSizeBody,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    child: selectedSchedule
                                                .data()["Creator Id"] ==
                                            UserSingleton.userSingleton.userID
                                        ? IconButton(
                                            icon: Icon(Icons.edit),
                                            iconSize: iconSizeBody,
                                            onPressed: () {
                                              setState(() {
                                                editingDescription = true;
                                              });
                                            },
                                          )
                                        : SizedBox(),
                                  ),
                                ],
                              ),
                      ),
                      Expanded(
                        child: Container(
                          padding:
                              EdgeInsets.only(top: 10, left: 10, right: 10),
                          child: ListView(
                            children: DaysOfTheWeek.values
                                .map((day) =>
                                    createDayRow(convertDayToString(day), day))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
            floatingActionButton: IconButton(
                iconSize: 45,
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
                }),
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
