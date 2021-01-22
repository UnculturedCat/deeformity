import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../visuals/Finances.dart';
import '../visuals/MailPage.dart';
import '../visuals/NotificationsPage.dart';
import '../visuals/SearhPage.dart';
import '../visuals/Home.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import '../visuals/Profile.dart';

class NavigatorClass extends StatefulWidget {
  static FirebaseAnalytics analytics = new FirebaseAnalytics();
  //static FirebaseAnalyticsObserver observer = new FirebaseAnalyticsObserver(analytics: analytics);
  NavigatorClass();
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
    //SearchPage(),
    MailPage(),
    NotificationsPage(),
    ProfilePage()
  ];
  List<String> _pageNames = <String>[
    "HomePage",
    //"FinancePage",
    //"SearchPage",
    "MailPage",
    "NotificationsPage",
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
        //elevation: 8,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          //BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Finances"),
          //BottomNavigationBarItem( icon: Icon(Icons.search),label: "Search",),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: "Mail"),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none), label: "Notifications"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile")
        ],
        onTap: _itemTapped,
      ),
    );
  }
}
