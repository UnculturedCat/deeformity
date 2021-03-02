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
  int sets;
  int reps;
  String description;
  String date = UserSingleton.userSingleton.selectedStringDate;
  int frequency = RepeatFrequency.none.index;
  DateTime dateTime = UserSingleton.userSingleton.dateTime;
  File _mediaFile;
  final ImagePicker _imagePicker = ImagePicker();
  Image picture;

  _AddExercisePageState();
  void addExercise() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      String cardDocId = await DatabaseService(
              uid: UserSingleton.userSingleton.currentUSer.uid)
          .createSchedule(
              cardId: cardId,
              category: category,
              userId: userId,
              workOutName: workOutName,
              sets: sets,
              reps: reps,
              description: description,
              day: widget.day,
              dateTime: dateTime.toString(),
              frequency: frequency);
      cardDocId.isNotEmpty
          ? updateRoutineInfo(cardDocId)
          : print("Add Exercise Page: CardDocId not received");
    }
  }

  void updateRoutineInfo(String cardDocId) async {
    await DatabaseService(uid: UserSingleton.userSingleton.currentUSer.uid)
        .updateRoutineInfo(cardDocId);
    Navigator.pop(context);
  }

  Future<void> attachPhoto(ImageSource source) async {
    //open attach media page
    PickedFile selected = await _imagePicker.getImage(source: source);
    if (selected != null) {
      setState(() {
        _mediaFile = File(selected.path);
        picture = Image.file(_mediaFile);
      });
    }
  }

  Future<void> attachVideo(ImageSource source) async {
    //open attach media page
    PickedFile selected = await _imagePicker.getVideo(source: source);
    if (selected != null) {
      setState(() {
        // _mediaFile = File(selected.path);
        // picture = Image.file(_mediaFile);
      });
    }
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
                                        RaisedButton(
                                            child: Text("REPLACE"),
                                            onPressed: () {})
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
                                  onTap: () {
                                    showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return Container(
                                            padding: EdgeInsets.all(10),
                                            child: Column(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.only(
                                                      top: 10, bottom: 10),
                                                  child: GestureDetector(
                                                    child: Row(children: [
                                                      //IconButton(icon: Icon(CupertinoIcons.photo), onPressed: () {}),
                                                      Icon(
                                                        Icons.image,
                                                        size: 50,
                                                      ),
                                                      Text(
                                                          "Add Photo from device"),
                                                    ]),
                                                    onTap: () {
                                                      attachPhoto(
                                                          ImageSource.gallery);
                                                    },
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(
                                                      top: 10, bottom: 10),
                                                  child: GestureDetector(
                                                    child: Row(children: [
                                                      //IconButton(icon: Icon(CupertinoIcons.photo), onPressed: () {}),
                                                      Icon(
                                                        Icons.photo_camera,
                                                        size: 50,
                                                      ),
                                                      Text(
                                                          "Add Photo from camera"),
                                                    ]),
                                                    onTap: () {
                                                      attachPhoto(
                                                          ImageSource.camera);
                                                    },
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(
                                                      top: 10, bottom: 10),
                                                  child: GestureDetector(
                                                    child: Row(children: [
                                                      //IconButton(icon: Icon(CupertinoIcons.photo), onPressed: () {}),
                                                      Icon(
                                                        Icons.video_library,
                                                        size: 50,
                                                      ),
                                                      Text(
                                                          "Add video from gallery"),
                                                    ]),
                                                    onTap: () {
                                                      attachVideo(
                                                          ImageSource.gallery);
                                                    },
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(
                                                      top: 10, bottom: 10),
                                                  child: GestureDetector(
                                                    child: Row(children: [
                                                      //IconButton(icon: Icon(CupertinoIcons.photo), onPressed: () {}),
                                                      Icon(
                                                        Icons.videocam,
                                                        size: 50,
                                                      ),
                                                      Text(
                                                          "Add video from camera"),
                                                    ]),
                                                    onTap: () {
                                                      attachVideo(
                                                          ImageSource.camera);
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        });
                                  },
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 50),
                  child: RaisedButton(
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
