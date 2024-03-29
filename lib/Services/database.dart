import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:video_compress/video_compress.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  firebase_storage.FirebaseStorage _mediaStorage =
      firebase_storage.FirebaseStorage.instance;

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection("Users");

  final CollectionReference scheduleCollection =
      FirebaseFirestore.instance.collection("Schedules");

  final CollectionReference messageDanielCollection =
      FirebaseFirestore.instance.collection("MessageDaniel");

  String workOutRoutinesSubCollectionName = "Workout Routines";
  String addedWorkOutScheduleSubCollectionName = "Added Workout Schedule";
  String addedUsers = "Added Users";
  String messagesSubcollection = "Messages";
  String messagesUsersSubcollection = "Messages Users";

/*
 Messages functions
*/

//sends and recieves messages
  Future<String> sendMessage({
    @required DocumentSnapshot receiverDoc,
    @required int dateTimeNowMilli,
    @required String message,
  }) async {
    String successMessage = "";
    //write to recipients db
    var sentIdRef = await usersCollection
        .doc(receiverDoc.id)
        .collection(messagesSubcollection)
        .add({
      "Sender": uid,
      "Recipient": receiverDoc.id,
      "Time": dateTimeNowMilli,
      "Message": message,
      "Users": [receiverDoc.id, uid]
    });

    await usersCollection
        .doc(receiverDoc.id)
        .collection(messagesUsersSubcollection)
        .doc(uid)
        .set({
      "User Id": uid,
      "Time": dateTimeNowMilli,
    });

    //write to my(currentUser) own db
    var recievedIdRef =
        await usersCollection.doc(uid).collection(messagesSubcollection).add({
      "Sender": uid,
      "Recipient": receiverDoc.id,
      "Time": dateTimeNowMilli,
      "Message": message,
      "Users": [receiverDoc.id, uid]
    });

    await usersCollection
        .doc(uid)
        .collection(messagesUsersSubcollection)
        .doc(receiverDoc.id)
        .set({
      "User Id": receiverDoc.id,
      "Time": dateTimeNowMilli,
    });

    if (recievedIdRef.id.isNotEmpty && sentIdRef.id.isNotEmpty) {
      successMessage = "Sent successfully";
    }

    return successMessage;
  }

//user messages stream
  Stream<QuerySnapshot> get messages =>
      usersCollection.doc(uid).collection(messagesSubcollection).snapshots();

//users who messaged stream
  Stream<QuerySnapshot> get messagesUsers => usersCollection
      .doc(uid)
      .collection(messagesUsersSubcollection)
      .orderBy("Time", descending: false)
      .snapshots();

//Messages stream from a particular user
  Stream<QuerySnapshot> particularUserMessagesStream(String id) {
    return usersCollection
        .doc(uid)
        .collection(messagesSubcollection)
        .orderBy("Time", descending: false)
        .snapshots();
  }

/*
  user data functions
*/
  Stream<QuerySnapshot> get currentUsers {
    return usersCollection.snapshots();
  }

  Stream<QuerySnapshot> get addedUsersSnapShot {
    return usersCollection.doc(uid).collection(addedUsers).snapshots();
  }

//Get snapshot of current user
  Stream<DocumentSnapshot> get userData =>
      usersCollection.doc(UserSingleton.userSingleton.userID).snapshots();
//Get snapshot of any user
  Stream<DocumentSnapshot> get anyUserData =>
      usersCollection.doc(uid).snapshots();

  Stream<QuerySnapshot> get allUsers => usersCollection.snapshots();

  Future createUserData({
    String firstName,
    String lastName,
    String userName,
  }) async {
    await usersCollection.doc(uid).set({
      "First Name": firstName,
      "Last Name": lastName,
      "User Name": userName,
      "Time": DateTime.now().millisecondsSinceEpoch
    });
    UserSingleton.analytics.logEvent(name: "Account_created");
  }

  Future<DocumentSnapshot> getParticularUserDoc(String docId) async {
    var doc;
    doc = await usersCollection.doc(docId).get();

    return doc;
  }

  Future<void> connectWithUser(DocumentSnapshot userToAdd) async {
    try {
      await usersCollection
          .doc(uid)
          .collection(addedUsers)
          .doc(userToAdd.id)
          .set({
        "User Id": userToAdd.id,
        "First Name": userToAdd["First Name"],
        "Last Name": userToAdd["Last Name"],
        "Profile Picture Url": userToAdd["Profile Picture Url"],
        "About": userToAdd["About"]
      });

      //add to other user's addedUsers collection
      await usersCollection
          .doc(userToAdd.id)
          .collection(addedUsers)
          .doc(uid)
          .set({
        "User Id": UserSingleton.userSingleton.userDataSnapShot.id,
        "First Name":
            UserSingleton.userSingleton.userDataSnapShot["First Name"],
        "Last Name": UserSingleton.userSingleton.userDataSnapShot["Last Name"],
        "Profile Picture Url":
            UserSingleton.userSingleton.userDataSnapShot["Profile Picture Url"]
      });
      UserSingleton.analytics.logEvent(name: "Connected_with_user");
    } catch (e) {}
  }

  Future<void> disconnectWithUser(DocumentSnapshot userToRemove) async {
    try {
      await usersCollection
          .doc(uid)
          .collection(addedUsers)
          .doc(userToRemove.id)
          .delete();
//Remove from other user's addedUsers collection
      await usersCollection
          .doc(userToRemove.id)
          .collection(addedUsers)
          .doc(uid)
          .delete();
      UserSingleton.analytics.logEvent(name: "Disconnected_with_user");
    } catch (e) {}
  }

  Future<QuerySnapshot> searchForUser(String searchQuery) async {
    return await usersCollection
        .where("Location", isEqualTo: searchQuery)
        .get();
  }

  Future updateUserData({
    DocumentSnapshot doc,
    String field,
    value,
  }) async {
    await usersCollection.doc(uid).set({field: value}, SetOptions(merge: true));
    UserSingleton.analytics.logEvent(name: "User_" + field.trim() + "_Updated");
  }

  Future messageDaniel(
      {String topic, String message, DocumentSnapshot recipientDoc}) async {
    String firstname = recipientDoc["First Name"];
    String lastname = recipientDoc["Last Name"];
    await messageDanielCollection.add({
      "Topic": topic,
      "Message": message,
      "Sender": firstname + " " + lastname,
      "Email": UserSingleton.userSingleton.currentUSer.email,
      "Time": DateTime.now().millisecondsSinceEpoch
    });
  }

  Future deleteUserData({
    DocumentSnapshot doc,
    String field,
    value,
  }) async {
    await usersCollection.doc(uid).set({field: value}, SetOptions(merge: true));
  }

//When deleting an acount
  Future deleteUser({
    DocumentSnapshot doc,
    String field,
    value,
  }) async {
    await usersCollection.doc(uid).delete();
  }

/*
  Routine and schedule functions
*/

  //get routine snapshot for the current user
  Stream<QuerySnapshot> routines({@required String scheduleId}) {
    return scheduleCollection
        .doc(uid)
        .collection(addedWorkOutScheduleSubCollectionName)
        .doc(scheduleId)
        .collection(workOutRoutinesSubCollectionName)
        .snapshots();
  }

  Stream<DocumentSnapshot> particularRoutine(
      {@required String scheduleId, @required String routineId}) {
    return scheduleCollection
        .doc(uid)
        .collection(addedWorkOutScheduleSubCollectionName)
        .doc(scheduleId)
        .collection(workOutRoutinesSubCollectionName)
        .doc(routineId)
        .snapshots();
  }

//get schedules snapshot for the current user
  Stream<QuerySnapshot> get addedSchedules => scheduleCollection
      .doc(uid)
      .collection(addedWorkOutScheduleSubCollectionName)
      .snapshots();

  Future<QuerySnapshot> schedules() {
    return scheduleCollection
        .doc(uid)
        .collection(addedWorkOutScheduleSubCollectionName)
        .get();
  }

  Stream<DocumentSnapshot> particularUserSchedule(String scheduleId) {
    return scheduleCollection
        .doc(uid)
        .collection(addedWorkOutScheduleSubCollectionName)
        .doc(scheduleId)
        .snapshots();
  }

  Future<String> createRoutine({
    String cardId,
    String userId,
    String scheduleId,
    String workOutName,
    String description,
    String dateTime,
    String mediaURL,
    String mediaStoragePath,
    MediaType mediaType,
    bool exerciseDone,
    List<int> days,
    bool differUser = false,
    String differUserId,
    bool correctedAspectRatio,
  }) async {
    DocumentReference ref;
    try {
      ref = await scheduleCollection
          .doc(differUser ? differUserId : uid)
          .collection(addedWorkOutScheduleSubCollectionName)
          .doc(scheduleId)
          .collection(workOutRoutinesSubCollectionName)
          .add({
        "Card Id": cardId,
        "Creator Id": uid,
        "Schedule Id": scheduleId,
        "Name": workOutName,
        "Description": description,
        "MediaURL": mediaURL,
        "MediaPath": mediaStoragePath,
        "Mediatype": mediaType != null ? mediaType.index : MediaType.none.index,
        "Done": exerciseDone,
        "Days": days,
        "CorrectVideo": correctedAspectRatio
      });
      if (description.isNotEmpty) {
        UserSingleton.analytics.logEvent(name: "Exercise_Description");
      }
      if (mediaType != null && mediaType != MediaType.none) {
        UserSingleton.analytics.logEvent(name: "Exercise_created_with_media");
      }
      if (days.length > 1) {
        UserSingleton.analytics.logEvent(name: "Exercise_is_MultiDay");
      }
      UserSingleton.analytics.logEvent(name: "Exercise_Created");
      return ref.id;
    } catch (e) {
      return "";
    }
  }

  Future updateRoutineField({
    DocumentSnapshot doc,
    String field,
    value,
  }) async {
    await scheduleCollection
        .doc(uid)
        .collection(addedWorkOutScheduleSubCollectionName)
        .doc(doc["Schedule Id"])
        .collection(workOutRoutinesSubCollectionName)
        .doc(doc.id)
        .update({field: value});
    UserSingleton.analytics
        .logEvent(name: "Exercise_" + field.trim() + "_Updated");
  }

  Future<DocumentSnapshot> getRoutineDoc(DocumentSnapshot doc) async {
    return await scheduleCollection
        .doc(uid)
        .collection(addedWorkOutScheduleSubCollectionName)
        .doc(doc["Schedule Id"])
        .collection(workOutRoutinesSubCollectionName)
        .doc(doc.id)
        .get();
  }

  Future<DocumentSnapshot> getScheduleDoc(String docId) async {
    return await scheduleCollection
        .doc(uid)
        .collection(addedWorkOutScheduleSubCollectionName)
        .doc(docId)
        .get();
  }

  Future deleteRoutine({
    DocumentSnapshot doc,
    DaysOfTheWeek dayEnum,
    bool deletingSchedule = false,
  }) async {
    List<int> days = List<int>.from(doc["Days"]);

    if (!deletingSchedule && !days.remove(dayEnum.index)) {
      //if the schedule is being deleted just go ahead and delete the routine
      print("DataBase: DeleteRoutine Failed");
      return;
    }

    if (!deletingSchedule) {
      //messy code, clean up during optimization
      await updateRoutineField(doc: doc, field: "Days", value: days);
    }

    if (deletingSchedule || days.isEmpty) {
      String mediaURl = doc["MediaURL"];
      if (mediaURl != null && mediaURl.isNotEmpty) {
        await deleteMedia(mediaURl);
      }
      await scheduleCollection
          .doc(uid)
          .collection(addedWorkOutScheduleSubCollectionName)
          .doc(doc["Schedule Id"])
          .collection(workOutRoutinesSubCollectionName)
          .doc(doc.id)
          .delete();
    }
    print("Deleted routine");
  }

  Future deleteSchedule({
    QueryDocumentSnapshot doc,
    List<DocumentSnapshot> exercises,
  }) async {
    if (exercises != null) {
      Future.forEach(exercises, (document) async {
        await deleteRoutine(doc: document, deletingSchedule: true);
      });
    }
    await scheduleCollection
        .doc(uid)
        .collection(addedWorkOutScheduleSubCollectionName)
        .doc(doc.id)
        .delete();
  }

  Future createSchedule(String scheduleName, Map<String, int> daysFocus) async {
    try {
      await scheduleCollection
          .doc(uid)
          .collection(addedWorkOutScheduleSubCollectionName)
          .add({"Name": scheduleName, "Creator Id": uid, "Split": daysFocus});
      UserSingleton.analytics.logEvent(name: "Schedule_Created");
    } catch (e) {}
  }

  Future updateScheduleField({
    DocumentSnapshot doc,
    String field,
    value,
  }) async {
    try {
      await scheduleCollection
          .doc(uid)
          .collection(addedWorkOutScheduleSubCollectionName)
          .doc(doc.id)
          .update({field: value});
      UserSingleton.analytics.logEvent(name: "Schedule_updated");
    } catch (e) {}
  }

  Future<String> shareSchedule({
    @required DocumentSnapshot userDoc,
    @required DocumentSnapshot schedule,
  }) async {
    String errorMessage = "";
    print("Sharing Schedule to " + userDoc.id);

    //check if user already has this schedule
    CollectionReference targetUserSchedulesRef = scheduleCollection
        .doc(userDoc.id)
        .collection(addedWorkOutScheduleSubCollectionName);
    QuerySnapshot targetUserSchedules = await targetUserSchedulesRef.get();
    if (targetUserSchedules != null) {
      if (targetUserSchedules.docs != null &&
          targetUserSchedules.docs.isNotEmpty) {
        targetUserSchedules.docs.forEach((element) {
          if (element.id == schedule.id) {
            errorMessage = userDoc["First Name"] + " already has this schedule";
          }
        });
      }
    }
    if (errorMessage.isEmpty) {
      await scheduleCollection
          .doc(userDoc.id)
          .collection(addedWorkOutScheduleSubCollectionName)
          .doc(schedule.id)
          .set({
        "Name": schedule["Name"],
        "Creator Id": uid,
        "Split": schedule["Split"],
        "Description": schedule["Description"]
      }, SetOptions(merge: true));
      UserSingleton.analytics.logEvent(name: "Schedule_Shared");
    }
    return errorMessage;
  }

/*
  Media functions
*/
  Future<Map<String, String>> storeMedia(
      File file, String title, MediaType mediaType) async {
    String subfolder = "";
    switch (mediaType) {
      case MediaType.photo:
        subfolder = "Photos";
        break;
      case MediaType.video:
        subfolder = "Videos";
        break;
      case MediaType.textDocument:
        subfolder = "Documents";
        break;
      default:
        subfolder = "";
        break;
    }
    File uploadFile = file;

    if (mediaType == MediaType.video) {
      try {
        var info = await VideoCompress.compressVideo(file.path,
            includeAudio: true, quality: VideoQuality.MediumQuality);
        uploadFile = info.file;
      } catch (e) {
        VideoCompress.cancelCompression();
      }
    } else if (mediaType == MediaType.photo) {
      try {
        uploadFile = await FlutterNativeImage.compressImage(file.path);
      } catch (e) {
        //FlutterNativeImage.canc
      }
    }

    var mediaFileName = uid + DateTime.now().millisecondsSinceEpoch.toString();

    firebase_storage.TaskSnapshot task = await _mediaStorage
        .ref()
        .child(subfolder)
        .child(mediaFileName)
        .putFile(uploadFile);
    String downloadURL = await task.ref.getDownloadURL();
    String fullPath = task.ref.fullPath;
    Map<String, String> mediaFields = {
      "downloadURL": downloadURL,
      "fullPath": fullPath
    };
    return mediaFields;
  }

  Future<void> deleteMedia(String url) async {
    //await _mediaStorage.ref().child(fullPath).delete();
    firebase_storage.Reference reference = _mediaStorage.refFromURL(url);
    print(reference.fullPath);
    await reference.delete();
    print("image deleted");
  }
}
