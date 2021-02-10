import 'package:deeformity/Shared/constants.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deeformity/Services/database.dart';
import 'package:flutter/services.dart';

class AddExercisePage extends StatefulWidget {
  final ActivityType _activityType;
  AddExercisePage(this._activityType);
  @override
  _AddExercisePageState createState() => _AddExercisePageState(_activityType);
}

class _AddExercisePageState extends State<AddExercisePage> {
  final _formKey = GlobalKey<FormState>();
  String cardId;
  String userId = UserSingleton.userSingleton.currentUSer.uid;
  final ActivityType _activityType;
  String category;
  String workOutName;
  int sets;
  int reps;
  String description;
  String date = UserSingleton.userSingleton.selectedStringDate;
  int frequency = RepeatFrequency.none.index;
  DateTime dateTime = UserSingleton.userSingleton.dateTime;

  _AddExercisePageState(this._activityType) {
    if (_activityType == ActivityType.fitness) {
      category = "Fitness";
    } else if (_activityType == ActivityType.physio) {
      category = "Physio";
    } else if (_activityType == ActivityType.personal) {
      category = "Personal";
    }
  }
  void addExercise() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      String cardDocId = await DatabaseService(
              uid: UserSingleton.userSingleton.currentUSer.uid)
          .createSchedule(
              cardId: cardId,
              category: category,
              userId: userId,
              workOutName: workOutName,
              sets: sets,
              reps: reps,
              description: description,
              date: date,
              dateTime: dateTime.toString(),
              frequency: frequency);
      cardDocId.isNotEmpty
          ? updateRoutineInfo(cardDocId)
          : print("Add Exercise Page: CardDocId not received");
    }
  }

  void updateRoutineInfo(String cardDocId) async {
    await DatabaseService(uid: UserSingleton.userSingleton.currentUSer.uid)
        .updateRoutineInfo(cardDocId);
    Navigator.pop(context);
  }

  void attachMedia() {
    //open attach media page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          "Add Exercise",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: Color.fromRGBO(21, 33, 47, 15),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.only(top: 20, left: 10, right: 10),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Container(
                    padding: EdgeInsets.only(left: 10, bottom: 30),
                    child: Text(
                      category,
                      style: TextStyle(fontSize: 30),
                    )),
                Container(
                  child: TextFormField(
                    decoration: textInputDecorationWhite.copyWith(
                      hintStyle: TextStyle(fontSize: fontSizeInputHint),
                      hintText: "Workout Name",
                    ),
                    onSaved: (input) => workOutName = input,
                    validator: (input) =>
                        input.isEmpty ? "Enter exercise name" : null,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 30),
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                          ],
                          decoration: textInputDecorationWhite.copyWith(
                              hintStyle: TextStyle(fontSize: fontSizeInputHint),
                              hintText: "reps"),
                          onSaved: (input) => reps = int.parse(input),
                          validator: (input) =>
                              input.isEmpty ? "Enter number of reps" : null,
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Container(
                        width: 70,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                          ],
                          decoration: textInputDecorationWhite.copyWith(
                              hintStyle: TextStyle(fontSize: fontSizeInputHint),
                              hintText: "Sets"),
                          onSaved: (input) => sets = int.parse(input),
                          validator: (input) =>
                              input.isEmpty ? "Enter number of sets" : null,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  height: 300,
                  padding: EdgeInsets.only(top: 30),
                  child: TextFormField(
                    maxLines: null,
                    //keyboardType: TextInputType.multiline,
                    decoration: textInputDecorationWhite.copyWith(
                        //contentPadding: EdgeInsets.only(right: 10, left: 10),
                        hintText: "Description",
                        hintStyle: TextStyle(fontSize: fontSizeInputHint)),
                    onSaved: (input) => description = input,
                    //validator: (input) => input.isEmpty? "Enter",
                  ),
                ),
                Row(children: [
                  //IconButton(icon: Icon(CupertinoIcons.photo), onPressed: () {}),
                  DropdownButton(
                      value: RepeatFrequency.values[frequency],
                      dropdownColor: Colors.white,
                      items: dropDownFrequency,
                      onChanged: (value) {
                        setState(() {
                          frequency = RepeatFrequency.values.indexOf(value);
                        });
                      }),
                  Text("Event"),
                ]),
                Row(children: [
                  //IconButton(icon: Icon(CupertinoIcons.photo), onPressed: () {}),
                  IconButton(
                      icon: Icon(Icons.image),
                      iconSize: 50,
                      onPressed: attachMedia),
                  Text("Add media"),
                ]),
                SizedBox(
                  height: 50,
                ),
                RaisedButton(
                    child: Text(
                      "Create Exercise",
                      style: TextStyle(
                          fontSize: fontSizeButton,
                          fontWeight: FontWeight.normal,
                          color: Colors.white),
                    ),
                    color: Color.fromRGBO(27, 98, 40, 1),
                    onPressed: addExercise)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
