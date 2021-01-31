import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:flutter/material.dart';
import 'package:deeformity/Services/database.dart';
import 'package:deeformity/Shared/loading.dart';

class SearchResults extends StatefulWidget {
  final String searchQuery;
  SearchResults(this.searchQuery);
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

  Widget createUserCard(QueryDocumentSnapshot doc) {
    if (doc.id == UserSingleton.userSingleton.userID) return SizedBox();
    return Container(
        padding: EdgeInsets.only(top: 100, bottom: 100),
        child: Text(doc.data()["First Name"]));
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
        ? Loading()
        : snapshot.isEmpty
            ? Text("No active user found in location")
            : Column(
                children: [for (var doc in snapshot) createUserCard(doc)],
              );
  }
}
