import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:deeformity/Services/database.dart';
import 'package:deeformity/visuals/AddExercisePage.dart';
import 'package:flutter/material.dart';
import 'package:deeformity/DataManager/Utility.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:provider/provider.dart';
import 'package:deeformity/visuals/RoutineList.dart';

class SchedulePage extends StatefulWidget {
  final ScheduleData scheduleData;
  final ActivityType activityType;
  SchedulePage(this.scheduleData, this.activityType);
  @override
  State<StatefulWidget> createState() {
    return SchedulePageState(activityType);
  }
}

class SchedulePageState extends State<SchedulePage> {
  String date = UserSingleton.userSingleton.selectedDate;
  String pageTitle;
  String category;
  final ActivityType activityType;
  SchedulePageState(this.activityType) {
    if (activityType == ActivityType.fitness) {
      pageTitle = "Fitness Schedule: " + date;
      category = "Fitness";
    } else if (activityType == ActivityType.physio) {
      pageTitle = "Physio Schedule: " + date;
      category = "Physio";
    } else if (activityType == ActivityType.personal) {
      pageTitle = "Personal Fitness: " + date;
    }
  }
  // void updateSchedule() async {
  //   await DatabaseService(uid: UserSingleton.userSingleton.currentUSer.uid)
  //       .updateSchedule();
  // }

  void openCreateExercisePage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddExercisePage(activityType);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<QuerySnapshot>.value(
      value: DatabaseService().schedule,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            pageTitle,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          backgroundColor: Color.fromRGBO(21, 33, 47, 15),
          actions: <Widget>[
            //IconButton(icon: Icon(Icons.settings), color: Colors.white,iconSize: 30, onPressed: handleGoToSettings),
          ],
        ),
        body: Center(
            //padding: EdgeInsets.all(40),
            child: ListView(
          children: [
            Container(
              padding: EdgeInsets.only(top: 20),
              child: RoutineList(activityType),
            ),
            Container(
              padding: EdgeInsets.only(top: 20, right: 20, left: 20),
              child: FloatingActionButton.extended(
                  label: Text(
                    "Add exercise",
                    style: TextStyle(
                        color: Colors.white, fontSize: fontSizeButton),
                  ),
                  backgroundColor: Color.fromRGBO(27, 98, 49, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                  ),
                  onPressed: () {
                    openCreateExercisePage();
                  }),
            ),
            //FloatingActionButton(onPressed: null)
          ],
        )),
      ),
    );
  }
}
