import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationProvider extends ChangeNotifier {
  Future<dynamic> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print(e.toString());
    }
    notifyListeners();
  }

  Future<dynamic> signUp(String email, String password) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    notifyListeners();
  }

  Future<dynamic> login(String email, String password) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    notifyListeners();
  }

  Future<dynamic> logout() async {
    await FirebaseAuth.instance.signOut();
    notifyListeners();
  }
}
