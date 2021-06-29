import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Services/database.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:deeformity/Shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:deeformity/Shared/MessageTiles.dart';

class UserMessagesPage extends StatefulWidget {
  final DocumentSnapshot userDoc;
  UserMessagesPage(this.userDoc);
  @override
  _UserMessagesPageState createState() => _UserMessagesPageState();
}

class _UserMessagesPageState extends State<UserMessagesPage> {
  final _formKey = GlobalKey<FormState>();
  final textEditingController = TextEditingController();
  final scrollController = ScrollController();
  String message = "";
  List<DocumentSnapshot> messages = [];

  Future sendMessage() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      // String snackBarMessage =
      await DatabaseService(uid: UserSingleton.userSingleton.userID)
          .sendMessage(
        receiverDoc: widget.userDoc,
        dateTimeNowMilli: DateTime.now().millisecondsSinceEpoch,
        message: message,
      );
      textEditingController.text = "";
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
      // if (snackBarMessage.isEmpty) {
      //   snackBarMessage = "Could not send message";
      // }
      // final snackBar = SnackBar(content: Text(snackBarMessage));
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: DatabaseService(uid: UserSingleton.userSingleton.userID)
          .particularUserMessagesStream(widget.userDoc.id),
      builder: (context, snapshot) {
        if (snapshot != null && snapshot.hasData) {
          messages = [];
          snapshot.data.docs.forEach((element) {
            List<String> messageUsers = List.from(element["Users"]);
            if (messageUsers.contains(widget.userDoc.id) &&
                messageUsers.contains(UserSingleton.userSingleton.userID)) {
              messages.add(element);
            }
          });
        }
        return GestureDetector(
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              //centerTitle: false,
              backgroundColor: Colors.white,
              shadowColor: Colors.white24,
              iconTheme: IconThemeData(color: elementColorWhiteBackground),
              title: Text(
                widget.userDoc["User Name"] ?? "Who this?",
                style: pageHeaderStyle,
              ),
            ),
            body: messages.isNotEmpty
                ? Container(
                    padding: EdgeInsets.all(10),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView(
                              controller: scrollController,
                              children: messages
                                  .map(
                                    (message) => MessageTile(
                                      messageDoc: message,
                                      otherUserName:
                                          widget.userDoc["User Name"],
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: textEditingController,
                                  maxLines: null,
                                  decoration: textInputDecorationWhite.copyWith(
                                    hintText: "Write stuff to " +
                                        widget.userDoc["User Name"],
                                    hintStyle:
                                        TextStyle(fontSize: fontSizeInputHint),
                                  ),
                                  onSaved: (input) => message = input,
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
                                ),
                                SizedBox(
                                  height: 50,
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: Loading(),
                  ),
          ),
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
        );
      },
    );
  }
}
