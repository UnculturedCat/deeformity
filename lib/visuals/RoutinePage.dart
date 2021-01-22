import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Shared/constants.dart';

class RoutinePage extends StatefulWidget {
  final QueryDocumentSnapshot documentSnapshot;
  RoutinePage(this.documentSnapshot);
  @override
  _RoutinePageState createState() => _RoutinePageState(documentSnapshot);
}

class _RoutinePageState extends State<RoutinePage> {
  QueryDocumentSnapshot docSnapshot;
  _RoutinePageState(this.docSnapshot);
  @override
  Widget build(BuildContext context) {
    String title = docSnapshot.data()["Name"];
    String description = docSnapshot.data()["Description"];
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: Color.fromRGBO(21, 33, 47, 15),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        decoration: gradientDecoration,
        child: ListView(children: [
          Container(
            padding: EdgeInsets.only(top: 20),
            child: Text("Description",
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.white,
                )),
          ),
          Container(
            child: Divider(
              color: Colors.white,
            ),
          ),
          Container(
            child: Text(description,
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w300)),
          )
        ]),
      ),
    );
  }
}
