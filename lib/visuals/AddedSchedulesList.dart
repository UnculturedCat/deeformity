import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Services/database.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:deeformity/visuals/SchedulePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:deeformity/Shared/ScheduleCardCreator.dart';

class AddedSchedules extends StatefulWidget {
  final String userDocID;
  final Function cardFunction;
  AddedSchedules(this.userDocID, {this.cardFunction});
  @override
  _AddedSchedulesState createState() => _AddedSchedulesState();
}

class _AddedSchedulesState extends State<AddedSchedules> {
  List<QueryDocumentSnapshot> addedSchedules = [];
  List<Widget> scheduleCards = [];
  bool cardsCreated = false;

  @override
  void initState() {
    DatabaseService(uid: widget.userDocID).addedSchedules.listen((event) {
      scheduleCards = [];
      addedSchedules = event.docs;
      event.docs.forEach((element) {
        createScheduleCard(element);
      });
      if (event.docs.isEmpty && mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    DatabaseService(uid: widget.userDocID)
        .addedSchedules
        .listen((event) {})
        .cancel();
    super.dispose();
  }

  void openScheduleCard({
    DocumentSnapshot scheduleDoc,
    DocumentSnapshot creatorDoc,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return SchedulePage(
            scheduleDoc,
          );
        },
      ),
    );
  }

  Future<DocumentSnapshot> getCreatorDoc(QueryDocumentSnapshot doc) async {
    return await DatabaseService(uid: UserSingleton.userSingleton.userID)
        .getParticularUserDoc(doc.data()["Creator Id"]);
  }

  void callExternalFunction(QueryDocumentSnapshot doc) {
    widget.cardFunction(doc);
    Navigator.pop(context);
  }

  void createScheduleCard(QueryDocumentSnapshot doc) {
    if (mounted) {
      getCreatorDoc(doc).then(
        (value) {
          scheduleCards.add(
            InkWell(
              child: ScheduleCard(scheduleDoc: doc, creatorDoc: value),
              onTap: () {
                widget.cardFunction != null
                    ? callExternalFunction(doc)
                    : openScheduleCard(scheduleDoc: doc, creatorDoc: value);
              },
            ),
          );
          if (scheduleCards.length == addedSchedules.length) {
            if (mounted) {
              setState(() {
                cardsCreated = true;
              });
            }
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: addedSchedules.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(
                      top: 10,
                    ),
                    child: scheduleCards.isEmpty
                        ? Text(
                            "Fetching added schedules.",
                            style: TextStyle(
                              color: Colors.black38,
                              fontSize: fontSize,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          )
                        : ListView(
                            children: scheduleCards,
                          ),
                  ),
                ),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pending_actions,
                    color: Colors.black38,
                    size: fontSize,
                  ),
                  Text(
                    "Whoops, nothing to see here.",
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }
}
