import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Shared/constants.dart';

class ExercisePage extends StatefulWidget {
  final QueryDocumentSnapshot documentSnapshot;
  ExercisePage(this.documentSnapshot);
  @override
  _ExercisePageState createState() => _ExercisePageState(documentSnapshot);
}

class _ExercisePageState extends State<ExercisePage> {
  QueryDocumentSnapshot docSnapshot;
  var media;
  _ExercisePageState(this.docSnapshot);
  @override
  Widget build(BuildContext context) {
    String title = docSnapshot.data()["Name"];
    String description = docSnapshot.data()["Description"];
    String mediaURL = docSnapshot.data()["MediaURL"];
    if (mediaURL != null && mediaURL.isNotEmpty) {
      media = Image.network(mediaURL);
    }
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
          Center(
            child: Container(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              child: Text(
                title,
                style: cardHeaderStyle,
              ),
            ),
          ),
          Container(
            height: 400,
            child: Center(
              child: media,
            ),
          ),
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
