import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deeformity/Services/database.dart';
import 'dart:io';
import 'package:deeformity/Services/AppVideoPlayer.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:image_picker/image_picker.dart';

class AddExercisePage extends StatefulWidget {
  final DaysOfTheWeek dayEnum;
  final QueryDocumentSnapshot scheduleDoc;
  AddExercisePage({@required this.dayEnum, @required this.scheduleDoc});
  @override
  _AddExercisePageState createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage>
/*with WidgetsBindingObserver // implement later*/ {
  final _formKey = GlobalKey<FormState>();
  String date = UserSingleton.userSingleton.selectedStringDate;
  DateTime dateTime = UserSingleton.userSingleton.dateTime;
  String cardId;
  String userId = UserSingleton.userSingleton.currentUSer.uid;
  String category;
  String workOutName;
  String description;
  List<int> workOutDays = [];
  File _mediaFile;
  final ImagePicker _imagePicker = ImagePicker();
  Image picture;
  String mediaURL;
  String mediaStoragePath;
  bool working = false;
  AppVideoPlayer _videoPlayer;
  MediaType _mediaType;
  bool correctVideoAspectRatio = false;
  bool mondayAdded = false,
      tuesdayAdded = false,
      wedAdded = false,
      thurAdded = false,
      friAdded = false,
      satAdded = false,
      sunAdded = false;
  _AddExercisePageState();

  @override
  void initState() {
    switch (widget.dayEnum) {
      case DaysOfTheWeek.monday:
        mondayAdded = true;
        break;

      case DaysOfTheWeek.tuesday:
        tuesdayAdded = true;
        break;

      case DaysOfTheWeek.wednesday:
        wedAdded = true;
        break;

      case DaysOfTheWeek.thursday:
        thurAdded = true;
        break;

      case DaysOfTheWeek.friday:
        friAdded = true;
        break;

      case DaysOfTheWeek.saturday:
        satAdded = true;
        break;

      case DaysOfTheWeek.sunday:
        sunAdded = true;
        break;
    }
    workOutDays.add(widget.dayEnum.index);
    super.initState();
  }

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance?.addObserver(this);
  // }

// //Implement this later to ensure app does not restart after permission has been given in the settings.
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) async {
//     if (state == AppLifecycleState.resumed) {
//       return;
//     }
//   }

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
                .storeMedia(_mediaFile, workOutName, _mediaType);
        mediaURL = mediaFields["downloadURL"];
        mediaStoragePath = mediaFields["fullPath"];
      }

      String cardDocId = await DatabaseService(
              uid: UserSingleton.userSingleton.currentUSer.uid)
          .createRoutine(
              cardId: cardId,
              userId: userId,
              workOutName: workOutName,
              description: description,
              dateTime: dateTime.toString(),
              mediaURL: mediaURL,
              mediaStoragePath: mediaStoragePath,
              mediaType: _mediaType,
              scheduleId: widget.scheduleDoc.id,
              days: workOutDays,
              correctedAspectRatio: correctVideoAspectRatio);
      cardDocId != null && cardDocId.isNotEmpty
          ? Navigator.pop(context)
          : setState(() {
              working = false;
              showBottomSheet(
                  context: context,
                  builder: (context) {
                    return Center(child: Text("Could not create exercise"));
                  });
            });
    } else {
      //check if workoutDays list is empty then show snackBar
    }
  }

  Future<bool> checkAndRequestMediaPermission(ImageSource source) async {
    PermissionStatus permission;
    if (source == ImageSource.camera) {
      permission = await Permission.camera.request();
    } else if (source == ImageSource.gallery) {
      permission = await Permission.photos.request();
    }
    if (permission == PermissionStatus.granted) return true;
    await showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: Text("Permission needed"),
            message: Text("Grant permission from App settings and try again?"),
            actions: [
              CupertinoActionSheetAction(
                child: Text("Yes"),
                onPressed: () async {
                  await openAppSettings();
                  Navigator.pop(context);
                },
              ),
              CupertinoActionSheetAction(
                child: Text("No"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
    return false;
  }

//attach photo
  Future<void> attachPhoto(ImageSource source) async {
    // bool permissionGranted = await checkAndRequestMediaPermission(source);
    // if (!permissionGranted) {
    //   return; //remove when didChangeAppLifecycleState has been figured out
    // }
    //Uncomment when didChangeAppLifecycleState has been figured out.
    // permissionGranted = await checkAndRequestMediaPermission(source);
    // //check again if user granted permission after being promted
    // if (!permissionGranted) {
    //   //exit if user denied permission.
    //   return;
    // }
    if (await checkAndRequestMediaPermission(source)) {
      //open attach media page
      PickedFile selected = await _imagePicker.getImage(source: source);
      _mediaType = MediaType.photo;
      if (selected != null) {
        setState(() {
          _mediaFile = File(selected.path);
          picture = Image.file(_mediaFile);
        });
      }
      Navigator.pop(context);
    }
  }

  Future<void> attachVideo(ImageSource source) async {
    if (await checkAndRequestMediaPermission(source)) {
      //open attach media page
      PickedFile selected = await _imagePicker.getVideo(source: source);
      _mediaType = MediaType.video;
      if (selected != null) {
        setState(() {
          _mediaFile = File(selected.path);
          //set video player to play from file
          _videoPlayer = AppVideoPlayer(
            assetSource: MediaAssetSource.file,
            assetFile: _mediaFile,
          );
        });
      }
      Navigator.pop(context);
    }
  }

  Widget createDayCard(DaysOfTheWeek dayEnum) {
    bool added = false;

    switch (dayEnum) {
      case DaysOfTheWeek.monday:
        added = mondayAdded;
        break;

      case DaysOfTheWeek.tuesday:
        added = tuesdayAdded;
        break;

      case DaysOfTheWeek.wednesday:
        added = wedAdded;
        break;

      case DaysOfTheWeek.thursday:
        added = thurAdded;
        break;

      case DaysOfTheWeek.friday:
        added = friAdded;
        break;

      case DaysOfTheWeek.saturday:
        added = satAdded;
        break;

      case DaysOfTheWeek.sunday:
        added = sunAdded;
        break;
    }

    return Container(
      width: MediaQuery.of(context).size.height / 7.5,
      child: InkWell(
        child: Card(
          color: added ? Color.fromRGBO(0, 122, 225, 1) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(4),
            child: Center(
              child: Text(
                convertDayToString(dayEnum),
                style: TextStyle(
                    color: added ? Colors.white : elementColorWhiteBackground),
              ),
            ),
          ),
        ),
        onTap: () {
          switch (dayEnum) {
            case DaysOfTheWeek.monday:
              mondayAdded
                  ? workOutDays.remove(dayEnum.index)
                  : workOutDays.add(dayEnum.index);
              mondayAdded = !mondayAdded;
              break;

            case DaysOfTheWeek.tuesday:
              tuesdayAdded
                  ? workOutDays.remove(dayEnum.index)
                  : workOutDays.add(dayEnum.index);
              tuesdayAdded = !tuesdayAdded;
              break;

            case DaysOfTheWeek.wednesday:
              wedAdded
                  ? workOutDays.remove(dayEnum.index)
                  : workOutDays.add(dayEnum.index);
              wedAdded = !wedAdded;
              break;

            case DaysOfTheWeek.thursday:
              thurAdded
                  ? workOutDays.remove(dayEnum.index)
                  : workOutDays.add(dayEnum.index);
              thurAdded = !thurAdded;
              break;

            case DaysOfTheWeek.friday:
              friAdded
                  ? workOutDays.remove(dayEnum.index)
                  : workOutDays.add(dayEnum.index);
              friAdded = !friAdded;
              break;

            case DaysOfTheWeek.saturday:
              satAdded
                  ? workOutDays.remove(dayEnum.index)
                  : workOutDays.add(dayEnum.index);
              satAdded = !satAdded;
              break;

            case DaysOfTheWeek.sunday:
              sunAdded
                  ? workOutDays.remove(dayEnum.index)
                  : workOutDays.add(dayEnum.index);
              sunAdded = !sunAdded;
              break;
          }
          setState(() {});
        },
      ),
    );
  }

  Widget displayMediaWidget() {
    return picture == null && _videoPlayer == null
        ? Container(
            padding: EdgeInsets.only(top: 30, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(5).copyWith(top: 2),
                  child: Text(
                    "Tap on the picture icon to add media ",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(21, 33, 47, 15),
                      //fontSize: 12,
                    ),
                  ),
                ),
                GestureDetector(
                  child: Row(
                    children: [
                      //IconButton(icon: Icon(CupertinoIcons.photo), onPressed: () {}),
                      Icon(
                        Icons.image,
                        size: 50,
                      ),
                      Text("Add Media"),
                    ],
                  ),
                  onTap: (showMediaSelectionOption),
                ),
                Container(
                  height: 50,
                )
              ],
            ),
          )
        : Container(
            padding: EdgeInsets.only(top: 20, bottom: 50),
            child: Column(
              children: [
                // Container(
                //   padding: EdgeInsets.only(top: 20, bottom: 50),
                //   child: Stack(
                //     alignment: AlignmentDirectional.bottomEnd,
                //     children: [
                //       picture != null
                //           ? picture
                //           : _videoPlayer != null
                //               ? _videoPlayer
                //               : Text("Nothing to show. Delete and try again"),
                //       IconButton(
                //         icon: Icon(
                //           CupertinoIcons.delete,
                //           color: Colors.white,
                //           size: 30,
                //         ),
                //         onPressed: () {
                //           setState(() {
                //             picture = null;
                //             _videoPlayer = null;
                //           });
                //         },
                //       ),
                //     ],
                //   ),
                // ),
                Container(
                  color: Colors.white,
                  alignment: Alignment.center,
                  height: 400,
                  child: picture != null
                      ? picture
                      : _videoPlayer != null
                          ? _videoPlayer
                          : Center(
                              child:
                                  Text("Nothing to show. Delete and try again"),
                            ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _videoPlayer != null
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
                                    "Decompress Video",
                                    style: TextStyle(
                                      color: Colors.blue,
                                    ),
                                  )
                                ],
                              ),
                              onTap: () {
                                setState(() {
                                  correctVideoAspectRatio =
                                      !correctVideoAspectRatio;
                                  _videoPlayer = AppVideoPlayer(
                                    assetSource: MediaAssetSource.file,
                                    assetFile: _mediaFile,
                                    flipHeightAndWidth: correctVideoAspectRatio,
                                  );
                                });
                                final snackBar = SnackBar(
                                    content:
                                        Text("Video's aspect ratio corrected"));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              },
                            ),
                          )
                        : SizedBox(),
                    Container(
                      child: InkWell(
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(5),
                              child: Icon(
                                CupertinoIcons.delete,
                                color: Colors.red,
                                size: 30,
                              ),
                            ),
                            Text(
                              "Delete Media",
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            )
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            picture = null;
                            _videoPlayer = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 50,
                )
              ],
            ),
          );
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
                      attachPhoto(ImageSource.gallery);
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
                      attachPhoto(ImageSource.camera);
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
                      attachVideo(ImageSource.gallery);
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
                      attachVideo(ImageSource.camera);
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
        //centerTitle: false,
        title: Text(
          "Add Exercise",
          style: pageHeaderStyle,
        ),
        backgroundColor: Color.fromRGBO(21, 33, 47, 15),
        actions: [
          Container(
            padding: EdgeInsets.only(left: 5, right: 5),
            child: !working
                ? TextButton(
                    onPressed: addExercise,
                    child: Text(
                      "Create",
                      style: headerActionButtonStyle,
                    ),
                  )
                : SizedBox(),
          ),
        ],
      ),
      body: GestureDetector(
        child: Center(
          child: Container(
            padding: EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  //children: [
                  // Expanded(
                  //   //height: MediaQuery.of(context).size.height * 0.70,
                  //   child: ListView(
                  children: [
                    Container(
                        padding: EdgeInsets.only(left: 10, bottom: 20),
                        child: Text(
                          convertDayToString(widget.dayEnum),
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
                                  color: elementColorWhiteBackground,
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
                                // validator: (input) => input.isEmpty
                                //     ? "Enter exercise name"
                                //     : null,
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
                                color: elementColorWhiteBackground,
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
                                hintStyle:
                                    TextStyle(fontSize: fontSizeInputHint),
                              ),
                              onSaved: (input) => description = input,
                              //validator: (input) => input.isEmpty? "Enter",
                            ),
                          ),
                        ],
                      ),
                    ),
                    //Days Container
                    Container(
                      padding: EdgeInsets.only(
                        top: 30,
                        //bottom: 30,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(5).copyWith(top: 2),
                            child: Text(
                              "Select the days to repeat this exercise",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: elementColorWhiteBackground,
                                //fontSize: 12,
                              ),
                            ),
                          ),
                          Container(
                            // height:
                            //     MediaQuery.of(context).size.height / 7.5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                createDayCard(DaysOfTheWeek.monday),
                                createDayCard(DaysOfTheWeek.tuesday),
                                createDayCard(DaysOfTheWeek.wednesday)
                              ],
                            ),
                          ),
                          Container(
                            // height:
                            //     MediaQuery.of(context).size.height / 7.5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                createDayCard(DaysOfTheWeek.thursday),
                                createDayCard(DaysOfTheWeek.friday),
                                createDayCard(DaysOfTheWeek.saturday)
                              ],
                            ),
                          ),
                          Container(
                            child: createDayCard(DaysOfTheWeek.sunday),
                          )
                        ],
                      ),
                    ),
                    Align(
                        alignment: Alignment.center,
                        child: displayMediaWidget())
                  ],
                  //   ),
                  // ),
                  // Container(
                  //   padding: EdgeInsets.only(bottom: 50),
                  //   child: working
                  //       ? SizedBox()
                  //       // : ElevatedButton(
                  //       //     child: Text(
                  //       //       "Create Exercise",
                  //       //       style: TextStyle(
                  //       //           fontSize: fontSizeButton,
                  //       //           fontWeight: FontWeight.normal,
                  //       //           color: Colors.white),
                  //       //     ),
                  //       //     style: ElevatedButton.styleFrom(
                  //       //         primary: Color.fromRGBO(27, 98, 40, 1)),
                  //       //     onPressed: addExercise),
                  //       : TextButton(
                  //           onPressed: addExercise,
                  //           child: Text(
                  //             "DONE",
                  //             style: TextStyle(
                  //                 color: Color.fromRGBO(27, 98, 40, 1),
                  //                 fontSize: 15),
                  //           ),
                  //         ),
                  // ),
                  //],
                ),
              ),
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
