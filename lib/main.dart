import 'package:deeformity/Services/Authentication.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'Screens/Profile.dart';
import 'package:firebase_core/firebase_core.dart';
import 'AuthenticationWrapper.dart';

Future<void> main() async {
  //add bootloader (Program starter)
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Deeformity());
}

class Deeformity extends StatelessWidget {
  static ProfilePage profilePage;
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(),
        ),
        StreamProvider.value(
          initialData: null,
          // create: (context) =>
          //     context.read<AuthenticationService>().authStateChanged
          value: AuthenticationService().authStateChanged,
        )
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          // theme: ThemeData(
          //   // iconTheme: IconThemeData(
          //   //   color: Colors.black,
          //   // ),
          //   brightness: Brightness.light,
          // ),
          home: AuthenticationWrapper()),
    );
  }
}

// class AuthenticationWrapper extends StatelessWidget {
//   const AuthenticationWrapper({
//     Key key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     //final firebaseUser = context.watch<User>();
//     final firebaseUser = Provider.of<User>(context);
//     if (firebaseUser != null) {
//       //initialize utility class here utility.initialize
//       return NavigatorClass();
//     }
//     //clear utility class here utility.clear();
//     return WelcomePage();
//   }
// }
