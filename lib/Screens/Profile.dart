import 'package:deeformity/Services/database.dart';
import 'package:deeformity/User/UserClass.dart';
import 'package:provider/provider.dart';
import 'package:deeformity/visuals/UserProfile.dart';

import 'package:flutter/material.dart';

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
