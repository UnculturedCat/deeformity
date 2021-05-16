import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/visuals/AboutSchedule.dart';
import 'package:flutter/material.dart';
import 'package:deeformity/Shared/constants.dart';

class SchedulePage extends StatefulWidget {
  final DocumentSnapshot scheduleDoc;
  SchedulePage(this.scheduleDoc);
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
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
            widget.scheduleDoc.data()["Name"] ?? "Schedule",
            style: pageHeaderStyle,
          ),
        ),
        backgroundColor: Colors.white,
        body: Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: AboutSchedulePage(widget.scheduleDoc)),
      ),
    );
  }
}
