import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:deeformity/User/UserClass.dart';
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

  String workOutRoutinesSubCollectionName = "Workout routines";
  String addedWorkOutScheduleSubCollectionName = "Added Workout Schedule";

  Stream<QuerySnapshot> get currentUsers {
    return usersCollection.snapshots();
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

  Future createSchedule(String scheduleName) async {
    await scheduleCollection
        .doc(uid)
        .collection(addedWorkOutScheduleSubCollectionName)
        .add({"Name": scheduleName, "User Id": uid});
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
  }) async {
    DocumentReference ref = await scheduleCollection
        .doc(uid)
        .collection(workOutRoutinesSubCollectionName)
        .add({
      "Card Id": cardId,
      "User Id": userId,
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
