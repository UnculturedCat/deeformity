import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Services/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:deeformity/Shared/ScheduleCardCreator.dart';

class AddedSchedules extends StatefulWidget {
  final DocumentSnapshot userDoc;
  AddedSchedules(this.userDoc);
  @override
  _AddedSchedulesState createState() => _AddedSchedulesState();
}

class _AddedSchedulesState extends State<AddedSchedules> {
  List<QueryDocumentSnapshot> addedSchedules = [];
  List<Widget> scheduleCards = [];
  bool cardsCreated = false;

  @override
  void initState() {
    DatabaseService(uid: widget.userDoc.id).addedSchedules.listen((event) {
      scheduleCards = [];
      addedSchedules = event.docs;
      event.docs.forEach((element) {
        createScheduleCard(element);
      });
    });
    super.initState();
  }

  void openScheduleCard(QueryDocumentSnapshot doc) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) {
    //       return OtherUserProfile(doc);
    //     },
    //   ),
    // );
  }

  Future<DocumentSnapshot> getCreatorDoc(QueryDocumentSnapshot doc) async {
    return await DatabaseService()
        .getParticularUserDoc(doc.data()["Creator Id"]);
  }

  void createScheduleCard(QueryDocumentSnapshot doc) {
    if (mounted) {
      getCreatorDoc(doc).then(
        (value) {
          scheduleCards.add(
            InkWell(
              child: ScheduleCard(scheduleDoc: doc, creatorDoc: value),
              onTap: () {
                openScheduleCard(doc);
              },
            ),
          );
          if (scheduleCards.length == addedSchedules.length) {
            setState(() {
              cardsCreated = true;
            });
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
              child: Text(
                "Whoops, you have no schedules.",
                style: TextStyle(
                  color: Colors.black38,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
    );
  }
}
