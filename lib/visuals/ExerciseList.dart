import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExerciseList extends StatefulWidget {
  @override
  _ExerciseListState createState() => _ExerciseListState();
}

class _ExerciseListState extends State<ExerciseList> {
  @override
  Widget build(BuildContext context) {
    final exercises = Provider.of<QuerySnapshot>(context);
    if (exercises != null && exercises.docs != null) {
      return Column();
    } else {
      return Text("No exercises for the day");
    }
  }
}
