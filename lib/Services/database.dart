import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';

import 'package:flutter/material.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  firebase_storage.FirebaseStorage _mediaStorage =
      firebase_storage.FirebaseStorage.instance;

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection("Users");

  final CollectionReference scheduleCollection =
      FirebaseFirestore.instance.collection("Schedules");

  String workOutRoutinesSubCollectionName = "Workout routines";
  String addedWorkOutScheduleSubCollectionName = "Added Workout Schedule";
  String addedUsers = "Added Users";

  Stream<QuerySnapshot> get currentUsers {
    return usersCollection.snapshots();
  }

  Stream<QuerySnapshot> get addedUsersSnapShot {
    return usersCollection
        .doc(UserSingleton.userSingleton.userID)
        .collection(addedUsers)
        .snapshots();
  }

  Stream<QuerySnapshot> get addedSchedules => scheduleCollection
      .doc(UserSingleton.userSingleton.currentUSer.uid)
      .collection(addedWorkOutScheduleSubCollectionName)
      .snapshots();

  //get routine snapshot for the current user
  Stream<QuerySnapshot> get routines => scheduleCollection
      .doc(UserSingleton.userSingleton.currentUSer.uid)
      .collection(workOutRoutinesSubCollectionName)
      .snapshots();

//Get snapshot of current user
  Stream<DocumentSnapshot> get userData => usersCollection
      .doc(UserSingleton.userSingleton.currentUSer.uid)
      .snapshots();

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
    DocumentSnapshot doc;
    doc = await usersCollection.doc(docId).get();

    return doc;
  }

  Future<void> connectWithUser(QueryDocumentSnapshot userToAdd) async {
    await usersCollection
        .doc(uid)
        .collection(addedUsers)
        .doc(userToAdd.id)
        .set({
      "User Id": userToAdd.id,
      "First Name": userToAdd.data()["First Name"],
      "Last Name": userToAdd.data()["Last Name"],
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
    });
  }

  Future<void> disconnectWithUser(QueryDocumentSnapshot userToRemove) async {
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
      String differUserId}) async {
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
    });
    return ref.id;
  }

  Future updateRoutineField({
    QueryDocumentSnapshot doc,
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
    QueryDocumentSnapshot doc,
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
    List<QueryDocumentSnapshot> routineSnapshot,
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
    QueryDocumentSnapshot doc,
    String field,
    value,
  }) async {
    await scheduleCollection
        .doc(uid)
        .collection(addedWorkOutScheduleSubCollectionName)
        .doc(doc.id)
        .update({field: value});
  }

  Future shareSchedule({
    @required QueryDocumentSnapshot userDoc,
    @required QueryDocumentSnapshot schedule,
    @required List<QueryDocumentSnapshot> schedulesExercises,
  }) async {
    print("Sharing Schedule to " + userDoc.id);
    await scheduleCollection
        .doc(userDoc.id)
        .collection(addedWorkOutScheduleSubCollectionName)
        .add({"Name": schedule.data()["Name"], "Creator Id": uid});
    Future.forEach(schedulesExercises, (QueryDocumentSnapshot exercise) async {
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
      );
    });

    print("Shared Schedule to " + userDoc.id);
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
