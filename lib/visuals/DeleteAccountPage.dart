import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Services/Authentication.dart';
import 'package:deeformity/Services/database.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeleteAccountPage extends StatefulWidget {
  final DocumentSnapshot recipientDoc;
  DeleteAccountPage(this.recipientDoc);
  @override
  _DeleteAccountPageState createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final _formKey = GlobalKey<FormState>();
  String message = "";

  Future sendMessage() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text("Warning"),
              content: Text("Hey, " +
                  widget.recipientDoc["First Name"] +
                  "\nAre you sure you want permanently delete your account?"),
              actions: [
                CupertinoActionSheetAction(
                  child: Text(
                    "Yes",
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () async {
                    await DatabaseService(uid: widget.recipientDoc.id)
                        .messageDaniel(
                            message: message,
                            topic: "Account Delete",
                            recipientDoc: widget.recipientDoc);
                    await context.read<AuthenticationService>().deleteAccount();
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
                CupertinoActionSheetAction(
                  child: Text("No"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
    }
  }

  void cancelDelete() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        //centerTitle: false,
        backgroundColor: Colors.white,
        shadowColor: Colors.white24,
        iconTheme: IconThemeData(color: elementColorWhiteBackground),
        title: Text(
          "Feedback",
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
                      "I hate\nto watch them\nleave.. :(".toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: elementColorWhiteBackground,
                        fontSize: 30,
                      ),
                    ),
                  ),
                  TextFormField(
                    maxLines: null,
                    minLines: 12,
                    decoration: textInputDecorationWhite.copyWith(
                      hintText: "Write stuff to Daniel, 30 characters required",
                      hintStyle: TextStyle(fontSize: fontSizeInputHint),
                    ),
                    onSaved: (input) => message = input,
                    validator: (input) => input.isEmpty
                        ? "Message is empty"
                        : input.length < 30
                            ? "More info please"
                            : null,
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.all(5),
                          child: InkWell(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(right: 5),
                                  child: Icon(
                                    CupertinoIcons.arrow_left,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  "CANCEL",
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                )
                              ],
                            ),
                            onTap: cancelDelete,
                          ),
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
                                    CupertinoIcons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                                Text(
                                  "Delete Account",
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                )
                              ],
                            ),
                            onTap: sendMessage,
                          ),
                        )
                      ],
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
