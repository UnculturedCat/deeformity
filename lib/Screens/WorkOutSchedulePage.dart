import 'package:deeformity/Shared/constants.dart';
import 'package:flutter/material.dart';

class WorkoutSchedulePage extends StatefulWidget {
  final String pageName = "WorkoutSchedulePage";
  WorkoutSchedulePage();

  @override
  State<StatefulWidget> createState() {
    return WorkoutSchedulePageState();
  }
}

class WorkoutSchedulePageState extends State<WorkoutSchedulePage>
    with AutomaticKeepAliveClientMixin {
  WorkoutSchedulePageState();

  List<String> days = ["SUN", "MON", "TUE", "WED", "THUR", "FRI", "SAT"];
  List<String> exercises = [
    "Squat",
    "Bench",
    "deadlift",
    "Press",
    "Ugh",
    "Um",
    "Uhm"
  ];

  Widget createWorkOutRoutineCard(String exercise) {
    return Container(
      key: Key(exercise),
      height: MediaQuery.of(context).size.height / 4,
      width: MediaQuery.of(context).size.width / 2.2,
      padding: EdgeInsets.only(left: 2, right: 2),
      child: InkWell(
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Center(child: Text(exercise)),
        ),
      ),
    );
  }

  Widget createDayRow(String day) {
    return Container(
      key: Key(day),
      child: Row(
        children: [
          Container(
            child: InkWell(
                child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 4,
                      width: MediaQuery.of(context).size.width / 2.2,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              //colors: [Colors.lightBlue, Colors.blueGrey]
                              colors: [
                                Color.fromRGBO(47, 72, 100, 1),
                                Color.fromRGBO(24, 41, 57, 1)
                              ])),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              day,
                              style: cardHeaderStyle,
                            ),
                          ),
                          Container(
                            //insert Icon
                            child: Text("Targeted area"),
                          )
                        ],
                      ),
                    ))),
          ),
          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.height / 4,
              child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: exercises
                      .map((exercise) => createWorkOutRoutineCard(exercise))
                      .toList()),
            ),
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.only(top: 10, left: 10, right: 10),
        child: Column(children: [
          Container(
            padding: EdgeInsets.only(bottom: 20),
            child: Row(children: [Text("Current Schdule")]),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.71,
            child: ListView(
              children: days.map((day) => createDayRow(day)).toList(),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
