import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deeformity/Services/database.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class AddExercisePage extends StatefulWidget {
  final String day;
  AddExercisePage(this.day);
  @override
  _AddExercisePageState createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {
  final _formKey = GlobalKey<FormState>();
  String cardId;
  String userId = UserSingleton.userSingleton.currentUSer.uid;
  String category;
  String workOutName;
  String description;
  String date = UserSingleton.userSingleton.selectedStringDate;
  DateTime dateTime = UserSingleton.userSingleton.dateTime;
  File _mediaFile;
  final ImagePicker _imagePicker = ImagePicker();
  Image picture;
  String mediaURL;
  String mediaStoragePath;
  bool working = false;

  _AddExercisePageState();
  void addExercise() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        working = true;
      });
      _formKey.currentState.save();

      Map<String, String> mediaFields;

      //store media in fireCloud
      if (_mediaFile != null) {
        mediaFields =
            await DatabaseService(uid: UserSingleton.userSingleton.userID)
                .storeMedia(_mediaFile, workOutName, MediaType.photo);
        mediaURL = mediaFields["downloadURL"];
        mediaStoragePath = mediaFields["fullPath"];
      }

      String cardDocId = await DatabaseService(
              uid: UserSingleton.userSingleton.currentUSer.uid)
          .createSchedule(
              cardId: cardId,
              userId: userId,
              workOutName: workOutName,
              description: description,
              day: widget.day,
              dateTime: dateTime.toString(),
              mediaURL: mediaURL,
              mediaStoragePath: mediaStoragePath);
      cardDocId.isNotEmpty
          ? Navigator.pop(context)
          : setState(() {
              working = false;
              showBottomSheet(
                  context: context,
                  builder: (context) {
                    return Center(child: Text("Could not create exercise"));
                  });
            });
    }
  }

  Future<void> attachPhoto(ImageSource source, BuildContext context) async {
    //open attach media page
    PickedFile selected = await _imagePicker.getImage(source: source);
    if (selected != null) {
      setState(() {
        _mediaFile = File(selected.path);
        picture = Image.file(_mediaFile);
      });
    }
    Navigator.pop(context);
  }

  Future<void> attachVideo(ImageSource source, BuildContext context) async {
    //open attach media page
    PickedFile selected = await _imagePicker.getVideo(source: source);
    if (selected != null) {
      setState(() {
        _mediaFile = File(selected.path);
        // picture = Image.file(_mediaFile);
      });
    }
    Navigator.pop(context);
  }

  void showMediaSelectionOption() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(10),
            child: Wrap(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: GestureDetector(
                    child: Row(children: [
                      //IconButton(icon: Icon(CupertinoIcons.photo), onPressed: () {}),
                      Icon(
                        Icons.image,
                        size: 50,
                      ),
                      Text("Add Photo from device"),
                    ]),
                    onTap: () {
                      attachPhoto(ImageSource.gallery, context);
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: GestureDetector(
                    child: Row(children: [
                      //IconButton(icon: Icon(CupertinoIcons.photo), onPressed: () {}),
                      Icon(
                        Icons.photo_camera,
                        size: 50,
                      ),
                      Text("Add Photo from camera"),
                    ]),
                    onTap: () {
                      attachPhoto(ImageSource.camera, context);
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: GestureDetector(
                    child: Row(children: [
                      //IconButton(icon: Icon(CupertinoIcons.photo), onPressed: () {}),
                      Icon(
                        Icons.video_library,
                        size: 50,
                      ),
                      Text("Add video from gallery"),
                    ]),
                    onTap: () {
                      attachVideo(ImageSource.gallery, context);
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: GestureDetector(
                    child: Row(children: [
                      //IconButton(icon: Icon(CupertinoIcons.photo), onPressed: () {}),
                      Icon(
                        Icons.videocam,
                        size: 50,
                      ),
                      Text("Add video from camera"),
                    ]),
                    onTap: () {
                      attachVideo(ImageSource.camera, context);
                    },
                  ),
                ),
                SizedBox(
                  height: 120,
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          "Add Exercise",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: Color.fromRGBO(21, 33, 47, 15),
      ),
      body: GestureDetector(
        child: Center(
          child: Container(
            padding: EdgeInsets.only(top: 20, left: 10, right: 10),
            child: Form(
              key: _formKey,
              child: Column(children: [
                Expanded(
                  //height: MediaQuery.of(context).size.height * 0.70,
                  child: ListView(
                    children: [
                      Container(
                          padding: EdgeInsets.only(left: 10, bottom: 20),
                          child: Text(
                            widget.day,
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          )),
                      Container(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(5).copyWith(top: 2),
                                child: Text(
                                  "Give your exercise a clear and succint name",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromRGBO(21, 33, 47, 15),
                                    // /fontSize: 15,
                                  ),
                                ),
                              ),
                              Container(
                                child: TextFormField(
                                  maxLength: 20,
                                  decoration: textInputDecorationWhite.copyWith(
                                    hintStyle:
                                        TextStyle(fontSize: fontSizeInputHint),
                                    hintText: "Workout Name",
                                  ),
                                  onSaved: (input) => workOutName = input,
                                  validator: (input) => input.isEmpty
                                      ? "Enter exercise name"
                                      : null,
                                ),
                              ),
                            ]),
                      ),
                      Container(
                        //height: 300,
                        padding: EdgeInsets.only(top: 30),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(5).copyWith(top: 2),
                                child: Text(
                                  "Describe the flow of the exercise. From sets, reps, rest time etc",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromRGBO(21, 33, 47, 15),
                                    //fontSize: 12,
                                  ),
                                ),
                              ),
                              Container(
                                child: TextFormField(
                                  maxLines: null,
                                  minLines: 12,
                                  //textInputAction: TextInputAction.newline,

                                  decoration: textInputDecorationWhite.copyWith(
                                      hintText: "Description",
                                      hintStyle: TextStyle(
                                          fontSize: fontSizeInputHint)),
                                  onSaved: (input) => description = input,
                                  //validator: (input) => input.isEmpty? "Enter",
                                ),
                              ),
                            ]),
                      ),
                      Container(
                        child: picture != null
                            ? Container(
                                padding: EdgeInsets.all(10),
                                child: Column(children: [
                                  Container(
                                    child: picture,
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        RaisedButton(
                                            child: Text("DELETE"),
                                            onPressed: () {
                                              setState(() {
                                                picture = null;
                                              });
                                            }),
                                        // RaisedButton(
                                        //     child: Text("REPLACE"),
                                        //     onPressed: () {})
                                      ],
                                    ),
                                  )
                                ]),
                              )
                            : Container(
                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                child: GestureDetector(
                                  child: Row(children: [
                                    //IconButton(icon: Icon(CupertinoIcons.photo), onPressed: () {}),
                                    Icon(
                                      Icons.image,
                                      size: 50,
                                    ),
                                    Text("Add Media"),
                                  ]),
                                  onTap: (showMediaSelectionOption),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 50),
                  child: working
                      ? SizedBox()
                      : RaisedButton(
                          child: Text(
                            "Create Exercise",
                            style: TextStyle(
                                fontSize: fontSizeButton,
                                fontWeight: FontWeight.normal,
                                color: Colors.white),
                          ),
                          color: Color.fromRGBO(27, 98, 40, 1),
                          onPressed: addExercise),
                )
              ]),
            ),
          ),
        ),
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
      ),
    );
  }
}
