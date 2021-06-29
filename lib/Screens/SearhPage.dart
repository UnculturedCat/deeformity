import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Services/database.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
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

class SearchPageSate extends State<SearchPage>
    with AutomaticKeepAliveClientMixin {
  String searchquery = dropDownLocations.first.value;
  String textBoxquery = "";
  SearchPageSate();
  Widget build(BuildContext context) {
    super.build(context);
    return StreamProvider<QuerySnapshot>.value(
      initialData: null,
      value: DatabaseService(uid: UserSingleton.userSingleton.userID).allUsers,
      child: GestureDetector(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            shadowColor: Colors.white24,
            title: TextFormField(
              decoration: textInputDecorationWhite.copyWith(
                prefixIcon: Icon(
                  CupertinoIcons.search,
                ),
                hintStyle: TextStyle(
                  fontSize: fontSizeInputHint,
                ),
                hintText: "Who are you looking for?",
              ),
              onChanged: (value) {
                setState(() {
                  textBoxquery = value;
                });
              },
            ),
          ),
          body: SafeArea(
            child: textBoxquery.isEmpty
                ? Center(
                    child: Text(
                      "Search",
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            //Location not needed
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.start,
                            //   children: [
                            //     Container(
                            //       padding: EdgeInsets.only(left: 5),
                            //       child: Text(
                            //         "Search Location:",
                            //         style: TextStyle(
                            //           color: elementColorWhiteBackground,
                            //           fontSize: fontSize,
                            //         ),
                            //       ),
                            //     ),
                            //     Container(
                            //       padding: EdgeInsets.only(left: 10, right: 10),
                            //       child: DropdownButton<String>(
                            //         icon: Icon(Icons.location_pin),
                            //         iconEnabledColor: Colors.redAccent,
                            //         iconSize: 20.0,
                            //         value: searchquery,
                            //         dropdownColor: Colors.white,
                            //         style:
                            //             TextStyle(color: elementColorWhiteBackground),
                            //         items: dropDownLocations,
                            //         onChanged: (String currentVal) {
                            //           setState(() {
                            //             searchquery = currentVal;
                            //           });
                            //         },
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            // TextFormField(
                            //   decoration: textInputDecorationWhite.copyWith(
                            //     prefixIcon: Icon(
                            //       CupertinoIcons.search,
                            //     ),
                            //   ),
                            //   onChanged: (value) {
                            //     setState(() {
                            //       textBoxquery = value;
                            //     });
                            //   },
                            // ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                            padding:
                                EdgeInsets.only(top: 10, left: 20, right: 20),
                            child: SearchResults(searchquery, textBoxquery)),
                      ),
                    ],
                  ),
          ),
        ),
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
