import 'package:deeformity/Services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:deeformity/Shared/infoSingleton.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  //User user;

  String errorMessage = "";
  AuthenticationService();

  //it is the same as the commented code below
  // Stream<User> get authStateChanged {
  //   return _firebaseAuth.authStateChanges();
  // }
  Stream<User> get authStateChanged => _firebaseAuth.authStateChanges();

  Future<bool> signOut() async {
    try {
      await _firebaseAuth.signOut();
      UserSingleton.analytics.logEvent(name: "Signed_out");
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message.trim();
      return false;
    }
  }

  Future deleteAccount() async {
    try {
      await DatabaseService(uid: _firebaseAuth.currentUser.uid).deleteUser();
      UserSingleton.analytics.logEvent(name: "Account_deleted");
      await _firebaseAuth.signOut();
      //Uncomment for account delete automation
      //await _firebaseAuth.currentUser.delete();
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message.trim();
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      errorMessage = "";
      // if (userCred != null) {
      //   _userCredential = userCred;
      //   user = _userCredential.user;
      // }
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message.trim();
      return false;
    }
  }

  Future<bool> signUp({
    String email,
    String password,
    String firstName,
    String lastName,
    String userName,
  }) async {
    try {
      UserCredential userCred = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      if (userCred != null) {
        await userCred.user.sendEmailVerification().catchError((error) {
          errorMessage = "Could not send verification link to " + email;
        }).then((value) {
          errorMessage = "Verification link sent to " + email;
        });
      }
      UserSingleton.analytics.logEvent(name: "SignUp_Completed");
      //create and auth user without creating a db for the user.
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message.trim();
      return false;
    }
  }

  Future<bool> createNewDataBaseDocument({
    User user,
    firstName,
    lastName,
    userName,
  }) async {
    try {
      await DatabaseService(uid: user.uid).createUserData(
          firstName: firstName, lastName: lastName, userName: userName);
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message.trim();
      return false;
    }
  }

  String giveErrorMessage() {
    if (errorMessage.isNotEmpty) {
      return errorMessage;
    }
    return "";
  }

  User getUser() {
    User user = _firebaseAuth.currentUser;
    return user;
  }
}
