import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Services/database.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:deeformity/visuals/ExercisePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExerciseList extends StatefulWidget {
  final DaysOfTheWeek dayEnum;
  final QueryDocumentSnapshot scheduleDoc;
  final bool horizontalLayout;
  ExerciseList({
    @required this.dayEnum,
    @required this.scheduleDoc,
    this.horizontalLayout = false,
  });
  @override
  _ExerciseListState createState() => _ExerciseListState();
}

class _ExerciseListState extends State<ExerciseList> {
  void openExerciseCard(QueryDocumentSnapshot doc) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ExercisePage(
        documentSnapshot: doc,
        key: Key(doc.id),
      );
    }));
  }

  void deleteExercise(QueryDocumentSnapshot doc) async {
    // String mediaURl = doc["MediaURL"];
    // if (mediaURl != null && mediaURl.isNotEmpty) {
    //   await DatabaseService(uid: UserSingleton.userSingleton.userID)
    //       .deleteMedia(mediaURl);
    // }
    // String mediaPath = doc["MediaPath"];
    // if (mediaPath != null && mediaPath.isNotEmpty) {
    //   await DatabaseService().deleteMedia(mediaPath);
    // }
    await DatabaseService(uid: UserSingleton.userSingleton.userID)
        .deleteRoutine(doc: doc, dayEnum: widget.dayEnum);
  }

  Widget createExerciseCard(QueryDocumentSnapshot doc) {
    List<int> days = List.from(doc["Days"]) ?? [];
    if (days.contains(widget.dayEnum.index) &&
        doc["Schedule Id"] == widget.scheduleDoc.id) {
      return Container(
        child: InkWell(
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromRGBO(47, 72, 100, 1),
                        Color.fromRGBO(24, 41, 57, 1)
                      ])),
              child: ListTile(
                title: Text(
                  doc["Name"] ?? "Error Name",
                  style: TextStyle(color: Colors.white),
                ),
                trailing:
                    doc["Creator Id"] == UserSingleton.userSingleton.userID
                        ? IconButton(
                            icon: Icon(
                              CupertinoIcons.delete,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              deleteExercise(doc);
                            },
                          )
                        : SizedBox(),
              ),
            ),
          ),
          onTap: () {
            openExerciseCard(doc);
          },
        ),
      );
    } else {
      return SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: DatabaseService(uid: widget.scheduleDoc["Creator Id"])
            .routines(scheduleId: widget.scheduleDoc.id),
        builder: (context, snapshot) {
          if ((snapshot != null && snapshot.data != null) &&
              (snapshot.data.docs != null && snapshot.data.docs.isNotEmpty)) {
            return Center(
              child: widget.horizontalLayout
                  ? ListView(
                      scrollDirection: Axis.horizontal,
                      children: snapshot.data.docs
                          .map((doc) => createExerciseCard(doc))
                          .toList(),
                    )
                  : Column(
                      children: snapshot.data.docs
                          .map((doc) => createExerciseCard(doc))
                          .toList(),
                    ),
            );
          } else {
            return Center(
              child: widget.horizontalLayout
                  ? ListView(
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
            );
          }
        });
  }
}
