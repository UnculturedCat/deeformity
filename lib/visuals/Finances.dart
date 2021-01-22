import 'package:flutter/material.dart';

class FinancePage extends StatefulWidget {
  final String pageName = "FinancePage";
  FinancePage();
  @override
  State<StatefulWidget> createState() {
    return FinancePageState();
  }
}

enum billType { trainer, doctor, therapist }

class FinancePageState extends State<FinancePage> {
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Finance",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: Color.fromRGBO(21, 33, 47, 15),
        actions: <Widget>[
          //IconButton(icon: Icon(Icons.settings), color: Colors.white,iconSize: 30, onPressed: handleGoToSettings),
        ],
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
    );
  }
}
