import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Services/database.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:deeformity/visuals/AddedSchedulesList.dart';
import 'package:deeformity/visuals/AddedUsersList.dart';
import 'package:deeformity/visuals/ScheduleView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  String scheduleToCreate;
  String scheduleDescription;
  List<QueryDocumentSnapshot> _schedulesExercises = [];
  List<QueryDocumentSnapshot> schedules;
  Pages currentPage = Pages.schedule;
  AboutSchedulePage aboutPage;
  ScheduleViewPage scheduleViewPage;

  final _formkey = GlobalKey<FormState>();
  DocumentSnapshot scheduleCreator;
  InkWell creatorUserCard;

  @override
  void initState() {
    DatabaseService(uid: UserSingleton.userSingleton.userID)
        .schedules()
        .then((value) {
      setState(() {
        if (value != null && value.docs != null && value.docs.isNotEmpty) {
          schedules = value.docs;
          selectedSchedule = schedules[0];
        }
      });
    });
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
            aboutPage = AboutSchedulePage(
              doc: selectedSchedule,
              key: Key(selectedSchedule.id),
            );
            scheduleViewPage =
                ScheduleViewPage(selectedSchedule: selectedSchedule);
          } else if (initializeSelectedSchedule && schedules.isEmpty) {
            selectedSchedule = null;
          }
          setState(() {});
        },
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    DatabaseService(uid: UserSingleton.userSingleton.userID)
        .addedSchedules
        .listen((event) {})
        .cancel();
    super.dispose();
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

  //Implement later
  void updateSelectedSchedule(String scheduleId) async {
    await await DatabaseService(uid: UserSingleton.userSingleton.userID)
        .updateUserData(field: "Last Used Schedule", value: scheduleId);
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
                        CupertinoIcons.add,
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
                                //Icons.offline_share,
                                CupertinoIcons.share,
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
                                          MediaQuery.of(context).size.height *
                                              0.02,
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
                      )
                    : SizedBox(),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                child: selectedSchedule.data()["Creator Id"] ==
                        UserSingleton.userSingleton.userID
                    ? Divider(
                        color: Colors.white,
                      )
                    : SizedBox(),
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
                                              0.02,
                                    ),
                                    //maxLines: 1,
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          deleteSchedule();
                        },
                      )
                    : InkWell(
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
                                    "Unfollow Schedule",
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize:
                                          MediaQuery.of(context).size.height *
                                              0.02,
                                    ),
                                    //maxLines: 1,
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          unFollowSchedule();
                        },
                      ),
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
          ),
        );
      },
    );
  }

  void showListOfSchedules() {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(top: 50),
          height: MediaQuery.of(context).size.height * 0.85,
          child: AddedSchedules(
            UserSingleton.userSingleton.userID,
            cardFunction: setSelectedSchedule,
          ),
        );
      },
    );
  }

  void setSelectedSchedule(QueryDocumentSnapshot doc) {
    setState(
      () {
        selectedSchedule = doc;
        aboutPage = AboutSchedulePage(
          doc: doc,
          key: Key(doc.id),
        );
        scheduleViewPage = ScheduleViewPage(
          selectedSchedule: doc,
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
                    .deleteSchedule(
                        doc: selectedSchedule, exercises: _schedulesExercises);
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

  void unFollowSchedule() {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("Warning"),
          content: Text("Are you sure you want permanently unfollow " +
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
                    .deleteSchedule(doc: selectedSchedule, exercises: null);
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

    return GestureDetector(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          actionsIconTheme: IconThemeData(color: themeColor),
          backgroundColor: Colors.white,
          shadowColor: Colors.white24,
          // title: Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     schedules == null ||
          //             schedules.isEmpty //check if user has saved any schedules
          //         ? SizedBox()
          //         : DropdownButton<QueryDocumentSnapshot>(
          //             value: selectedSchedule,
          //             items: schedules
          //                 .map(
          //                   (value) => DropdownMenuItem<QueryDocumentSnapshot>(
          //                     value: value,
          //                     child: Text(
          //                       value.data()["Name"] ?? "Error Name",
          //                       style: TextStyle(
          //                           color: themeColor,
          //                           fontWeight: FontWeight.bold),
          //                     ),
          //                   ),
          //                 )
          //                 .toList(),
          //             onChanged: (QueryDocumentSnapshot currentVal) {
          //               setState(
          //                 () {
          //                   selectedSchedule = currentVal;
          //                   aboutPage = AboutSchedulePage(
          //                     doc: currentVal,
          //                     key: Key(currentVal.id),
          //                   );
          //                   scheduleViewPage = ScheduleViewPage(
          //                     selectedSchedule: currentVal,
          //                   );
          //                 },
          //               );
          //             },
          //           ),
          //   ],
          // ),
          title: TextButton(
            child: Text(
              selectedSchedule != null
                  ? selectedSchedule.data()["Name"] ?? "No Name"
                  : " ",
              style: TextStyle(
                color: themeColor,
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            ),
            onPressed: showListOfSchedules,
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
                              style:
                                  ElevatedButton.styleFrom(primary: themeColor),
                              child: Container(child: Text("Create Schedule")),
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
                          Icon(
                            Icons.pending_actions,
                            color: Colors.black38,
                            size: fontSize,
                          ),
                          Column(
                            children: [
                              Container(
                                child: Text(
                                  "Create a schedule or request a schedule from another user",
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
                                  "Create Schedule",
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.height *
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
                              style:
                                  ElevatedButton.styleFrom(primary: themeColor),
                              child: Container(child: Text("Create Schedule")),
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
                            Expanded(
                              flex: 2,
                              child: Container(
                                child: TextButton(
                                  child: Text(
                                    "Schedule",
                                    style: TextStyle(
                                        fontSize: currentPage != Pages.schedule
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
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 4, bottom: 4),
                              child: VerticalDivider(
                                //width: 30,
                                color: Colors.black26,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
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
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.grey[50],
                          padding:
                              EdgeInsets.only(top: 10, left: 10, right: 10),
                          child: currentPage == Pages.schedule
                              ? scheduleViewPage
                              : aboutPage,
                        ),
                      ),
                    ],
                  ),

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
  }

  @override
  bool get wantKeepAlive => true;
}

class Workout {
  Workout();
}
