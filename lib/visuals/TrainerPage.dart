import 'package:deeformity/visuals/Settings.dart';
import 'package:flutter/material.dart';
import '../Screens/Profile.dart';

class TrainerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TrainerPageState();
  }
}

String _nameTrainer = "Otto Octavious";
String _trainerCompany = "OctoLabFitness Enschede";

class TrainerPageState extends State<TrainerPage> {
  void handleVoiceCallTrainer() {
    print("TrainerPage: Voice call trainer clicked");
  }

  void handleVideoeCallTrainer() {
    print("TrainerPage: Video call trainer clicked");
  }

  void handleGoToSettings() {
    //Navigator.removeRouteBelow(context, anchorRoute)
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SettingsPage();
    }));
  }

  void handleProfile() {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
      return ProfilePage();
    }), (route) => false);
    // Navigator.pop(context);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(21, 33, 47, 100),
      appBar: AppBar(
        title: Text(
          "Trainer",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: Color.fromRGBO(21, 33, 47, 15),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.settings),
              color: Colors.white,
              iconSize: 30,
              onPressed: handleGoToSettings),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
          color: Color.fromRGBO(21, 33, 47, 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // FlatButton
              // (
              //   onPressed: doSomeThing,
              //   child: Text("Settings", style: TextStyle(fontSize:20, color: Colors.white, fontWeight: FontWeight.w300,)),
              // ),
              IconButton(
                  icon: Icon(Icons.home),
                  color: Colors.white,
                  iconSize: 30,
                  onPressed: handleProfile),
              SizedBox(
                width: 10,
              ),
            ],
          )),
      body: SafeArea(
          child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      //colors: [Colors.lightBlue, Colors.blueGrey]
                      colors: [
                    Color.fromRGBO(21, 33, 47, 1),
                    Color.fromRGBO(9, 16, 23, 1)
                  ])),
              child: ListView(
                children: <Widget>[
                  //Information Column
                  Column(
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.only(top: 30),
                          child: Column(children: <Widget>[
                            SizedBox(
                                width: 100,
                                height: 100,
                                child: Container(
                                  color: Colors.lightBlue[50],
                                )),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "$_nameTrainer",
                              style:
                                  TextStyle(fontSize: 30, color: Colors.white),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text("$_trainerCompany",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300))
                          ])),
                      Container(
                          padding:
                              EdgeInsets.only(top: 30, left: 90, right: 90),
                          child: Column(
                            children: <Widget>[
                              Container(
                                //color: Colors.black10,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    IconButton(
                                        icon: Icon(Icons.call),
                                        color: Colors.white,
                                        iconSize: 50,
                                        onPressed: handleVoiceCallTrainer),
                                    SizedBox(width: 10),
                                    IconButton(
                                        icon: Icon(Icons.videocam),
                                        color: Colors.white,
                                        iconSize: 50,
                                        onPressed: handleVideoeCallTrainer),
                                  ],
                                ),
                              )
                            ],
                          ))
                    ],
                  ),

                  Container(
                      padding: EdgeInsets.only(top: 30, left: 10, right: 10),
                      child: Column(
                        children: <Widget>[
                          TextField(
                            decoration: InputDecoration(
                              labelText: "Message $_nameTrainer",
                              filled: true,
                              fillColor: Color.fromRGBO(21, 33, 47, 10),
                              labelStyle: TextStyle(
                                  fontSize: 15, color: Colors.white10),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              icon: Icon(Icons.message, color: Colors.white),
                            ),
                          ),
                        ],
                      ))
                ],
              ))),
    );
  }
}
