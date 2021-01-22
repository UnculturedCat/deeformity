import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
            Color.fromRGBO(47, 72, 100, 1),
            Color.fromRGBO(24, 41, 57, 1)
          ])),
      child: SpinKitCubeGrid(
        color: Colors.white,
        size: 50.0,
      ),
    );
  }
}
