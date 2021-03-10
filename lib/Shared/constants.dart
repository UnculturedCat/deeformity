import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../Screens/SearhPage.dart';

const double fontSize = 20;
const double fontSizeInputHint = 12;
const double fontSizeButton = 15;
const TextStyle cardHeaderStyle = TextStyle(color: Colors.white, fontSize: 30);
const headerActionButtonStyle = TextStyle(
    color: Color.fromRGBO(13, 255, 53, 1),
    fontSize: 17,
    fontWeight: FontWeight.w600);
const pageHeaderStyle =
    TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold);
const textInputDecoration = InputDecoration(
    contentPadding: EdgeInsets.all(15),
    filled: true,
    focusedBorder:
        OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
    hintStyle: TextStyle(fontSize: 15, color: Colors.white10),
    fillColor: Colors.white12,
    border: OutlineInputBorder(borderSide: BorderSide.none),
    floatingLabelBehavior: FloatingLabelBehavior.always);

const textInputDecorationWhite = InputDecoration(
    contentPadding: EdgeInsets.all(15),
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
  "Amsterdam",
  "Amersfoort",
  "Almere",
  "Apeldoorn",
  "Arnhem",
  "Breda",
  "Den Haag",
  "Enschede",
  "Eindhoven",
  "Groningen",
  "Haarlem",
  "Haarlemmermeer",
  "Leiden",
  "Nijmegen",
  "Rotterdam",
  "Tilburg",
  "Utrecht",
  "Zaanstad",
  "Zwolle",
  "'s-Hertogenbosch",
]
    .map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        ))
    .toList();

final List<DropdownMenuItem<RepeatFrequency>> dropDownFrequency =
    <RepeatFrequency>[
  RepeatFrequency.none,
  RepeatFrequency.daily,
  RepeatFrequency.weekly
].map((RepeatFrequency value) => createTextWidget(value)).toList();

// final List<DropdownMenuItem<String>> dropDownLocations = <String>[
//   "Enschede",
//   "Utrecht"
// ].map<DropdownMenuItem<String>>((String value) {
//   return DropdownMenuItem<String>(
//     value: value,
//     child: Text(value),
//   );
// }).toList();

DropdownMenuItem<RepeatFrequency> createTextWidget(RepeatFrequency value) {
  var receivedValue = value;
  var child;
  var textString;
  switch (receivedValue) {
    case RepeatFrequency.daily:
      {
        textString = "Every day";
        child = Text(textString);
        break;
      }
    case RepeatFrequency.weekly:
      {
        textString = "Weekly";
        child = Text(textString);
        break;
      }
    case RepeatFrequency.none:
      {
        textString = "One time";
        child = Text(textString);
        break;
      }
    default:
      {
        textString = "";
        child = Text(textString);
        break;
      }
  }
  return DropdownMenuItem<RepeatFrequency>(value: receivedValue, child: child);
}

enum MediaType {
  photo,
  video,
  textDocument,
}

enum MediaAssetSource {
  file,
  network,
  asset,
}

const List<String> locations = [
  "Enschede",
  "Utrecht",
  "Eindhoven",
  "Amsterdam"
];

const List<String> eventFrequency = ["One time", "Daily", "Weekly"];

enum ProfileType {
  professional,
  client,
}

enum ActivityType {
  fitness,
  physio,
  personal,
}

enum ScheduleCategory {
  vidoeSession,
}

enum RepeatFrequency {
  none,
  daily,
  weekly,
}
