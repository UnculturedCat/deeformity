import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Services/database.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:flutter/material.dart';

class MessageDaniel extends StatefulWidget {
  final DocumentSnapshot recipientDoc;
  MessageDaniel(this.recipientDoc);
  @override
  _MessageDanielState createState() => _MessageDanielState();
}

class _MessageDanielState extends State<MessageDaniel> {
  final _formKey = GlobalKey<FormState>();
  String message = "";

  Future sendMessage() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      await DatabaseService(uid: UserSingleton.userSingleton.userID)
          .messageDaniel(
        recipientDoc: widget.recipientDoc,
        message: message,
      );
      bool pop = true;
      final snackBar = SnackBar(content: Text("Daniel got the message"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      if (pop) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //centerTitle: false,
        backgroundColor: Colors.white,
        shadowColor: Colors.white24,
        iconTheme: IconThemeData(color: elementColorWhiteBackground),
        title: Text(
          "Developer Table",
          style: pageHeaderStyle,
        ),
      ),
      backgroundColor: Colors.white,
      body: GestureDetector(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(5).copyWith(top: 10, bottom: 20),
                    child: Text(
                      "Hi,\nHow can I help you? :)".toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: elementColorWhiteBackground,
                        fontSize: 30,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5).copyWith(top: 10, bottom: 20),
                    child: Text(
                      "Tell me anything. Feedback is really appreciated.",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: elementColorWhiteBackground,
                        // /fontSize: 15,
                      ),
                    ),
                  ),
                  TextFormField(
                    maxLines: null,
                    minLines: 12,
                    decoration: textInputDecorationWhite.copyWith(
                      hintText: "Write stuff to Daniel",
                      hintStyle: TextStyle(fontSize: fontSizeInputHint),
                    ),
                    onSaved: (input) => message = input,
                    validator: (input) =>
                        input.isEmpty ? "Message is empty" : null,
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    child: InkWell(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.only(right: 5),
                            child: Icon(
                              Icons.send,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            "Send",
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          )
                        ],
                      ),
                      onTap: sendMessage,
                    ),
                  )
                ],
              ),
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
}
