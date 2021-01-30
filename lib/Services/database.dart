import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:deeformity/User/UserClass.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  Stream<QuerySnapshot> get currentUsers {
    return usersCollection.snapshots();
  }

  //get schedule snapshot for the current user
  Stream<QuerySnapshot> get schedule => scheduleCollection
      .doc(UserSingleton.userSingleton.currentUSer.uid)
      .collection(scheduleSubCollectionName)
      .snapshots();

  Stream<UserData> get userData => usersCollection
      .doc(UserSingleton.userSingleton.currentUSer.uid)
      .snapshots()
      .map((doc) => createUserDataFromSnapshot(doc));

  Stream<QuerySnapshot> get allUsers => usersCollection.snapshots();

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection("Users");

  final CollectionReference scheduleCollection =
      FirebaseFirestore.instance.collection("Schedules");

  String scheduleSubCollectionName = "Daily routines";

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

  Future updateUserData({bool professionalAccount, String location}) async {}

  Future<String> createSchedule(
      {String cardId,
      String userId,
      String category,
      String workOutName,
      int sets,
      int reps,
      String description,
      String scheduleType,
      String date,
      String dateTime,
      int frequency}) async {
    DocumentReference ref =
        await scheduleCollection.doc(uid).collection("Daily routines").add({
      "Card Id": cardId,
      "User Id": userId,
      "Date": date,
      "Name": workOutName,
      "Category": category,
      "Schedule Type": scheduleType,
      "Sets": sets,
      "Reps": reps,
      "Description": description,
      "Frequency": frequency,
      "DateTime": dateTime
    });
    return ref.id;
  }

  Future updateRoutineInfo(String cardId) async {
    await scheduleCollection
        .doc(uid)
        .collection(scheduleSubCollectionName)
        .doc(cardId)
        .update({"Card Id": cardId});
  }

  Future deleteRoutine(QueryDocumentSnapshot doc) async {
    await scheduleCollection
        .doc(uid)
        .collection(scheduleSubCollectionName)
        .doc(doc.id)
        .delete();
  }

  Future<QuerySnapshot> searchForUser(String searchQuery) async {
    return await usersCollection
        .where("Location", isEqualTo: searchQuery)
        .get();
  }
  // Future<String> fetchUserData() {
  //   userCollection.doc(uid).update(data)
  // }
}
