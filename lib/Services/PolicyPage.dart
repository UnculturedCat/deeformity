import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:deeformity/Services/pdf_Api.dart';
import 'package:deeformity/Shared/constants.dart';

class PrivacyPolicyPage extends StatefulWidget {
  // final Language language;
  // PrivacyPolicyPage(this.language);
  @override
  _PrivacyPolicyPageState createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  File file;
  PDFViewController controller;
  int pages = 0;
  int indexPage = 0;

  void initializeFile() async {
    String filePath = "assets/Privacy_Policy_Combined.pdf";
    // switch (widget.language) {
    //   case Language.en:
    //     filePath = "assets/Privacy_Policy_EN.pdf";
    //     break;
    //   case Language.de:
    //     filePath = "assets/Privacy_Policy_DE.pdf";
    //     break;
    //   case Language.nl:
    //     filePath = "assets/Privacy_Policy_NL.pdf";
    //     break;
    // }
    file = await PDFApi.loadAssetPDF(filePath);
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
          "Privacy Policy",
          style: TextStyle(
            color: elementColorWhiteBackground,
          ),
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
