import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Services/AppVideoPlayer.dart';
import 'package:deeformity/Services/database.dart';
import 'package:deeformity/Shared/UserCardCreator.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:deeformity/Shared/loading.dart';
import 'package:deeformity/User/otherProfile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AboutSchedulePage extends StatefulWidget {
  final DocumentSnapshot doc;
  AboutSchedulePage({@required this.doc, Key key}) : super(key: key);
  @override
  _AboutSchedulePageState createState() => _AboutSchedulePageState();
}

class _AboutSchedulePageState extends State<AboutSchedulePage> {
  bool loading = false;
  AppVideoPlayer appVideoPlayer;
  bool editingMedia = false;
  bool editingDescription = false;
  bool editingHeader = false;
  String mediaURL;
  bool correctVideoAspectRatio = false;
  final ImagePicker _imagePicker = ImagePicker();
  MediaType _mediaType;
  File _mediaFile;
  Image picture;
  bool createdByYou = true;
  DocumentSnapshot docSnapshot;
  String description;
  final _formKey = GlobalKey<FormState>();
  final _formKeyHeader = GlobalKey<FormState>();
  var media;

  Widget creatorUserCard;
  @override
  void initState() {
    super.initState();
    docSnapshot = widget.doc;

    if (widget.doc["Creator Id"] != UserSingleton.userSingleton.userID) {
      getScheduleCreatorCard();
      createdByYou = false;
    }
    DatabaseService(uid: widget.doc["Creator Id"])
        .particularUserSchedule(widget.doc.id)
        .listen((event) {
      if (mounted) {
        setState(() {
          docSnapshot = event;
          initMedia(); //get latest snapshot from schedule Creator.
        });
      }
    });
    initMedia();
  }

  void updateDocument() async {
    docSnapshot = widget.doc;

    initMedia();
    if (widget.doc["Creator Id"] != UserSingleton.userSingleton.userID) {
      createdByYou = false;
      await getScheduleCreatorCard();
    } else {
      setState(() {
        creatorUserCard = null;
        createdByYou = true;
      });
    }
  }

  void setDescription() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (description.isNotEmpty) {
        await DatabaseService(uid: UserSingleton.userSingleton.userID)
            .updateScheduleField(
                doc: docSnapshot, field: "Description", value: description);

        //log event
        UserSingleton.analytics.logEvent(name: "Schedule_Discription_Edited");
        // await updateDocumentSnapShot();
      }
    }
    setState(() {
      editingDescription = false;
    });
  }

  void setHeader() async {
    if (_formKeyHeader.currentState.validate()) {
      _formKeyHeader.currentState.save();
      if (description.isNotEmpty) {
        await DatabaseService(uid: UserSingleton.userSingleton.userID)
            .updateScheduleField(
                doc: docSnapshot, field: "Header", value: description);

        //log event
        UserSingleton.analytics.logEvent(name: "Schedule_Header_Edited");
        // await updateDocumentSnapShot();
      }
    }
    setState(() {
      editingHeader = false;
    });
  }
  // Future updateDocumentSnapShot() async {
  //   DocumentSnapshot newDoc;
  //   newDoc = await DatabaseService(uid: UserSingleton.userSingleton.userID)
  //       .getScheduleDoc(docSnapshot.id);
  //   setState(() {
  //     docSnapshot = newDoc;
  //   });
  // }

  void initMedia() {
    if (docSnapshot["MediaURL"] != null && docSnapshot["MediaURL"] != "") {
      mediaURL = docSnapshot["MediaURL"];
      int mediaTypeIndex =
          docSnapshot["Mediatype"] ?? docSnapshot["Media type"];
      correctVideoAspectRatio = docSnapshot["CorrectVideo"] ?? false;
      media = null;
      appVideoPlayer = null;

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
    }
  }

  void saveMedia() async {
    Map<String, String> mediaFields;
    String mediaStoragePath;
    bool done = false;

    setState(() {
      loading = true;
    });

    String message = "Media upload unsuccessful";
    if (_mediaFile != null) {
      mediaFields =
          await DatabaseService(uid: UserSingleton.userSingleton.userID)
              .storeMedia(_mediaFile, docSnapshot["Name"], _mediaType);
      mediaURL = mediaFields["downloadURL"];
      mediaStoragePath = mediaFields["fullPath"];
      done = true;
    }
    if (done) {
      await DatabaseService(uid: UserSingleton.userSingleton.userID)
          .updateScheduleField(
              doc: docSnapshot, field: "Mediatype", value: _mediaType.index);
      await DatabaseService(uid: UserSingleton.userSingleton.userID)
          .updateScheduleField(
              doc: docSnapshot, field: "MediaURL", value: mediaURL);
      await DatabaseService(uid: UserSingleton.userSingleton.userID)
          .updateScheduleField(
              doc: docSnapshot, field: "MediaPath", value: mediaStoragePath);
      //await updateDocumentSnapShot();
      message = "Media upload successful";
    }
    setState(() {
      editingMedia = false;
      loading = false;
      initMedia();
    });
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void deleteMedia() async {
    String message = "Media Delete unsuccessful";
    setState(() {
      loading = true;
    });
    try {
      await DatabaseService(uid: UserSingleton.userSingleton.userID)
          .deleteMedia(mediaURL);
      await DatabaseService(uid: UserSingleton.userSingleton.userID)
          .updateScheduleField(
              doc: docSnapshot,
              field: "Mediatype",
              value: MediaType.none.index);
      await DatabaseService(uid: UserSingleton.userSingleton.userID)
          .updateScheduleField(doc: docSnapshot, field: "MediaURL", value: "");
      await DatabaseService(uid: UserSingleton.userSingleton.userID)
          .updateScheduleField(doc: docSnapshot, field: "MediaPath", value: "");
      //await updateDocumentSnapShot();
      message = "Media Delete successful";
      setState(() {
        picture = null;
        appVideoPlayer = null;
        _mediaFile = null;
        media = null;
      });
    } catch (_) {}
    setState(() {
      loading = false;
    });
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

  Future<File> cropPicture(File imageFile) async {
    return await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(
        ratioX: 1,
        ratioY: 1,
      ),
      aspectRatioPresets: [CropAspectRatioPreset.square],
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 60,
    );
  }

//attach photo
  Future<void> attachPhoto(ImageSource source) async {
    if (await checkAndRequestMediaPermission(source)) {
      //open attach media page
      PickedFile selected = await _imagePicker.getImage(
        source: source,
      );
      _mediaType = MediaType.photo;
      if (selected != null) {
        File croppedImage = await cropPicture(File(selected.path));
        if (croppedImage != null) {
          setState(() {
            _mediaFile = croppedImage;
            picture = Image.file(_mediaFile);
          });
        } else {
          setState(() {
            editingMedia = false;
          });
        }
      } else {
        setState(() {
          editingMedia = false;
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
          appVideoPlayer = AppVideoPlayer(
            assetSource: MediaAssetSource.file,
            assetFile: _mediaFile,
          );
        });
      } else {
        setState(() {
          editingMedia = false;
        });
      }
      Navigator.pop(context);
    }
  }

  void showMediaSelectionOption() {
    setState(() {
      editingMedia = true;
    });
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
                  child: InkWell(
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
                  child: InkWell(
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
                  child: InkWell(
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
                  child: InkWell(
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

  void openCreatorCard(DocumentSnapshot doc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return OtherUserProfile(doc);
        },
      ),
    );
  }

  Future getScheduleCreatorCard() async {
    String creatorId = docSnapshot["Creator Id"];
    await DatabaseService(uid: UserSingleton.userSingleton.userID)
        .getParticularUserDoc(creatorId)
        .then((value) {
      setState(
        () {
          creatorUserCard = InkWell(
            child: UserCardCreator(
              userDoc: value,
            ),
            onTap: () {
              openCreatorCard(value);
            },
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : ListView(
            children: [
              Container(
                padding: EdgeInsets.only(top: 5, bottom: 5),
                child: editingHeader
                    ? Row(
                        //crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.70,
                            child: Form(
                              key: _formKeyHeader,
                              child: TextFormField(
                                initialValue: docSnapshot["Header"] ?? "",
                                maxLines: 1,
                                maxLength: 30,
                                decoration: textInputDecorationWhite.copyWith(
                                    hintText: "Add a header",
                                    hintStyle:
                                        TextStyle(fontSize: fontSizeInputHint)),
                                onSaved: (input) => description = input,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: setHeader,
                            child: Text("Done"),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: 20),
                            child: Text(
                              docSnapshot["Header"] ?? "No Header",
                              style: TextStyle(
                                  fontSize: fontSizeHeader,
                                  color: elementColorWhiteBackground,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                            child: createdByYou
                                ? IconButton(
                                    icon: Icon(Icons.edit),
                                    iconSize: iconSizeBody,
                                    color: elementColorWhiteBackground,
                                    onPressed: () {
                                      setState(() {
                                        editingHeader = true;
                                      });
                                    },
                                  )
                                : SizedBox(),
                          )
                        ],
                      ),
              ),
              Column(
                children: [
                  Container(
                    child: Text("Created by:"),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: creatorUserCard == null
                        ? createdByYou
                            ? Text("You")
                            : SizedBox()
                        : creatorUserCard,
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              editingMedia
                  ? Card(
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      elevation: 5,
                      child: Container(
                        color: Colors.white,
                        alignment: Alignment.center,
                        height: (picture == null)
                            ? MediaQuery.of(context).size.height * 0.50
                            : null,
                        child: picture != null
                            ? picture
                            : appVideoPlayer != null
                                ? appVideoPlayer
                                : createdByYou
                                    ? Center(
                                        child: InkWell(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.image,
                                                size: 50,
                                              ),
                                              Text("Add Media"),
                                            ],
                                          ),
                                          onTap: showMediaSelectionOption,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image,
                                            size: 50,
                                          ),
                                          Text("No Media"),
                                        ],
                                      ),
                      ),
                    )
                  : Card(
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      elevation: 5,
                      child: Container(
                        color: Colors.white,
                        alignment: Alignment.center,
                        height: (media == null)
                            ? MediaQuery.of(context).size.height * 0.50
                            : null,
                        child: media != null
                            ? media
                            : appVideoPlayer != null
                                ? appVideoPlayer
                                : Center(
                                    child: createdByYou
                                        ? InkWell(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.image,
                                                  size: 50,
                                                ),
                                                Text("Add Media"),
                                              ],
                                            ),
                                            onTap: showMediaSelectionOption,
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.image,
                                                size: 50,
                                              ),
                                              Text("No Media"),
                                            ],
                                          ),
                                  ),
                      ),
                    ),
              // appVideoPlayer != null
              //     ? Container(
              //         child: InkWell(
              //           child: Row(
              //             children: [
              //               Container(
              //                 padding: EdgeInsets.all(5),
              //                 child: Icon(
              //                   Icons.reset_tv,
              //                   color: Colors.blue,
              //                   size: 20,
              //                 ),
              //               ),
              //               Text(
              //                 "Fix Video",
              //                 style: TextStyle(
              //                   color: Colors.blue,
              //                 ),
              //               )
              //             ],
              //           ),
              //           onTap: () {
              //             setState(
              //               () {
              //                 correctVideoAspectRatio =
              //                     !correctVideoAspectRatio;
              //                 appVideoPlayer = AppVideoPlayer(
              //                   assetSource: editingMedia
              //                       ? MediaAssetSource.file
              //                       : MediaAssetSource.network,
              //                   assetURL: mediaURL,
              //                   assetFile: _mediaFile,
              //                   flipHeightAndWidth: correctVideoAspectRatio,
              //                 );
              //               },
              //             );
              //             final snackBar = SnackBar(
              //                 content: Text("Video's aspect ratio corrected"));
              //             ScaffoldMessenger.of(context).showSnackBar(snackBar);
              //           },
              //         ),
              //       )
              //     : SizedBox(),
              Container(
                child: Column(
                  children: [
                    Container(
                      child: editingMedia &&
                              (picture != null || appVideoPlayer != null)
                          ? InkWell(
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    child: Icon(
                                      Icons.done,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                  ),
                                  Text(
                                    "Save Media",
                                    style: TextStyle(
                                      color: Colors.blue,
                                    ),
                                  )
                                ],
                              ),
                              onTap: saveMedia,
                            )
                          : SizedBox(),
                    ),
                    Container(
                      child: createdByYou &&
                              (picture != null ||
                                  appVideoPlayer != null ||
                                  media != null)
                          ? InkWell(
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    child: Icon(
                                      CupertinoIcons.xmark,
                                      color: Colors.red,
                                      size: 20,
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
                              onTap: editingMedia
                                  ? () {
                                      setState(() {
                                        picture = null;
                                        appVideoPlayer = null;
                                        _mediaFile = null;
                                        editingMedia = false;
                                      });
                                    }
                                  : deleteMedia,
                            )
                          : SizedBox(),
                    ),
                  ],
                ),
              ),
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
                                initialValue: docSnapshot["Description"] ?? "",
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
                            docSnapshot["Description"] ?? "No description",
                            style: TextStyle(
                                fontSize: fontSizeBody,
                                color: elementColorWhiteBackground,
                                fontWeight: FontWeight.w600),
                          ),
                          Container(
                            child: createdByYou
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
              ),
            ],
          );
  }
}
