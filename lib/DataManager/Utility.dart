import 'package:deeformity/User/UserClass.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'EventData.dart';
import 'package:deeformity/Shared/constants.dart';

class WorkOutRoutine {
  String name;
  String description;
  //Image media;
  int reps;
  int sets;
  WorkOutRoutine(this.description, this.name, this.reps, this.sets);
}

class ScheduleData {
  String dateString;
  final DateTime date;
  ActivityType activityType;
  List<Event> events;
  ScheduleData(this.activityType, this.date /*this.dateString, this.events*/);
}

class Utility {
  void getSchedule() {
    User user;
  }

  void addTrainer() {}
  void initialiseUser() {}
}
