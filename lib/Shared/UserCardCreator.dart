import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserCardCreator extends StatelessWidget {
  final DocumentSnapshot userDoc;
  final bool mark;
  UserCardCreator({this.userDoc, this.mark = false});
  @override
  Widget build(BuildContext context) {
    if (userDoc.data() == null) {
      return Card(
        color: mark == true ? Colors.blue[200] : null,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Container(
          child: ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "MISSING USER",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    String firstName = userDoc.data()["First Name"];
    String lastName = userDoc.data()["Last Name"];
    String userName = userDoc.data()["User Name"] ?? "Private user";
    String userFullName = firstName + " " + lastName;
    return Card(
      elevation: 5,
      color: mark == true ? Colors.blue[200] : null,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Container(
        child: ListTile(
          leading: CircleAvatar(
            child: userDoc.data()["Profile Picture Url"] == null
                ? Text(userDoc.data()["First Name"][0])
                : null,
            backgroundImage: userDoc.data()["Profile Picture Url"] != null
                ? NetworkImage(userDoc.data()["Profile Picture Url"])
                : null,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userFullName,
                style: TextStyle(
                  color: Color.fromRGBO(21, 33, 47, 1),
                ),
              ),
              Text(
                userName,
                style: TextStyle(
                    color: Color.fromRGBO(21, 33, 47, 1),
                    fontWeight: FontWeight.w300,
                    fontSize: 12),
              )
            ],
          ),
        ),
      ),
    );
  }
}
