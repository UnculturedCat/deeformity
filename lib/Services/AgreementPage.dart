import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:deeformity/Services/pdf_Api.dart';
import 'package:deeformity/Shared/constants.dart';

class AgreementPage extends StatefulWidget {
  @override
  _AgreementPageState createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  File file;
  PDFViewController controller;
  int pages = 0;
  int indexPage = 0;

  void initializeFile() async {
    file = await PDFApi.loadAssetPDF('assets/Beta_Agreement.pdf');
    setState(() {});
  }

  void handleRead() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (file == null) {
      initializeFile();
    }
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: elementColorWhiteBackground),
        backgroundColor: Colors.white,
        title: Text(
          "Agreement",
          style: TextStyle(color: elementColorWhiteBackground, fontSize: 30),
        ),
      ),
      // body: Container(
      //   padding: EdgeInsets.only(left: 10, right: 10),
      //   decoration: gradientDecoration,
      //   child: Column(children: [
      //     Column(
      //       children: [
      //         SizedBox(height: 40.0),
      //         Container(
      //           padding: EdgeInsets.only(left: 10),
      //           child: Text(
      //             "Agreement",
      //             style: TextStyle(color: Colors.white, fontSize: 30),
      //           ),
      //         ),
      //         Container(
      //           padding: EdgeInsets.only(
      //             left: 10,
      //             right: 10,
      //             top: 50,
      //           ),
      //           child: Row(
      //             mainAxisAlignment: MainAxisAlignment.end,
      //             children: <Widget>[
      //               ElevatedButton(
      //                 onPressed: handleRead,
      //                 child: Text(
      //                   "READ",
      //                   style: TextStyle(
      //                     fontSize: fontSizeButton,
      //                     color: Colors.white,
      //                   ),
      //                 ),
      //                 style: ElevatedButton.styleFrom(
      //                     primary: Color.fromRGBO(36, 36, 36, 100)),
      //               )
      //             ],
      //           ),
      //         ),
      //         SizedBox(
      //           height: 100,
      //         ),
      //         SizedBox(height: 20.0),
      //         Container(
      //           height: ,
      //           child: file == null
      //               ? SizedBox()
      //               :
      //         ),
      //       ],
      //     ),
      //   ]),
      // ),
      body: file != null
          ? PDFView(
              filePath: file.path,
              // onRender: (pages) => setState(() => this.pages = pages),
              // onViewCreated: (controller) =>
              //     setState(() => this.controller = controller),
              // onPageChanged: (indexPage, _) =>
              //     setState(() => this.indexPage = indexPage),
            )
          : SizedBox(),
    );
  }
}
