import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Services/database.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:flutter/material.dart';
import 'package:deeformity/Shared/constants.dart';

class OtherUserProfile extends StatefulWidget {
  final DocumentSnapshot userDoc;
  OtherUserProfile(this.userDoc);
  @override
  _OtherUserProfileState createState() => _OtherUserProfileState();
}

class _OtherUserProfileState extends State<OtherUserProfile> {
  bool addedUser = true;

  void connectWithUser() {
    DatabaseService(uid: UserSingleton.userSingleton.userID)
        .connectWithUser(widget.userDoc);
  }

  void disconnectWithUser() {
    DatabaseService(uid: UserSingleton.userSingleton.userID)
        .disconnectWithUser(widget.userDoc);
  }

  bool isUserAdded(QuerySnapshot snapshot) {
    bool userAdded = false;
    snapshot.docs.forEach((doc) {
      if (widget.userDoc.id == doc.id) {
        userAdded = true;
      }
    });
    return userAdded;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: DatabaseService(uid: UserSingleton.userSingleton.userID)
            .addedUsersSnapShot,
        builder: (context, snapshot) {
          if (snapshot != null && snapshot.hasData) {
            addedUser = isUserAdded(snapshot.data);
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.userDoc.data()["First Name"]) ??
                  Text(
                    "Error Name",
                    style: TextStyle(color: elementColorWhiteBackground),
                  ),
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: elementColorWhiteBackground),
            ),
            body: Center(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: CircleAvatar(
                              child: widget.userDoc
                                          .data()["Profile Picture Url"] !=
                                      null
                                  ? null
                                  : Text(
                                      widget.userDoc.data()["First Name"][0]),
                              backgroundImage: widget.userDoc
                                          .data()["Profile Picture Url"] !=
                                      null
                                  ? NetworkImage(widget.userDoc
                                      .data()["Profile Picture Url"])
                                  : null,
                              radius: 40,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                child: addedUser
                                    ? Row(
                                        children: [
                                          TextButton(
                                            onPressed: disconnectWithUser,
                                            child: Text(
                                              "Disconnect",
                                              style:
                                                  TextStyle(color: Colors.blue),
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
                                              style:
                                                  TextStyle(color: Colors.blue),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                              Container(
                                child: Text(
                                  widget.userDoc.data()["First Name"] +
                                      "\n " +
                                      widget.userDoc.data()["Last Name"],
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
