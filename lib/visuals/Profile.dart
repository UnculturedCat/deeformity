import 'package:deeformity/Services/database.dart';
import 'package:deeformity/User/UserClass.dart';
import 'package:provider/provider.dart';
import 'package:deeformity/visuals/UserProfile.dart';
import 'PhysioPage.dart';
import 'package:flutter/material.dart';
import 'TrainerPage.dart';
import 'DoctorPage.dart';
import 'Settings.dart';
import 'package:deeformity/Shared/infoSingleton.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage();

  @override
  State<StatefulWidget> createState() {
    return ProfilePageState();
  }
}

class ProfilePageState extends State<ProfilePage> {
  ProfilePageState();

  TrainerPage trainerPage;
  DoctorPage doctorPage;
  PhysioPage physioPage;

  Widget build(BuildContext context) {
    return StreamProvider<UserData>.value(
        value:
            DatabaseService(uid: UserSingleton.userSingleton.userID).userData,
        child: UserProfile());
  }
}
