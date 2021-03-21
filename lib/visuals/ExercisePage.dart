import 'package:deeformity/Services/AppVideoPlayer.dart';
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
  AppVideoPlayer appVideoPlayer;
  var media;
  _ExercisePageState(this.docSnapshot);
  @override
  Widget build(BuildContext context) {
    String title = docSnapshot.data()["Name"];
    String description = docSnapshot.data()["Description"];
    String mediaURL = docSnapshot.data()["MediaURL"];
    int mediaTypeIndex = docSnapshot.data()["Media type"] ?? 15;
    if (mediaURL != null && mediaURL.isNotEmpty) {
      if (mediaTypeIndex != 15) {
        MediaType mediaType = MediaType.values[mediaTypeIndex];
        switch (mediaType) {
          case MediaType.photo:
            media = Image.network(mediaURL);
            break;
          case MediaType.video:
            appVideoPlayer = AppVideoPlayer(
              assetURL: mediaURL,
              assetSource: MediaAssetSource.network,
            );
            break;
          case MediaType.textDocument:
            break;
        }
      }
    }
    return Scaffold(
      appBar: AppBar(
        //centerTitle: false,
        title: Text(
          title,
          style: pageHeaderStyle,
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
          media != null || appVideoPlayer != null
              ? Container(
                  color: Colors.white,
                  alignment: Alignment.center,
                  height: 400,
                  child: media != null
                      ? media
                      : appVideoPlayer != null
                          ? appVideoPlayer
                          : SizedBox(),
                )
              : SizedBox(),
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
