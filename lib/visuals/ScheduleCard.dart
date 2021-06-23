import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:flutter/material.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ScheduleCard extends StatefulWidget {
  final ActivityType activityType;

  ScheduleCard(this.activityType);

  @override
  State<StatefulWidget> createState() {
    return ScheduleCardState(this.activityType);
  }
}

class ScheduleCardState extends State<ScheduleCard> {
  String category = "unknown";
  // String eventsName;
  final ActivityType activityType;
  //ScheduleData scheduleData;
  // int numberOfRoutines;
  // int numberOfVideoSessions;
  int numberOfActivities = 0;

  ScheduleCardState(this.activityType) {
    if (activityType == ActivityType.fitness) {
      category = "Fitness";
    } else if (activityType == ActivityType.physio) {
      category = "Physio";
    } else if (activityType == ActivityType.personal) {
      category = "Personal";
    }
  }

  void initialCardValues(QuerySnapshot scheduleSnapShot) {
    numberOfActivities = 0;
    for (var doc in scheduleSnapShot.docs) {
      if ((doc["Date"] == UserSingleton.userSingleton.selectedStringDate ||
              doc["Frequency"] == RepeatFrequency.daily.index ||
              (doc["Frequency"] == RepeatFrequency.weekly.index &&
                  DateFormat.EEEE().format(DateTime.parse(doc["DateTime"])) ==
                      DateFormat.EEEE()
                          .format(UserSingleton.userSingleton.dateTime))) &&
          doc["Category"] == category) numberOfActivities++;
    }
  }

  Widget createScheduleCard() {
    return Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    //colors: [Colors.lightBlue, Colors.blueGrey]
                    colors: [
                      Color.fromRGBO(47, 72, 100, 1),
                      Color.fromRGBO(24, 41, 57, 1)
                    ])),
            child: Container(
              padding: EdgeInsets.only(bottom: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    // trailing: CircleAvatar(
                    //   child: Text(
                    //     "P",
                    //     style: TextStyle(fontSize: 15, color: Colors.white),
                    //   ),
                    //   radius: 20,
                    // ),
                    trailing: activityType == ActivityType.fitness
                        ? Icon(Icons.fitness_center,
                            size: 30, color: Colors.white)
                        : Icon(Icons.accessibility,
                            size: 30, color: Colors.white),
                    title: Text(
                      category,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      right: 20,
                      left: 18,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text("$numberOfActivities Activities",
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w300))
                      ],
                    ),
                  ),
                ],
              ),
            )));
  }

  Widget build(BuildContext build) {
    final scheduleSnapShot = Provider.of<QuerySnapshot>(context);
    if (scheduleSnapShot != null) initialCardValues(scheduleSnapShot);
    return createScheduleCard();
  }
}
