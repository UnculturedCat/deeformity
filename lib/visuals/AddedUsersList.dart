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
  AddedUsers({this.sharingItem, this.schedule});
  @override
  _AddedUsersState createState() => _AddedUsersState();
}

class _AddedUsersState extends State<AddedUsers> {
  List<DocumentSnapshot> userToShareSchedule = [];
  bool search = false;
  List<DocumentSnapshot> addedUsers = [];
  List<DocumentSnapshot> addedUsersSnapshot = [];
  bool fullDetailsGotten = false;

  String textBoxquery;

  @override
  void dispose() {
    DatabaseService(uid: UserSingleton.userSingleton.userID)
        .addedUsersSnapShot
        .listen((snapShot) {})
        .cancel();
    super.dispose();
  }

  void shareSchedule() async {
    String message = "";
    await Future.forEach(userToShareSchedule, (user) async {
      String error =
          await DatabaseService(uid: UserSingleton.userSingleton.userID)
              .shareSchedule(
        userDoc: user,
        schedule: widget.schedule,
      );

      if (error.isNotEmpty) {
        message = message + "!!" + error + "!!";
      }
    });
    if (message.isEmpty) message = "Shared successfully";
    final snackBar = SnackBar(
      content: Text(
        message,
      ),
      duration: Duration(seconds: 10),
      // action: SnackBarAction(
      //   label: "DISMISS",
      //   onPressed: () {
      //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
      //   },
      // ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    Navigator.pop(context);
  }

  void markUser(DocumentSnapshot doc) {
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

  void openUserCard(DocumentSnapshot doc) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return OtherUserProfile(doc);
    }));
  }

  @override
  void initState() {
    if (mounted) {
      DatabaseService(uid: UserSingleton.userSingleton.userID)
          .addedUsersSnapShot
          .listen((snapShot) {
        addedUsers = [];
        addedUsersSnapshot = snapShot.docs;
        snapShot.docs.forEach((doc) {
          addeToAddedUsersList(doc);
        });
      });
    }
    super.initState();
  }

  Future<DocumentSnapshot> retreiveUserDocument(
      QueryDocumentSnapshot doc) async {
    return await DatabaseService(uid: UserSingleton.userSingleton.userID)
        .getParticularUserDoc(doc.id);
  }

  void addeToAddedUsersList(QueryDocumentSnapshot doc) async {
    retreiveUserDocument(doc).then((value) {
      addedUsers.add(value);
      if (addedUsers.length == addedUsersSnapshot.length) {
        if (mounted) {
          setState(() {
            fullDetailsGotten = true;
          });
        }
      }
    });
  }

  Widget createUserCard(DocumentSnapshot doc) {
    if (doc == null || doc.data() == null) {
      return SizedBox();
    }
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
      child: Container(
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
                      child: fullDetailsGotten
                          ? ListView(
                              children: addedUsers
                                  .map((doc) => createUserCard(doc))
                                  .toList(),
                            )
                          : Text(
                              "Fetching connections",
                              style: TextStyle(
                                color: Colors.black38,
                                fontSize: fontSize,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
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
      ),
      onTap: () {
        setState(() {
          search = false;
        });
      },
    );
  }
}
