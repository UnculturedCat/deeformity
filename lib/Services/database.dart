import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:deeformity/User/UserClass.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  firebase_storage.FirebaseStorage _mediaStorage =
      firebase_storage.FirebaseStorage.instance;

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection("Users");

  final CollectionReference scheduleCollection =
      FirebaseFirestore.instance.collection("Schedules");

  String scheduleSubCollectionName = "Daily routines";
  String workOutScheduleCollectionName = "Workout routines";

  Stream<QuerySnapshot> get currentUsers {
    return usersCollection.snapshots();
  }

  //get schedule snapshot for the current user
  Stream<QuerySnapshot> get schedule => scheduleCollection
      .doc(UserSingleton.userSingleton.currentUSer.uid)
      .collection(workOutScheduleCollectionName)
      .snapshots();

  Stream<UserData> get userData => usersCollection
      .doc(UserSingleton.userSingleton.currentUSer.uid)
      .snapshots()
      .map((doc) => createUserDataFromSnapshot(doc));

  Stream<QuerySnapshot> get allUsers => usersCollection.snapshots();

  UserData createUserDataFromSnapshot(DocumentSnapshot snap) {
    UserSingleton.userSingleton.userData = UserData(
        firstName: snap.data()["First Name"] ?? "Unknown",
        lastName: snap.data()["Last Name"] ?? "Unknown",
        location: snap.data()["Location"] ?? "Unknown");
    return UserData(
        firstName: snap.data()["First Name"] ?? "Unknown",
        lastName: snap.data()["Last Name"] ?? "Unknown",
        location: snap.data()["Location"] ?? "Unknown");
  }

  Future createUserData(
      {String firstName,
      String lastName,
      bool professionalAccount,
      String location}) async {
    await usersCollection.doc(uid).set({
      "First Name": firstName,
      "Last Name": lastName,
      "Location": location,
      "Professional Acc": professionalAccount
    });
  }

  Future saveWorkoutSchedule(String workoutScheduleName, String day) async {}

  Future updateUserData({bool professionalAccount, String location}) async {}

  Future<String> createSchedule(
      {String cardId,
      String userId,
      String scheduleName,
      String workOutName,
      String description,
      String day,
      String dateTime,
      String mediaURL,
      String mediaStoragePath,
      MediaType mediaType}) async {
    DocumentReference ref = await scheduleCollection
        .doc(uid)
        .collection(workOutScheduleCollectionName)
        .add({
      "Card Id": cardId,
      "User Id": userId,
      "Day": day,
      "Schedule Name": scheduleName,
      "Name": workOutName,
      "Description": description,
      "MediaURL": mediaURL,
      "Media Path": mediaStoragePath,
      "Media type": mediaType.index
    });
    return ref.id;
  }

  Future updateRoutineInfo(String cardId) async {
    await scheduleCollection
        .doc(uid)
        .collection(workOutScheduleCollectionName)
        .doc(cardId)
        .update({"Card Id": cardId});
  }

  Future deleteRoutine(QueryDocumentSnapshot doc) async {
    await scheduleCollection
        .doc(uid)
        .collection(workOutScheduleCollectionName)
        .doc(doc.id)
        .delete();
  }

  Future<QuerySnapshot> searchForUser(String searchQuery) async {
    return await usersCollection
        .where("Location", isEqualTo: searchQuery)
        .get();
  }

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
