import 'package:deeformity/Services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  UserCredential _userCredential;
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
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      UserCredential userCred = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      errorMessage = "";
      // if (userCred != null) {
      //   _userCredential = userCred;
      //   user = _userCredential.user;
      // }
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> signUp(
      {String email,
      String password,
      String firstName,
      String lastName,
      String location}) async {
    try {
      UserCredential userCred = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      await createNewDataBaseDocument(userCred, firstName, lastName, location);
      errorMessage = "";
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.toString();
      return false;
    }
  }

  Future createNewDataBaseDocument(
      UserCredential userCredential, firstName, lastName, location) async {
    User user = userCredential.user;
    await DatabaseService(uid: user.uid).createUserData(
        firstName: firstName,
        lastName: lastName,
        professionalAccount: false,
        location: location);
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
