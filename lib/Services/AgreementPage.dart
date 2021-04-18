import 'package:deeformity/Shared/constants.dart';
import 'package:flutter/material.dart';

class AgreementPage extends StatefulWidget {
  @override
  _AgreementPageState createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  void handleRead() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        decoration: gradientDecoration,
        child: ListView(children: [
          Column(
            children: [
              SizedBox(height: 40.0),
              Container(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "Agreement",
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                child: Text(
                  userAgreement,
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 50,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: handleRead,
                      child: Text(
                        "READ",
                        style: TextStyle(
                          fontSize: fontSizeButton,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                          primary: Color.fromRGBO(36, 36, 36, 100)),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 100,
              )
            ],
          ),
        ]),
      ),
    );
  }
}
