import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:deeformity/visuals/Profile.dart';
import 'package:deeformity/visuals/RoutinePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:deeformity/Shared/constants.dart';

class RoutineList extends StatefulWidget {
  final ActivityType activityType;
  RoutineList(this.activityType);
  @override
  _RoutineListState createState() => _RoutineListState(this.activityType);
}

class _RoutineListState extends State<RoutineList> {
  String category;
  _RoutineListState(ActivityType activityType) {
    if (activityType == ActivityType.fitness) {
      category = "Fitness";
    } else if (activityType == ActivityType.physio) {
      category = "Physio";
    } else if (activityType == ActivityType.personal) {
      category = "Personal";
    }
  }

  void openCard(QueryDocumentSnapshot doc) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => RoutinePage(doc)));
  }

  Widget createRoutineCard(QueryDocumentSnapshot doc) {
    //String cardId = doc.data()["Card Id"];
    String sets = doc.data()["Sets"].toString();
    String reps = doc.data()["Reps"].toString();
    String name = doc.data()["Name"];
    if ((UserSingleton.userSingleton.selectedStringDate == doc.data()["Date"] ||
            doc.data()["Frequency"] == RepeatFrequency.daily.index ||
            (doc.data()["Frequency"] == RepeatFrequency.weekly.index &&
                DateFormat.EEEE()
                        .format(DateTime.parse(doc.data()["DateTime"])) ==
                    DateFormat.EEEE()
                        .format(UserSingleton.userSingleton.dateTime))) &&
        doc.data()["Category"] == category) {
      return Container(
        padding: EdgeInsets.only(top: 10, left: 20, right: 20),
        child: InkWell(
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Container(
              padding: EdgeInsets.only(bottom: 30),
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
              child: Column(
                children: [
                  ListTile(
                    trailing: Icon(
                      Icons.fitness_center,
                      color: Colors.white,
                    ),
                    title: Text(
                      name,
                      style: cardHeaderStyle,
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
                        Text(
                          "Sets: $sets",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w300),
                        ),
                        Text("Reps: $reps",
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w300))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            openCard(doc);
          },
          //on
        ),
      );
    }
    return SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    final routines = Provider.of<QuerySnapshot>(context);
    if (routines != null) {
      if (routines.docs != null) {
        return Column(
            children:
                routines.docs.map((doc) => createRoutineCard(doc)).toList());
      } else {
        return SizedBox();
      }
    } else {
      return SizedBox();
    }
  }
}
