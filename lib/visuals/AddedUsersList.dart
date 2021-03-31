import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Services/database.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:deeformity/User/otherProfile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deeformity/Shared/constants.dart';

class AddedUsers extends StatefulWidget {
  final bool sharingItem;
  final QueryDocumentSnapshot schedule;
  final List<QueryDocumentSnapshot> schedulesExercises;
  AddedUsers({this.sharingItem, this.schedule, this.schedulesExercises});
  @override
  _AddedUsersState createState() => _AddedUsersState();
}

class _AddedUsersState extends State<AddedUsers> {
  List<QueryDocumentSnapshot> userToShareSchedule = [];

  String textBoxquery;

  void shareSchedule() {
    Future.forEach(userToShareSchedule, (user) async {
      await DatabaseService(uid: UserSingleton.userSingleton.userID)
          .shareSchedule(
              userDoc: user,
              schedule: widget.schedule,
              schedulesExercises: widget.schedulesExercises);
    });
  }

  void markUser(QueryDocumentSnapshot doc) {
    //messy code clean up during optimization
    bool add = true;
    userToShareSchedule.forEach((element) {
      if (element.id == doc.id) add = false;
    });
    if (add) {
      userToShareSchedule.add(doc);
    } else {
      userToShareSchedule.remove(doc);
    }
    setState(() {});
  }

  void openUserCard(QueryDocumentSnapshot doc) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return OtherUserProfile(doc);
    }));
  }

  Widget createUserCard(QueryDocumentSnapshot doc) {
    bool markedForShare = false;
    String firstName = doc.data()["First Name"] ?? "Error";
    String lastName = doc.data()["Last Name"] ?? "Error";
    String profession = doc.data()["Profession"] ?? "Private user";
    String userFullName = firstName + " " + lastName;

    userToShareSchedule.forEach((element) {
      if (element.id == doc.id) markedForShare = true;
    });

    //Fliters displayed users according to textForm input
    if (textBoxquery != null && textBoxquery.isNotEmpty) {
      int iterationPos = 0;
      for (var s in textBoxquery.characters) {
        if (s.toUpperCase() != userFullName[iterationPos].toUpperCase())
          return SizedBox();
        iterationPos += 1;
      }
    }

    //create card
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: InkWell(
        child: Card(
          color: markedForShare ? Colors.blue[200] : null,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Container(
            child: ListTile(
              leading: CircleAvatar(),
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
                      profession,
                      style: TextStyle(
                          color: Color.fromRGBO(21, 33, 47, 1),
                          fontWeight: FontWeight.w300,
                          fontSize: 12),
                    )
                  ]),
            ),
          ),
        ),
        onTap: markedForShare
            ? () {
                markUser(doc);
              }
            : () {
                openUserCard(doc);
              },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                child: widget.sharingItem
                    ? TextButton(
                        onPressed: shareSchedule,
                        child: Row(
                          children: [
                            Icon(Icons.offline_share, color: Colors.blue),
                            Text("Share")
                          ],
                        ),
                      )
                    : null,
              ),
            ],
          ),
          Container(
            child: Column(
              children: [
                TextFormField(
                  decoration: textInputDecorationWhite.copyWith(
                    prefixIcon: Icon(
                      CupertinoIcons.search,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      textBoxquery = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(
                top: 10,
              ),
              child: ListView(
                children: UserSingleton.userSingleton.addedUsers
                    .map((doc) => createUserCard(doc))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
