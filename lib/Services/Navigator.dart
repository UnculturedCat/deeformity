import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Screens/WorkOutSchedulePage.dart';
import '../Screens/SearhPage.dart';
import '../Screens/Home.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../Screens/Profile.dart';

class NavigatorClass extends StatefulWidget {
  static FirebaseAnalytics analytics = new FirebaseAnalytics();
  //static FirebaseAnalyticsObserver observer = new FirebaseAnalyticsObserver(analytics: analytics);
  NavigatorClass({Key key}) : super(key: key);
  State<StatefulWidget> createState() {
    return NavigatorClassState();
  }
}

class NavigatorClassState extends State<NavigatorClass> {
  int _currentIndex = 0;
  PageController _pageController = PageController();

  List<Widget> _pages = <Widget>[
    HomePage(),
    //FinancePage(),
    SearchPage(),
    WorkoutSchedulePage(),
    //NotificationsPage(),
    ProfilePage()
  ];
  List<String> _pageNames = <String>[
    "HomePage",
    //"FinancePage",
    "SearchPage",
    "WorkoutSchedulePage",
    //"NotificationsPage",
    "ProfilePage"
  ];

  void _pageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    print('page change, current index: $_currentIndex');
    print(_pageNames[_currentIndex]);
    DatabaseReference _testRef =
        FirebaseDatabase.instance.reference().child("Navigation");
    _testRef.set(_pageNames[_currentIndex]);
    NavigatorClass.analytics.logEvent(name: "pageChanged");
  }

  void _itemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          //BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Finances"),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            label: "Search",
          ),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.calendar_circle_fill),
              label: "Workout"),
          // BottomNavigationBarItem(
          //     icon: Icon(CupertinoIcons.bell_solid), label: "Notifications"),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.profile_circled), label: "Profile")
        ],
        onTap: _itemTapped,
      ),
    );
  }
}
