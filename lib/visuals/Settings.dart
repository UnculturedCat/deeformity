import 'package:deeformity/Services/Authentication.dart';
import 'package:flutter/material.dart';
import '../Screens/Profile.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingsPageState();
  }
}

class SettingsPageState extends State<SettingsPage> {
  void handleLogout() {
    context.read<AuthenticationService>().signOut();
    Navigator.pop(context);
  }

  void handleProfile() {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
      return ProfilePage();
    }), (route) => false);
  }

  void changeInfo() {}

  void removeTrainer() {}

  void removeDoctor() {}

  void removeTherapist() {}

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(21, 33, 47, 100),

      appBar: AppBar(
        backgroundColor: Color.fromRGBO(21, 33, 47, 15),
      ),

      //Page Body
      body: SafeArea(
          child: ListView(
        children: <Widget>[
          //Place holder
          SizedBox(
            height: 480,
          ), //Spacer
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                RaisedButton(
                    onPressed: handleLogout,
                    child: Text(
                      "Logout",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    color: Color.fromRGBO(36, 36, 36, 100)),
              ],
            ),
          )
        ],
      )),
    );
  }
}
