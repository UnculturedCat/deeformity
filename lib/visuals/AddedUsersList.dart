import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Services/database.dart';
import 'package:deeformity/Shared/UserCardCreator.dart';
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
  bool search = false;
  List<QueryDocumentSnapshot> addedUsers = [];

  String textBoxquery;

  void shareSchedule() async {
    String message = "";
    await Future.forEach(userToShareSchedule, (user) async {
      String error =
          await DatabaseService(uid: UserSingleton.userSingleton.userID)
              .shareSchedule(
                  userDoc: user,
                  schedule: widget.schedule,
                  schedulesExercises: widget.schedulesExercises);

      if (error.isNotEmpty) {
        message = message + "!!" + error + "!!";
      }
    });
    if (message.isEmpty) message = "Shared successfully";
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    Navigator.pop(context);
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
        child: UserCardCreator(
          userDoc: doc,
          mark: markedForShare,
        ),
        onTap: widget.sharingItem
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
    return GestureDetector(
      child: StreamBuilder<QuerySnapshot>(
          stream: DatabaseService(uid: UserSingleton.userSingleton.userID)
              .addedUsersSnapShot,
          builder: (context, snapshot) {
            if ((snapshot != null && snapshot.data != null) &&
                snapshot.data.docs != null) {
              addedUsers = snapshot.data.docs;
            }
            return Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: addedUsers.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                          Icon(Icons.offline_share,
                                              color: Colors.blue),
                                          Text("Share")
                                        ],
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                        Container(
                          child: search
                              ? Column(
                                  children: [
                                    TextFormField(
                                      decoration:
                                          textInputDecorationWhite.copyWith(
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
                                )
                              : IconButton(
                                  icon: Icon(
                                    CupertinoIcons.search,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    setState(
                                      () {
                                        search = true;
                                      },
                                    );
                                  }),
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
                    )
                  : Center(
                      child: Text(
                        "Whoops, you have no connections.\nGo to the search page and make a new connection",
                        style: TextStyle(
                          color: Colors.black38,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
            );
          }),
      onTap: () {
        setState(() {
          search = false;
        });
      },
    );
  }
}
