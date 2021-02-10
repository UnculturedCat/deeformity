import 'package:deeformity/Example.dart';
import 'package:deeformity/Services/database.dart';
import 'package:deeformity/User/UserClass.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:deeformity/visuals/UserProfile.dart';
import '../visuals/PhysioPage.dart';
import 'package:flutter/material.dart';
import '../visuals/TrainerPage.dart';
import '../visuals/DoctorPage.dart';
import '../visuals/Settings.dart';
import 'package:deeformity/Shared/infoSingleton.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage();

  @override
  State<StatefulWidget> createState() {
    return ProfilePageState();
  }
}

class ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  ProfilePageState();

  TrainerPage trainerPage;
  DoctorPage doctorPage;
  PhysioPage physioPage;

  Widget build(BuildContext context) {
    super.build(context);
    return StreamProvider<UserData>.value(
        value:
            DatabaseService(uid: UserSingleton.userSingleton.userID).userData,
        child: UserProfile());
  }

  @override
  bool get wantKeepAlive => true;
}
