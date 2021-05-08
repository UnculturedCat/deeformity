import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Messages/messageDaniel.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:deeformity/visuals/AddedSchedulesList.dart';
import 'package:deeformity/visuals/AddedUsersList.dart';
import 'package:deeformity/visuals/DeleteAccountPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:deeformity/Services/Authentication.dart';
import 'package:provider/provider.dart';
import 'package:deeformity/Services/database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

enum Pages { schedules, connections }

class ProfilePage extends StatefulWidget {
  ProfilePage();

  @override
  State<StatefulWidget> createState() {
    return ProfilePageState();
  }
}

class ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  List<DocumentSnapshot> usersConnections = [];
  Pages currentpage = Pages.schedules;
  ProfilePageState();
  DocumentSnapshot userDoc;
  String aboutUser;
  final ImagePicker _imagePicker = ImagePicker();
  bool editingDescription = false;
  final _discriptionFormKey = GlobalKey<FormState>();

  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    if (mounted) {
      DatabaseService(uid: UserSingleton.userSingleton.userID)
          .addedUsersSnapShot
          .listen((event) {
        usersConnections = event.docs;
        if (mounted) {
          setState(() {});
        }
      });
      DatabaseService(uid: UserSingleton.userSingleton.userID)
          .anyUserData
          .listen((event) {
        userDoc = event;
        if (mounted) {
          setState(() {});
        }
      });
    }
    super.initState();
  }

  void logOut() {
    context.read<AuthenticationService>().signOut();
    Navigator.popUntil(context, (route) => route.isFirst);
    // Navigator.pop(context);
  }

  void deleteAccountPage() {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return DeleteAccountPage(userDoc);
      },
    ));
  }

  void messageDaniel() {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return MessageDaniel(userDoc);
      },
    ));
  }

  Future<bool> checkAndRequestMediaPermission(ImageSource source) async {
    PermissionStatus permission;
    if (source == ImageSource.camera) {
      permission = await Permission.camera.request();
    } else if (source == ImageSource.gallery) {
      permission = await Permission.photos.request();
    }
    if (permission == PermissionStatus.granted) {
      return true;
    }
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

  Future<void> replacePhoto(ImageSource source) async {
    if (await checkAndRequestMediaPermission(source)) {
      File profilePictureFile;
      //open attach media page
      PickedFile selected = await _imagePicker.getImage(source: source);
      if (selected != null) {
        setState(() {
          profilePictureFile = File(selected.path);
          // _profilePicture = Image.file(_profilePictureFile);
        });
        if (profilePictureFile != null) {
          if (userDoc.data()["Profile Picture Url"] != null) {
            DatabaseService(uid: UserSingleton.userSingleton.userID)
                .deleteMedia(userDoc.data()["Profile Picture Url"]);
          }
          Map<String, String> mediaFields =
              await DatabaseService(uid: UserSingleton.userSingleton.userID)
                  .storeMedia(profilePictureFile, userDoc.data()["First Name"],
                      MediaType.photo);
          await DatabaseService(uid: UserSingleton.userSingleton.userID)
              .updateUserData(
                  field: "Profile Picture Url",
                  value: mediaFields["downloadURL"]);
        }
      }
      Navigator.pop(context);
    }
  }

  void setUserDescription() async {
    if (_discriptionFormKey.currentState.validate()) {
      _discriptionFormKey.currentState.save();
      if (aboutUser.isNotEmpty) {
        await DatabaseService(uid: UserSingleton.userSingleton.userID)
            .updateUserData(field: "About", value: aboutUser);
      }
    }
    setState(() {
      editingDescription = false;
    });
  }

  void showPhotoSelectionOption() {
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
                    Text("Photo from device"),
                  ]),
                  onTap: () {
                    replacePhoto(ImageSource.gallery);
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
                    Text("Photo from camera"),
                  ]),
                  onTap: () {
                    replacePhoto(ImageSource.camera);
                  },
                ),
              ),
              SizedBox(
                height: 120,
              )
            ],
          ),
        );
      },
    );
  }

  Widget createDrawer() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.55,
      child: Drawer(
        child: Container(
          padding: EdgeInsets.only(top: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Divider(
                  color: Colors.black26,
                ),
              ),
              InkWell(
                child: Container(
                  padding: EdgeInsets.all(6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      Text(
                        "Log out",
                        style: TextStyle(color: Colors.red, fontSize: fontSize),
                      ),
                    ],
                  ),
                ),
                onTap: logOut,
              ),
              Container(
                child: Divider(
                  color: Colors.black26,
                ),
              ),
              InkWell(
                child: Container(
                  padding: EdgeInsets.all(6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.smiley_fill, color: Colors.blue),
                      Text(
                        "Message Daniel",
                        style:
                            TextStyle(color: Colors.blue, fontSize: fontSize),
                      ),
                    ],
                  ),
                ),
                onTap: messageDaniel,
              ),
              Container(
                child: Divider(
                  color: Colors.black26,
                ),
              ),
              InkWell(
                child: Container(
                  padding: EdgeInsets.all(6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.delete, color: Colors.red),
                      Text(
                        "Delete Account",
                        style: TextStyle(color: Colors.red, fontSize: fontSize),
                      ),
                    ],
                  ),
                ),
                onTap: deleteAccountPage,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    super.build(context);
    return (userDoc != null && userDoc.data != null)
        ? Scaffold(
            // key: _scaffoldKey,
            appBar: AppBar(
              actionsIconTheme: IconThemeData(
                color: elementColorWhiteBackground,
              ),
              backgroundColor: Colors.white,
              shadowColor: Colors.white24,
              title: Text(
                userDoc.data()["User Name"] ?? "Error Name",
                style: TextStyle(color: elementColorWhiteBackground),
              ),
            ),
            endDrawer: createDrawer(),
            backgroundColor: Colors.white,
            body: Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Column(
                children: [
                  Container(
                    child: Container(
                      color: Colors.blue,
                      height: 35,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                child: userDoc.data()["Profile Picture Url"] ==
                                        null
                                    ? Text(userDoc.data()["First Name"][0])
                                    : null,
                                backgroundImage: userDoc
                                            .data()["Profile Picture Url"] !=
                                        null
                                    ? NetworkImage(
                                        userDoc.data()["Profile Picture Url"])
                                    : null,
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                ),
                                onPressed: showPhotoSelectionOption,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    userDoc.data()["First Name"] + " ",
                                    style: TextStyle(
                                      color: elementColorWhiteBackground,
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    userDoc.data()["Last Name"],
                                    style: TextStyle(
                                      color: elementColorWhiteBackground,
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  usersConnections != null
                                      ? Text(
                                          usersConnections.length.toString(),
                                          style: TextStyle(
                                            color: elementColorWhiteBackground,
                                            fontSize: fontSize,
                                          ),
                                        )
                                      : SizedBox(),
                                  Icon(Icons.people)
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: editingDescription
                        ? Row(
                            //crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.70,
                                child: Form(
                                  key: _discriptionFormKey,
                                  child: TextFormField(
                                    maxLines: null,
                                    minLines: 3,
                                    decoration:
                                        textInputDecorationWhite.copyWith(
                                      hintText: "Description",
                                      hintStyle: TextStyle(
                                        fontSize: fontSizeInputHint,
                                      ),
                                    ),
                                    onSaved: (input) => aboutUser = input,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: setUserDescription,
                                child: Text("Done"),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              userDoc.data()["About"] != null
                                  ? Expanded(
                                      child: Text(userDoc.data()["About"],
                                          style: TextStyle(
                                            color: elementColorWhiteBackground,
                                            fontSize: fontSizeBody,
                                          ),
                                          textAlign: TextAlign.justify),
                                    )
                                  : Text(
                                      "Who am I,\nwhat am I,\nWhere am I?",
                                      style: TextStyle(
                                        color: elementColorWhiteBackground,
                                        fontSize: fontSizeBody,
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                              IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    setState(() {
                                      editingDescription = true;
                                    });
                                  }),
                            ],
                          ),
                  ),
                  Divider(
                    color: Colors.black26,
                  ),
                  IntrinsicHeight(
                    //added intrinsicHeight order to have a proper height for the vertical divider
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          child: TextButton(
                            child: Text("Connections",
                                style: TextStyle(
                                    fontSize: currentpage != Pages.connections
                                        ? 15
                                        : fontSize,
                                    color: currentpage != Pages.connections
                                        ? Colors.grey
                                        : themeColor)),
                            onPressed: () {
                              setState(
                                () {
                                  currentpage = Pages.connections;
                                },
                              );
                            },
                          ),
                        ),
                        VerticalDivider(
                          //width: 30,
                          color: Colors.black26,
                        ),
                        Container(
                          child: TextButton(
                            child: Text(
                              "Schedules",
                              style: TextStyle(
                                  fontSize: currentpage != Pages.schedules
                                      ? 15
                                      : fontSize,
                                  color: currentpage != Pages.schedules
                                      ? Colors.grey
                                      : themeColor),
                            ),
                            onPressed: () {
                              setState(
                                () {
                                  currentpage = Pages.schedules;
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.grey[50],
                      child: currentpage == Pages.connections
                          ? AddedUsers(
                              sharingItem: false,
                            )
                          : currentpage == Pages.schedules
                              ? AddedSchedules(userDoc)
                              : Container(),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Center(
            child: Text("User profile not found"),
          );
  }

  @override
  bool get wantKeepAlive => true;
}
