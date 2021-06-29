import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:deeformity/Shared/infoSingleton.dart';
import 'package:flutter/material.dart';

class MessageTile extends StatelessWidget {
  final DocumentSnapshot messageDoc;
  final String otherUserName;
  MessageTile({@required this.messageDoc, @required this.otherUserName});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          messageDoc["Sender"] == UserSingleton.userSingleton.userID
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * .6,
          child: Card(
            color: messageDoc["Sender"] == UserSingleton.userSingleton.userID
                ? themeColor
                : null,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: ListTile(
              title: Container(
                padding: EdgeInsets.all(2),
                child: Text(
                  messageDoc["Message"] ?? "No description",
                  style: TextStyle(
                    color: messageDoc["Sender"] ==
                            UserSingleton.userSingleton.userID
                        ? Colors.white
                        : Color.fromRGBO(21, 33, 47, 1),
                    fontSize: fontSizeBody,
                  ),
                ),
              ),
              trailing: Container(
                padding: EdgeInsets.only(bottom: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    messageDoc["Sender"] == UserSingleton.userSingleton.userID
                        ? Text(
                            "You",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                              fontSize: 12,
                            ),
                          )
                        : Text(
                            otherUserName,
                            style: TextStyle(
                              color: Color.fromRGBO(21, 33, 47, 1),
                              fontWeight: FontWeight.w300,
                              fontSize: 12,
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
