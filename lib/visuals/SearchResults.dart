import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:flutter/material.dart';
import 'package:deeformity/Services/database.dart';
import 'package:deeformity/Shared/loading.dart';

class SearchResults extends StatefulWidget {
  final String searchQuery;
  final String textBoxQuery;
  SearchResults(this.searchQuery, this.textBoxQuery);
  @override
  _SearchResultsState createState() => _SearchResultsState(this.searchQuery);
}

class _SearchResultsState extends State<SearchResults> {
  bool loading = false;
  bool gotSnaps = false;
  bool queryChanged = false;
  String query;
  QuerySnapshot querySnapshot;
  List<QueryDocumentSnapshot> snapshot;
  _SearchResultsState(this.query);

  void getSnapshots() async {
    loading = true;
    querySnapshot = await DatabaseService().searchForUser(query);
    snapshot = querySnapshot.docs;
    if (snapshot != null) {
      loading = false;
      gotSnaps = true;
      setState(() {});
    }
  }

  void openUserCard(QueryDocumentSnapshot doc) {}

  Widget createUserCard(QueryDocumentSnapshot doc) {
    if (doc.id == UserSingleton.userSingleton.userID) return SizedBox();
    String firstName = doc.data()["First Name"];
    String lastName = doc.data()["Last Name"];
    String profession = doc.data()["Profession"] ?? "Private user";
    String userFullName = firstName + " " + lastName;

    //Fliters displayed users according to textForm input
    if (widget.textBoxQuery.isNotEmpty) {
      int iterationPos = 0;
      for (var s in widget.textBoxQuery.characters) {
        if (s.toUpperCase() != userFullName[iterationPos].toUpperCase())
          return SizedBox();
        iterationPos += 1;
      }
    }
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: InkWell(
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Container(
            child: ListTile(
              leading: CircleAvatar(),
              title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firstName + " " + lastName,
                      style: TextStyle(
                        color: Color.fromRGBO(21, 33, 47, 1),
                      ),
                    ),
                    Text(
                      profession,
                      style: TextStyle(
                          color: Color.fromRGBO(21, 33, 47, 1),
                          fontWeight: FontWeight.w300,
                          fontSize: 12),
                    )
                  ]),
            ),
          ),
        ),
        onTap: () {
          openUserCard(doc);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      queryChanged = false;
      if (query != widget.searchQuery) {
        query = widget.searchQuery;
        queryChanged = true;
      }
      if (queryChanged || snapshot == null) {
        getSnapshots();
      }
    });
    return loading
        ? Center(child: Loading())
        : snapshot.isEmpty
            ? Text("No active user found in location")
            : ListView(
                children: [for (var doc in snapshot) createUserCard(doc)],
              );
  }
}
