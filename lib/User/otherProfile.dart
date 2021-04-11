import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Services/database.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:deeformity/visuals/AddedSchedulesList.dart';
import 'package:deeformity/visuals/createMessagePage.dart';
import 'package:flutter/material.dart';
import 'package:deeformity/Shared/constants.dart';

class OtherUserProfile extends StatefulWidget {
  final DocumentSnapshot userDoc;
  OtherUserProfile(this.userDoc);
  @override
  _OtherUserProfileState createState() => _OtherUserProfileState(this.userDoc);
}

class _OtherUserProfileState extends State<OtherUserProfile> {
  List<DocumentSnapshot> usersConnections = [];
  QuerySnapshot connectionsSnapShot;
  DocumentSnapshot userDoc;

  _OtherUserProfileState(DocumentSnapshot doc) {
    userDoc = doc;
  }

  void connectWithUser() {
    DatabaseService(uid: UserSingleton.userSingleton.userID)
        .connectWithUser(userDoc);
  }

  void disconnectWithUser() {
    DatabaseService(uid: UserSingleton.userSingleton.userID)
        .disconnectWithUser(userDoc);
  }

  @override
  void initState() {
    DatabaseService(uid: widget.userDoc.id).addedUsersSnapShot.listen((event) {
      connectionsSnapShot = event;
      usersConnections = event.docs;
      setState(() {});
    });
    DatabaseService(uid: widget.userDoc.id).anyUserData.listen((event) {
      userDoc = event;
      setState(() {});
    });
    super.initState();
  }

  bool isUserAdded(QuerySnapshot snapshot) {
    bool userAdded = false;
    snapshot.docs.forEach((doc) {
      if (UserSingleton.userSingleton.userID == doc.id) {
        userAdded = true;
      }
    });
    return userAdded;
  }

  void getUsersConnections() {
    DatabaseService(uid: UserSingleton.userSingleton.userID)
        .usersCollection
        .doc(userDoc.id)
        .collection(
            DatabaseService(uid: UserSingleton.userSingleton.userID).addedUsers)
        .get()
        .then((value) {
      setState(() {
        usersConnections = value.docs; //this
      });
    });
  }

  void openCreateMessagePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return CreateMessage(widget.userDoc);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          userDoc.data()["First Name"] ?? "Error Name",
          style: TextStyle(color: elementColorWhiteBackground),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: elementColorWhiteBackground,
        ),
        actions: [
          Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: connectionsSnapShot != null
                ? isUserAdded(connectionsSnapShot)
                    ? Row(
                        children: [
                          TextButton(
                            onPressed: disconnectWithUser,
                            child: Text(
                              "Disconnect",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          TextButton(
                            onPressed: connectWithUser,
                            child: Text(
                              "Connect",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      )
                : SizedBox(),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    child: CircleAvatar(
                      radius: 50,
                      child: userDoc.data()["Profile Picture Url"] == null
                          ? Text(userDoc.data()["First Name"][0])
                          : null,
                      backgroundImage: userDoc.data()["Profile Picture Url"] !=
                              null
                          ? NetworkImage(userDoc.data()["Profile Picture Url"])
                          : null,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          userDoc.data()["First Name"],
                          style: TextStyle(
                            color: elementColorWhiteBackground,
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          userDoc.data()["Last Name"],
                          style: TextStyle(
                            color: elementColorWhiteBackground,
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            usersConnections != null
                                ? Text(
                                    usersConnections.length.toString(),
                                    style: TextStyle(
                                      color: elementColorWhiteBackground,
                                      fontSize: fontSize,
                                    ),
                                  )
                                : SizedBox(),
                            Icon(Icons.people)
                          ],
                        ),
                        Container(
                          child: InkWell(
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(right: 5),
                                  child: Icon(
                                    Icons.send,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  "Message",
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                )
                              ],
                            ),
                            onTap: openCreateMessagePage,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
              child: Row(
                children: [
                  userDoc.data()["About"] != null
                      ? Expanded(
                          child: Text(userDoc.data()["About"],
                              style: TextStyle(
                                color: elementColorWhiteBackground,
                                fontSize: fontSizeBody,
                              ),
                              textAlign: TextAlign.justify),
                        )
                      : Text(
                          "Who am I,\nwhat am I,\nWhere am I?",
                          style: TextStyle(
                            color: elementColorWhiteBackground,
                            fontSize: fontSizeBody,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                ],
              ),
            ),
            Divider(
              color: Colors.black26,
            ),
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    child: Text(
                      "Schedules",
                      style: TextStyle(fontSize: fontSize, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AddedSchedules(userDoc),
            ),
          ],
        ),
      ),
    );
  }
}
