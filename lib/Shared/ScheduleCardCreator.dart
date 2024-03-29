import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:flutter/material.dart';
import 'package:deeformity/Services/database.dart';

class ScheduleCard extends StatelessWidget {
  final DocumentSnapshot scheduleDoc;
  final DocumentSnapshot creatorDoc;
  ScheduleCard({this.scheduleDoc, this.creatorDoc});

  Future<DocumentSnapshot> getCreatorDoc() async {
    return await DatabaseService(uid: UserSingleton.userSingleton.userID)
        .getParticularUserDoc(scheduleDoc["Creator Id"]);
  }

  @override
  Widget build(BuildContext context) {
    Map<dynamic, dynamic> docMap = scheduleDoc.data() as Map;
    Map<dynamic, dynamic> creatorDocMap = creatorDoc.data() as Map;
    String name = docMap["Name"];
    String description = docMap["Header"] ?? "No description";
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Container(
        child: ListTile(
          contentPadding: EdgeInsets.all(20),
          trailing: CircleAvatar(
            child: creatorDocMap["Profile Picture Url"] == null
                ? Text(creatorDocMap["First Name"][0])
                : null,
            backgroundImage: creatorDocMap["Profile Picture Url"] != null
                ? NetworkImage(creatorDocMap["Profile Picture Url"])
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
