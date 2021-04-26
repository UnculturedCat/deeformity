import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deeformity/Services/Authentication.dart';
import 'package:deeformity/Shared/constants.dart';
import 'package:deeformity/Shared/loading.dart';

class SignIn extends StatefulWidget {
  final Function showsigninPage;
  SignIn({this.showsigninPage});
  @override
  State<StatefulWidget> createState() {
    return SignInState();
  }
}

class SignInState extends State<SignIn> {
  final _formkey = GlobalKey<FormState>();
  String _email, _password;
  bool loading = false;

  void handleLogin() async {
    setState(() => loading = true);
    String errorMessage;
    dynamic success = await context
        .read<AuthenticationService>()
        .signIn(_email.trim(), _password.trim());
    if (!success) {
      setState(() => loading = false);
      errorMessage = context.read<AuthenticationService>().errorMessage;
      if (errorMessage.isNotEmpty) showErrorMessage(errorMessage.trim());
    }
  }

  void showErrorMessage(String errorMessage) {
    SnackBar snackBar = SnackBar(
      content: Text(errorMessage),
      duration: Duration(seconds: 60),
      action: SnackBarAction(
        label: "DISMISS",
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void validateInput() {
    final formState = _formkey.currentState;
    if (formState.validate()) {
      formState.save();
      handleLogin();
    }
  }

  void handleSignUp() {
    // Navigator.push(context, MaterialPageRoute(builder: (context) {
    //   return SignUpPage();
    // }));
    widget.showsigninPage(false);
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            //backgroundColor: Color.fromRGBO(21, 33, 47,100),
            //body: SafeArea(
            body: Container(
            decoration: gradientDecoration,
            child: ListView(
              children: <Widget>[
                //SizedBox(height: 80.0),
                Container(
                    padding: EdgeInsets.only(top: 200),
                    child: Column(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("REPLEE",
                            style: TextStyle(
                                decorationThickness: 3,
                                //decorationColor: elementColorWhiteBackground,
                                decoration: TextDecoration.combine([
                                  //TextDecoration.lineThrough,
                                  TextDecoration.overline,
                                  //TextDecoration.underline
                                ]),
                                color: Colors.white,
                                fontSize: 40.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: "ZenDots")),
                        //Form
                        Form(
                            key: _formkey,
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(
                                      left: 40, right: 40, top: 40),
                                  child: TextFormField(
                                    decoration: textInputDecoration.copyWith(
                                        hintText: "Email"),
                                    style: TextStyle(color: Colors.white),
                                    onSaved: (input) => _email = input,
                                    validator: (input) =>
                                        input.isEmpty ? "Enter Email" : null,
                                  ),
                                ),

                                //password container
                                Container //Padding class can also be used
                                    (
                                  padding: EdgeInsets.only(
                                      left: 40, right: 40, top: 20),
                                  child: TextFormField(
                                    decoration: textInputDecoration.copyWith(
                                        hintText: "Password"),
                                    style: TextStyle(color: Colors.white),
                                    obscureText: true,
                                    onSaved: (input) => _password = input,
                                    validator: (input) =>
                                        input.isEmpty ? "Enter Password" : null,
                                  ),
                                ),
                              ],
                            )),
                        //Button Container
                        Container(
                          padding:
                              EdgeInsets.only(left: 10, right: 10, top: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                child: ElevatedButton(
                                  onPressed: validateInput,
                                  child: Text(
                                    "LOGIN",
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      primary: Color.fromRGBO(36, 36, 36, 100)),
                                ),
                              ),
                              SizedBox(width: 20),
                              Container(
                                child: Text(
                                  "or",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                              Container(
                                child: TextButton(
                                  onPressed: handleSignUp,
                                  child: Text(
                                    "Create an account",
                                    style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  // color: Color.fromRGBO(36, 36, 36, 100),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    )),
              ],
            ),
          )
            // )
            );
  }
}
