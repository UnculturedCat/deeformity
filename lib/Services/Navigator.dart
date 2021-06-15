import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Screens/MessagesPage.dart';
import 'package:deeformity/Services/database.dart';
import 'package:deeformity/Shared/loading.dart';
//import 'package:deeformity/Shared/infoSingleton.dart';

import 'package:deeformity/User/CreateUserPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Screens/WorkOutSchedulePage.dart';
import '../Screens/SearhPage.dart';
import '../Screens/Profile.dart';

class NavigatorClass extends StatefulWidget {
  final User user;
  //static FirebaseAnalyticsObserver observer = new FirebaseAnalyticsObserver(analytics: analytics);
  NavigatorClass({Key key, this.user}) : super(key: key);
  State<StatefulWidget> createState() {
    return NavigatorClassState();
  }
}

class NavigatorClassState extends State<NavigatorClass> {
  int _currentIndex = 0;
  PageController _pageController = PageController();
  List<DocumentSnapshot> allUsers = [];

  List<Widget> _pages = <Widget>[
    //HomePage(),
    //FinancePage(),
    WorkoutSchedulePage(),
    SearchPage(),
    MessagesPage(),
    ProfilePage()
  ];
  List<String> _pageNames = <String>[
    //"HomePage",
    //"FinancePage",
    "SearchPage",
    "WorkoutSchedulePage",
    "MessagesPage",
    "ProfilePage"
  ];

  void _pageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    DatabaseReference _testRef =
        FirebaseDatabase.instance.reference().child("Navigation");
    _testRef.set(_pageNames[_currentIndex]);
    // UserSingleton.analytics.logEvent(name: "pageChanged");
  }

  void _itemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: DatabaseService().allUsers,
        builder: (context, snapshot) {
          bool userFound = false;
          bool loading = true;
          if (snapshot != null && snapshot.data != null) {
            allUsers = snapshot.data.docs;
            allUsers.forEach((doc) {
              if (doc.id == widget.user.uid) {
                userFound = true;
              }
            });
            loading = false;
          }
          return loading
              ? Loading()
              : userFound
                  ? Scaffold(
                      body: PageView(
                        controller: _pageController,
                        children: _pages,
                        onPageChanged: _pageChanged,
                      ),
                      bottomNavigationBar: BottomNavigationBar(
                        type: BottomNavigationBarType.fixed,
                        currentIndex: _currentIndex,
                        selectedItemColor: Color.fromRGBO(21, 33, 47, 1),
                        iconSize: 30,
                        backgroundColor: Colors.white,
                        unselectedItemColor: Colors.grey,
                        //elevation: 8,
                        items: [
                          //BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                          //BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Finances"),

                          BottomNavigationBarItem(
                              icon: Icon(Icons.fitness_center_rounded),
                              label: "Workout"),
                          BottomNavigationBarItem(
                            icon: Icon(CupertinoIcons.search),
                            label: "Search",
                          ),
                          BottomNavigationBarItem(
                              icon: Icon(CupertinoIcons.chat_bubble),
                              label: "Messages"),
                          BottomNavigationBarItem(
                              icon: Icon(CupertinoIcons.profile_circled),
                              label: "Profile")
                        ],
                        onTap: _itemTapped,
                      ),
                    )
                  : CreateUserPage(
                      widget.user); //if user not create navigate to this page
        });
  }
}
