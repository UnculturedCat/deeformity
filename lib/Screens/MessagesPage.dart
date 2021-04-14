import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Services/database.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:deeformity/Messages/UserMessages.dart';
import 'package:flutter/material.dart';
import 'package:deeformity/Shared/UserCardCreator.dart';

class MessagesPage extends StatefulWidget {
  MessagesPage();

  State<StatefulWidget> createState() {
    return MessagesPageState();
  }
}

class MessagesPageState extends State<MessagesPage> {
  List<Widget> correspondenceCards = [];
  List<DocumentSnapshot> allMessageUsers = [];
  bool cardsCreated = false;
  @override
  void initState() {
    DatabaseService(uid: UserSingleton.userSingleton.userID)
        .messagesUsers
        .listen((snapShot) {
      initializeCorrespondenceCards(snapShot);
    });
    super.initState();
  }

  Future<DocumentSnapshot> getUserDoc(DocumentSnapshot doc) async {
    return await DatabaseService(uid: UserSingleton.userSingleton.userID)
        .getParticularUserDoc(doc.id);
  }

  void initializeCorrespondenceCards(QuerySnapshot snapshot) {
    if (mounted) {
      if (snapshot != null && snapshot.docs != null) {
        allMessageUsers = snapshot.docs;
        correspondenceCards = []; //clear all cards

        snapshot.docs.forEach((doc) {
          getUserDoc(doc).then(
            (value) {
              correspondenceCards.add(
                InkWell(
                  child: UserCardCreator(
                    userDoc: value,
                  ),
                  onTap: () {
                    openMessages(value);
                  },
                ),
              );
              if (allMessageUsers.length == correspondenceCards.length) {
                setState(() {
                  cardsCreated = true;
                });
              }
            },
          );
        });
      }
    }
  }

  void openMessages(DocumentSnapshot userDoc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return UserMessagesPage(userDoc);
        },
      ),
    );
  }

  MessagesPageState();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //centerTitle: false,
        backgroundColor: Colors.white,
        shadowColor: Colors.white24,
        iconTheme: IconThemeData(color: elementColorWhiteBackground),
        title: Text(
          "Messages",
          style: pageHeaderStyle,
        ),
      ),
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: allMessageUsers.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: correspondenceCards.isNotEmpty
                          ? ListView(
                              children: correspondenceCards,
                            )
                          : Text(
                              "Fetching messages.",
                              style: TextStyle(
                                color: Colors.black38,
                                fontSize: fontSize,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ))
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pending_actions,
                      color: Colors.black38,
                      size: fontSize,
                    ),
                    Text(
                      "Whoops, nothing to see here.",
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
