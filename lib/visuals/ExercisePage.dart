import 'package:deeformity/Services/AppVideoPlayer.dart';
import 'package:deeformity/Services/database.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
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
  bool editingMedia = false;
  bool editingDescription = false;
  String description;
  final _formKey = GlobalKey<FormState>();
  var media;
  _ExercisePageState(this.docSnapshot);

  @override
  void initState() {
    super.initState();
  }

  void setDescription() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (description.isNotEmpty) {
        DatabaseService(uid: UserSingleton.userSingleton.userID)
            .updateRoutineField(
                doc: docSnapshot, field: "Description", value: description);
      }
    }
    setState(() {
      editingDescription = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String mediaURL = docSnapshot.data()["MediaURL"];
    int mediaTypeIndex = docSnapshot.data()["Media type"];
    bool correctedAspectRatio = docSnapshot.data()["CorrectVideo"] ?? false;

    if (mediaURL != null && mediaURL.isNotEmpty) {
      if (mediaTypeIndex != MediaType.none.index) {
        MediaType mediaType = MediaType.values[mediaTypeIndex];
        switch (mediaType) {
          case MediaType.photo:
            media = Image.network(mediaURL);
            break;
          case MediaType.video:
            appVideoPlayer = AppVideoPlayer(
              assetURL: mediaURL,
              assetSource: MediaAssetSource.network,
              flipHeightAndWidth: correctedAspectRatio,
            );
            break;
          case MediaType.textDocument:
            break;
          case MediaType.none:
            break;
        }
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        //centerTitle: false,
        title: Text(
          docSnapshot.data()["Name"] ?? "No name",
          style: pageHeaderStyle,
        ),
        backgroundColor: Color.fromRGBO(21, 33, 47, 15),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        decoration: gradientDecoration,
        child: ListView(
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.only(top: 20, bottom: 20),
                child: Text(
                  docSnapshot.data()["Name"] ?? "No name",
                  style: cardHeaderStyle,
                ),
              ),
            ),
            media != null || appVideoPlayer != null
                ? Container(
                    color: Colors.white,
                    alignment: Alignment.center,
                    height: 500,
                    child: media != null
                        ? media
                        : appVideoPlayer != null
                            ? appVideoPlayer
                            : SizedBox(),
                  )
                : SizedBox(),
            Container(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                "Description",
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              child: Divider(
                color: Colors.white,
              ),
            ),
            Container(
              child: editingDescription
                  ? Row(
                      //crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.70,
                          child: Form(
                            key: _formKey,
                            child: TextFormField(
                              maxLines: null,
                              minLines: 3,
                              decoration: textInputDecorationWhite.copyWith(
                                  hintText: "Description",
                                  hintStyle:
                                      TextStyle(fontSize: fontSizeInputHint)),
                              onSaved: (input) => description = input,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: setDescription,
                          child: Text("Done"),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          docSnapshot.data()["Description"] ?? "No description",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w300),
                        ),
                        Container(
                          child: docSnapshot.data()["Creator Id"] ==
                                  UserSingleton.userSingleton.userID
                              ? IconButton(
                                  icon: Icon(Icons.edit),
                                  iconSize: iconSizeBody,
                                  color: Colors.white,
                                  onPressed: () {
                                    setState(() {
                                      editingDescription = true;
                                    });
                                  },
                                )
                              : SizedBox(),
                        )
                      ],
                    ),
            ),
            SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }
}
