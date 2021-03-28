import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:deeformity/User/otherProfile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchResults extends StatefulWidget {
  final String locationQuery;
  final String textBoxQuery;
  SearchResults(this.locationQuery, this.textBoxQuery);
  @override
  _SearchResultsState createState() => _SearchResultsState(this.locationQuery);
}

class _SearchResultsState extends State<SearchResults> {
  bool loading = false;
  bool gotSnaps = false;
  bool queryChanged = false;
  String query;
  QuerySnapshot querySnapshot;
  List<QueryDocumentSnapshot> snapshot;
  _SearchResultsState(this.query);

  //Uncomment for manual retreival of QuerySnapshots. Was done for study purposes
  /*void getSnapshots() async {
    loading = true;
    querySnapshot = await DatabaseService().searchForUser(query);
    snapshot = querySnapshot.docs;
    if (snapshot != null) {
      loading = false;
      gotSnaps = true;
      setState(() {});
    }
  }*/

  void openUserCard(QueryDocumentSnapshot doc) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return OtherUserProfile(doc);
    }));
  }

  Widget createUserCard(QueryDocumentSnapshot doc) {
    if ((doc.id == UserSingleton.userSingleton.userID ||
            doc.data()["Location"] != widget.locationQuery) &&
        widget.textBoxQuery.isEmpty) return SizedBox();
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

    //create card
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
                      userFullName,
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
    final snaps = Provider.of<QuerySnapshot>(context);

    /* //Uncomment for manual retreival of QuerySnapshots. Was done for study purposes
    setState(() {
      queryChanged = false;
      if (query != widget.locationQuery) {
        query = widget.locationQuery;
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
              );*/

    return snaps != null && snaps.docs.isNotEmpty
        ? ListView(
            children: snaps.docs.map((doc) => createUserCard(doc)).toList())
        : SizedBox();
  }
}
