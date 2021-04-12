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
  String mediaURL;
  bool correctVideoAspectRatio = false;

  String description;
  final _formKey = GlobalKey<FormState>();
  var media;
  _ExercisePageState(this.docSnapshot);

  @override
  void initState() {
    mediaURL = docSnapshot.data()["MediaURL"];
    int mediaTypeIndex = docSnapshot.data()["Media type"];
    correctVideoAspectRatio = docSnapshot.data()["CorrectVideo"] ?? false;

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
              flipHeightAndWidth: correctVideoAspectRatio,
            );
            break;
          case MediaType.textDocument:
            break;
          case MediaType.none:
            break;
        }
      }
    }
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: elementColorWhiteBackground),
        //centerTitle: false,
        title: Text(
          docSnapshot.data()["Name"] ?? "No name",
          style: pageHeaderStyle,
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white24,
      ),
      body: Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: ListView(
          children: [
            SizedBox(
              height: 20,
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
            appVideoPlayer != null
                ? Container(
                    child: InkWell(
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(5),
                            child: Icon(
                              Icons.reset_tv,
                              color: Colors.blue,
                              size: 30,
                            ),
                          ),
                          Text(
                            "Fix Video",
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          )
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          correctVideoAspectRatio = !correctVideoAspectRatio;
                          appVideoPlayer = AppVideoPlayer(
                            assetSource: MediaAssetSource.network,
                            assetURL: mediaURL,
                            flipHeightAndWidth: correctVideoAspectRatio,
                          );
                        });
                        final snackBar = SnackBar(
                            content: Text("Video's aspect ratio corrected"));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      },
                    ),
                  )
                : SizedBox(),
            Container(
              padding: EdgeInsets.only(top: 30),
              child: Text(
                "Description",
                style: TextStyle(
                  fontSize: fontSize,
                  color: elementColorWhiteBackground,
                ),
              ),
            ),
            Container(
              child: Divider(
                color: elementColorWhiteBackground,
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
                              fontSize: fontSizeBody,
                              color: elementColorWhiteBackground,
                              fontWeight: FontWeight.w600),
                        ),
                        Container(
                          child: docSnapshot.data()["Creator Id"] ==
                                  UserSingleton.userSingleton.userID
                              ? IconButton(
                                  icon: Icon(Icons.edit),
                                  iconSize: iconSizeBody,
                                  color: elementColorWhiteBackground,
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
