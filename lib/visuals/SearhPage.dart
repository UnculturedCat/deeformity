import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Services/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:deeformity/visuals/SearchResults.dart';

class SearchPage extends StatefulWidget {
  final String pageName = "SearchPage";
  SearchPage();

  @override
  State<StatefulWidget> createState() {
    return SearchPageSate();
  }
}

class SearchPageSate extends State<SearchPage> {
  String searchquery = dropDownLocations.first.value;
  SearchPageSate();
  Widget build(BuildContext context) {
    return StreamProvider<QuerySnapshot>.value(
      value: DatabaseService().allUsers,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(left: 5),
                child: Text(
                  "Location:",
                  style: TextStyle(color: Color.fromRGBO(24, 41, 57, 1)),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: DropdownButton<String>(
                  icon: Icon(Icons.location_pin),
                  iconEnabledColor: Colors.redAccent,
                  iconSize: 20.0,
                  value: searchquery,
                  dropdownColor: Colors.white,
                  style: TextStyle(color: Color.fromRGBO(24, 41, 57, 1)),
                  items: dropDownLocations,
                  onChanged: (String currentVal) {
                    setState(() {
                      searchquery = currentVal;
                    });
                  },
                ),
              )
            ],
          ),
        ),
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.only(top: 10, left: 20, right: 20),
            child: ListView(
              children: [
                // TextFormField(
                //   decoration: textInputDecorationWhite.copyWith(
                //       prefixIcon: Icon(CupertinoIcons.search)),
                //   onChanged: (value) {
                //     setState(() {
                //       searchquery = value;
                //     });
                //   },
                // ),
                SearchResults(searchquery)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
