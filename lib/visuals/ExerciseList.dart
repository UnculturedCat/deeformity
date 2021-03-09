import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Services/database.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:deeformity/visuals/ExercisePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deeformity/Shared/constants.dart';

class ExerciseList extends StatefulWidget {
  @override
  _ExerciseListState createState() => _ExerciseListState();
}

class _ExerciseListState extends State<ExerciseList> {
  void openExerciseCard(QueryDocumentSnapshot doc) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ExercisePage(doc);
    }));
  }

  void deleteExercise(QueryDocumentSnapshot doc) async {
    String mediaURl = doc.data()["MediaURL"];
    if (mediaURl != null && mediaURl.isNotEmpty) {
      await DatabaseService(uid: UserSingleton.userSingleton.userID)
          .deleteMedia(mediaURl);
    }
    // String mediaPath = doc.data()["Media Path"];
    // if (mediaPath != null && mediaPath.isNotEmpty) {
    //   await DatabaseService().deleteMedia(mediaPath);
    // }
    await DatabaseService(uid: UserSingleton.userSingleton.userID)
        .deleteRoutine(doc);
  }

  Widget createExerciseCard(QueryDocumentSnapshot doc) {
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
                doc.data()["Name"],
                style: TextStyle(color: Colors.white),
              ),
              trailing:
                  doc.data()["User Id"] == UserSingleton.userSingleton.userID
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
  }

  @override
  Widget build(BuildContext context) {
    final exercises = Provider.of<QuerySnapshot>(context);
    if ((exercises != null && exercises.docs != null) &&
        exercises.docs.isNotEmpty) {
      return Column(
        children: exercises.docs.map((doc) => createExerciseCard(doc)).toList(),
      );
    } else {
      return Center(
          child: Text(
        "No exercises for the day \n Add exercise",
        textAlign: TextAlign.center,
      ));
    }
  }
}
