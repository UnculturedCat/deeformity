import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const double fontSize = 20;
const double fontSizeInputHint = 12;
const double fontSizeButton = 15;
const TextStyle cardHeaderStyle = TextStyle(color: Colors.white, fontSize: 30);
const textInputDecoration = InputDecoration(
    filled: true,
    focusedBorder:
        OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
    hintStyle: TextStyle(fontSize: 15, color: Colors.white10),
    fillColor: Colors.white12,
    border: OutlineInputBorder(borderSide: BorderSide.none),
    floatingLabelBehavior: FloatingLabelBehavior.always);

const textInputDecorationWhite = InputDecoration(
    filled: true,
    focusedBorder:
        OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
    fillColor: Color.fromRGBO(234, 234, 234, 1),
    border: OutlineInputBorder(borderSide: BorderSide.none),
    hintStyle: TextStyle()
    //floatingLabelBehavior: FloatingLabelBehavior.never
    );

const gradientDecoration = BoxDecoration(
    gradient: RadialGradient(
        //begin: Alignment.topCenter,
        //end: Alignment.bottomCenter,
        radius: 1,
        colors: [
      Color.fromRGBO(47, 72, 100, 1),
      Color.fromRGBO(24, 41, 57, 1)
    ]));

final List<DropdownMenuItem<String>> dropDownLocations = <String>[
  "Enschede",
  "Utrecht",
  "Eindhoven",
  "Amsterdam"
]
    .map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        ))
    .toList();

// final List<DropdownMenuItem<String>> dropDownLocations = <String>[
//   "Enschede",
//   "Utrecht"
// ].map<DropdownMenuItem<String>>((String value) {
//   return DropdownMenuItem<String>(
//     value: value,
//     child: Text(value),
//   );
// }).toList();

const List<String> locations = [
  "Enschede",
  "Utrecht",
  "Eindhoven",
  "Amsterdam"
];

enum ProfileType { professional, client }

enum ActivityType { fitness, physio, personal }

enum ScheduleCategory {
  vidoeSession,
}
