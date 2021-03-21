import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Services/database.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:deeformity/visuals/ExercisePage.dart';
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
  String scheduleToCreate;
  bool creatingSchedule = false;
  String selectedSchedule;
  QuerySnapshot _exercisesSnapshot;
  List<QueryDocumentSnapshot> _exercisesForTheDay = [];
  List<String> schedules;
  final _formkey = GlobalKey<FormState>();

  void openExerciseCard(QueryDocumentSnapshot doc) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ExercisePage(doc);
    }));
  }

  Widget createExerciseCard(QueryDocumentSnapshot doc, DaysOfTheWeek dayEnum) {
    return Container(
      key: Key(dayEnum.toString()),
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
            padding: EdgeInsets.all(4),
            child: Center(
              child: Text(doc.data()["Name"]),
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

  void openDay(DaysOfTheWeek dayEnum) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return WorkoutDay(
        dayEnum: dayEnum,
        scheduleName: selectedSchedule,
      );
    }));
  }

  void addScheduleToDataBase() async {
    if (_formkey.currentState.validate()) {
      _formkey.currentState.save();
      await DatabaseService(uid: UserSingleton.userSingleton.userID)
          .createSchedule(scheduleToCreate);
    }
  }

  void getSchedulesFormDataBase(QuerySnapshot snapshot) {
    List<String> tempSchedule = [];
    snapshot.docs.forEach((element) {
      tempSchedule.add(element.data()["Schedule Name"]);
    });
    selectedSchedule = tempSchedule[0];
    schedules = tempSchedule;
  }

  bool checkForTheDaysExercise(
      QuerySnapshot exercisesSnapshot, DaysOfTheWeek dayEnum) {
    _exercisesForTheDay = [];
    bool exerciseAvailable = false;
    if ((exercisesSnapshot != null && exercisesSnapshot.docs != null) &&
        exercisesSnapshot.docs.isNotEmpty) {
      exercisesSnapshot.docs.forEach((doc) {
        if (doc.data()["Day"] == dayEnum.index &&
            doc.data()["Schedule Name"] == selectedSchedule) {
          _exercisesForTheDay.add(doc);
          exerciseAvailable = true;
        }
      });
    }
    return exerciseAvailable;
  }

  Widget createDayRow(String day, DaysOfTheWeek dayEnum) {
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
                        child: Text("Targeted area"),
                      )
                    ],
                  ),
                ),
              ),
              onTap: () {
                openDay(dayEnum);
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

  Widget createScheduleButton() {
    return TextButton(
        onPressed: () {
          setState(() {
            creatingSchedule = true;
          });
        },
        child: Text(
          "Create New",
          //style: headerActionButtonStyle,
        ));
  }

  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder<QuerySnapshot>(
      stream: DatabaseService(uid: UserSingleton.userSingleton.userID)
          .addedSchedules,
      builder: (context, snapshot) {
        if ((snapshot != null && snapshot.hasData) &&
            (snapshot.data.docs != null && snapshot.data.docs.isNotEmpty)) {
          getSchedulesFormDataBase(snapshot.data);
        }
        return StreamBuilder<QuerySnapshot>(
            stream: DatabaseService(uid: UserSingleton.userSingleton.userID)
                .schedule,
            builder: (context, routinesSnapshot) {
              if ((routinesSnapshot != null && routinesSnapshot.hasData) &&
                  (routinesSnapshot.data.docs != null &&
                      routinesSnapshot.data.docs.isNotEmpty)) {
                _exercisesSnapshot = routinesSnapshot.data;
              }
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  shadowColor: Colors.white10,
                  title:
                      creatingSchedule //check if user clicked create schedule
                          ? Form(
                              key: _formkey,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    child: TextFormField(
                                      decoration:
                                          textInputDecorationWhite.copyWith(
                                        prefixIcon: Icon(CupertinoIcons.tags),
                                        hintStyle: TextStyle(
                                          fontSize: fontSizeInputHint,
                                        ),
                                        hintText: "Name schedule",
                                      ),
                                      onSaved: (input) =>
                                          scheduleToCreate = input,
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
                                    : DropdownButton<String>(
                                        value: selectedSchedule,
                                        items: schedules
                                            .map(
                                              (value) =>
                                                  DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (String currentVal) {
                                          setState(
                                            () {
                                              selectedSchedule = currentVal;
                                            },
                                          );
                                        },
                                      ),
                              ],
                            ),
                ),
                body: schedules == null || schedules.isEmpty
                    ? Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                child: Text(
                                  "Whoops, you have no schedule. \nTap on \"Create New\" to create a schedule. \n You can also save a schedule from another user",
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
                    : Container(
                        padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                        child: ListView(
                          children: DaysOfTheWeek.values
                              .map((day) =>
                                  createDayRow(convertDayToString(day), day))
                              .toList(),
                        ),
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
              );
            });
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class Workout {
  Workout();
}
