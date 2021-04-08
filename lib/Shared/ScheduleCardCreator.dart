import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:deeformity/Services/database.dart';

class ScheduleCard extends StatelessWidget {
  final DocumentSnapshot scheduleDoc;
  final DocumentSnapshot creatorDoc;
  ScheduleCard({this.scheduleDoc, this.creatorDoc});

  Future<DocumentSnapshot> getCreatorDoc() async {
    return await DatabaseService()
        .getParticularUserDoc(scheduleDoc.data()["Creator Id"]);
  }

  @override
  Widget build(BuildContext context) {
    String name = scheduleDoc.data()["Name"];
    String description = scheduleDoc.data()["Description"] ?? "No description";
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Container(
        child: ListTile(
          contentPadding: EdgeInsets.all(20),
          trailing: CircleAvatar(
            child: creatorDoc.data()["Profile Picture Url"] == null
                ? Text(creatorDoc.data()["First Name"][0])
                : null,
            backgroundImage: creatorDoc.data()["Profile Picture Url"] != null
                ? NetworkImage(creatorDoc.data()["Profile Picture Url"])
                : null,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: Color.fromRGBO(21, 33, 47, 1),
                ),
              ),
            ],
          ),
          subtitle: Text(
            description,
            style: TextStyle(
              color: Color.fromRGBO(21, 33, 47, 1),
              fontWeight: FontWeight.w300,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
