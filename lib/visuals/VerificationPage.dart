import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:deeformity/Services/Navigator.dart';

class VerificationPage extends StatefulWidget {
  final User user;
  VerificationPage(this.user);
  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  @override
  Widget build(BuildContext context) {
    return NavigatorClass();
  }
}
