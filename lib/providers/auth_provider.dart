import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intrencity_provider/model/user_profile_model.dart';

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

  Future<dynamic> signUp(
      String email, String password, String name, String phoneNumber) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    UserCredential userCredentials = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    String uid = userCredentials.user!.uid;
    UserProfileModel userProfile = UserProfileModel(
      uid: uid,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
    );
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(userProfile.toJson());
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
