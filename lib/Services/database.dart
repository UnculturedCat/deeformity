import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';

import 'package:flutter/material.dart';

class DatabaseService {
  final String uid;
  DatabaseService({@required this.uid});

  firebase_storage.FirebaseStorage _mediaStorage =
      firebase_storage.FirebaseStorage.instance;

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection("Users");

  final CollectionReference scheduleCollection =
      FirebaseFirestore.instance.collection("Schedules");

  String workOutRoutinesSubCollectionName = "Workout routines";
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

  Stream<QuerySnapshot> get addedSchedules => scheduleCollection
      .doc(uid)
      .collection(addedWorkOutScheduleSubCollectionName)
      .snapshots();

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
    bool professionalAccount,
    String location,
  }) async {
    await usersCollection.doc(uid).set({
      "First Name": firstName,
      "Last Name": lastName,
      "Location": location,
      "Professional Acc": professionalAccount
    });
  }

  Future<DocumentSnapshot> getParticularUserDoc(String docId) async {
    var doc;
    doc = await usersCollection.doc(docId).get();

    return doc;
  }

  Future<void> connectWithUser(DocumentSnapshot userToAdd) async {
    await usersCollection
        .doc(uid)
        .collection(addedUsers)
        .doc(userToAdd.id)
        .set({
      "User Id": userToAdd.id,
      "First Name": userToAdd.data()["First Name"],
      "Last Name": userToAdd.data()["Last Name"],
      "Profile Picture Url": userToAdd.data()["Profile Picture Url"],
      "About": userToAdd.data()["About"]
    });

    //add to other user's addedUsers collection
    await usersCollection
        .doc(userToAdd.id)
        .collection(addedUsers)
        .doc(uid)
        .set({
      "User Id": UserSingleton.userSingleton.userDataSnapShot.id,
      "First Name":
          UserSingleton.userSingleton.userDataSnapShot.data()["First Name"],
      "Last Name":
          UserSingleton.userSingleton.userDataSnapShot.data()["Last Name"],
      "Profile Picture Url": UserSingleton.userSingleton.userDataSnapShot
          .data()["Profile Picture Url"]
    });
  }

  Future<void> disconnectWithUser(DocumentSnapshot userToRemove) async {
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
  }

  Future<QuerySnapshot> searchForUser(String searchQuery) async {
    return await usersCollection
        .where("Location", isEqualTo: searchQuery)
        .get();
  }

  Future updateUserData({
    QueryDocumentSnapshot doc,
    String field,
    value,
  }) async {
    await usersCollection.doc(uid).set({field: value}, SetOptions(merge: true));
  }

/*
  Routine and schedule functions
*/

  //get routine snapshot for the current user
  Stream<QuerySnapshot> get routines => scheduleCollection
      .doc(UserSingleton.userSingleton.userID)
      .collection(workOutRoutinesSubCollectionName)
      .snapshots();

  Future<String> createRoutine(
      {String cardId,
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
      bool correctedAspectRatio}) async {
    DocumentReference ref = await scheduleCollection
        .doc(differUser ? differUserId : uid)
        .collection(workOutRoutinesSubCollectionName)
        .add({
      "Card Id": cardId,
      "Creator Id": uid,
      "Schedule Id": scheduleId,
      "Name": workOutName,
      "Description": description,
      "MediaURL": mediaURL,
      "Media Path": mediaStoragePath,
      "Media type": mediaType != null ? mediaType.index : MediaType.none.index,
      "Done": exerciseDone,
      "Days": days,
      "CorrectVideo": correctedAspectRatio
    });
    return ref.id;
  }

  Future updateRoutineField({
    DocumentSnapshot doc,
    String field,
    value,
  }) async {
    await scheduleCollection
        .doc(uid)
        .collection(workOutRoutinesSubCollectionName)
        .doc(doc.id)
        .update({field: value});
  }

  Future deleteRoutine({
    DocumentSnapshot doc,
    DaysOfTheWeek dayEnum,
    bool deletingSchedule = false,
  }) async {
    List<int> days = List<int>.from(doc.data()["Days"]);

    if (!deletingSchedule && !days.remove(dayEnum.index)) {
      //if the schedule is being deleted just go ahead and delete the routine
      print("DataBase: DeleteRoutine Failed");
      return;
    }

    if (!deletingSchedule) {
      //messy code, clean up during optimization
      await updateRoutineField(doc: doc, field: "Days", value: days);
      doc.data()["Days"] = days;
    }

    if (deletingSchedule || days.isEmpty) {
      String mediaURl = doc.data()["MediaURL"];
      if (mediaURl != null && mediaURl.isNotEmpty) {
        await deleteMedia(mediaURl);
      }
      await scheduleCollection
          .doc(uid)
          .collection(workOutRoutinesSubCollectionName)
          .doc(doc.id)
          .delete();
    }
    print("Deleted routine");
  }

  Future deleteSchedule(
    QueryDocumentSnapshot doc,
    List<DocumentSnapshot> routineSnapshot,
  ) async {
    if (routineSnapshot != null) {
      Future.forEach(routineSnapshot, (document) async {
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
    await scheduleCollection
        .doc(uid)
        .collection(addedWorkOutScheduleSubCollectionName)
        .add({"Name": scheduleName, "Creator Id": uid, "Split": daysFocus});
  }

  Future updateScheduleField({
    DocumentSnapshot doc,
    String field,
    value,
  }) async {
    await scheduleCollection
        .doc(uid)
        .collection(addedWorkOutScheduleSubCollectionName)
        .doc(doc.id)
        .update({field: value});
  }

  Future<String> shareSchedule({
    @required DocumentSnapshot userDoc,
    @required DocumentSnapshot schedule,
    @required List<DocumentSnapshot> schedulesExercises,
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
            errorMessage =
                userDoc.data()["First Name"] + " already has this schedule";
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
        "Name": schedule.data()["Name"],
        "Creator Id": uid,
        "Split": schedule.data()["Split"],
        "Description": schedule.data()["Description"]
      }, SetOptions(merge: true));
      Future.forEach(schedulesExercises, (DocumentSnapshot exercise) async {
        await createRoutine(
          differUser: true,
          differUserId: userDoc.id,
          cardId: exercise.data()["Card Id"],
          scheduleId: exercise.data()["Schedule Id"],
          workOutName: exercise.data()["Name"],
          description: exercise.data()["Description"],
          mediaURL: exercise.data()["MediaURL"],
          mediaStoragePath: exercise.data()["mediaStoragePath"],
          mediaType: MediaType.values[exercise.data()["Media type"]],
          days: List<int>.from(exercise.data()["Days"]),
          correctedAspectRatio: exercise.data()["CorrectVideo"],
        );
      });
    }
    print("Shared Schedule to " + userDoc.id);
    print(errorMessage);
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
    var mediaFileName = uid + DateTime.now().millisecondsSinceEpoch.toString();

    firebase_storage.TaskSnapshot task = await _mediaStorage
        .ref()
        .child(subfolder)
        .child(mediaFileName)
        .putFile(file);
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
