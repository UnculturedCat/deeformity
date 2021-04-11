import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Services/database.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:flutter/material.dart';

class CreateMessage extends StatefulWidget {
  final DocumentSnapshot recipientDoc;
  CreateMessage(this.recipientDoc);
  @override
  _CreateMessageState createState() => _CreateMessageState();
}

class _CreateMessageState extends State<CreateMessage> {
  final _formKey = GlobalKey<FormState>();
  String message = "";

  Future sendMessage() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      String snackBarMessage =
          await DatabaseService(uid: UserSingleton.userSingleton.userID)
              .sendMessage(
        receiverDoc: widget.recipientDoc,
        dateTimeNowMilli: DateTime.now().millisecondsSinceEpoch,
        message: message,
      );
      if (snackBarMessage.isEmpty) {
        snackBarMessage = "Could not send message";
      }
      final snackBar = SnackBar(content: Text(snackBarMessage));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
          "Send Message",
          style: pageHeaderStyle,
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                maxLines: null,
                minLines: 12,
                decoration: textInputDecorationWhite.copyWith(
                  hintText: "Write stuff to  " +
                          widget.recipientDoc.data()["First Name"] ??
                      "This guy",
                  hintStyle: TextStyle(fontSize: fontSizeInputHint),
                ),
                onSaved: (input) => message = input,
                validator: (input) => input.isEmpty ? "Message is empty" : null,
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
    );
  }
}
