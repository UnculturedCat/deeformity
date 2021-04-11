import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/User/otherProfile.dart';
import 'package:flutter/material.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:deeformity/Shared/UserCardCreator.dart';
import 'package:deeformity/Shared/infoSingleton.dart';

class SchedulePage extends StatefulWidget {
  final DocumentSnapshot creatorDoc;
  final DocumentSnapshot scheduleDoc;
  SchedulePage({this.creatorDoc, this.scheduleDoc});
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  void openCreatorPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return OtherUserProfile(widget.creatorDoc);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          //centerTitle: false,
          backgroundColor: Colors.white,
          shadowColor: Colors.white24,
          iconTheme: IconThemeData(color: elementColorWhiteBackground),
          title: Text(
            "Schedule",
            style: pageHeaderStyle,
          ),
        ),
        backgroundColor: Colors.white,
        body: Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              Container(
                child: Column(
                  children: [
                    Text("Created by"),
                    widget.creatorDoc.id == UserSingleton.userSingleton.userID
                        ? Text("You")
                        : InkWell(
                            child: UserCardCreator(
                              userDoc: widget.creatorDoc,
                            ),
                            onTap: openCreatorPage,
                          )
                  ],
                ),
              ),
              Divider(
                color: Colors.black26,
              ),
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      widget.scheduleDoc.data()["Description"] ??
                          "No schedule Description",
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        color: elementColorWhiteBackground,
                        fontSize: fontSizeBody,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
