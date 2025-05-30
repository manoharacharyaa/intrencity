import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intrencity/models/user_profile_model.dart';

class AuthenticationProvider extends ChangeNotifier {
  bool isGuest = false;

  void toggleGuest() {
    isGuest = true;
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
      isApproved: false,
      isVerificationPending: true,
    );
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(userProfile.toJson());
    notifyListeners();
  }

  Future<dynamic> login(String email, String password) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('User signed in: ${userCredential.user?.email}');
      return userCredential;
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow; // Rethrow to handle in UI
    }
  }

  Future<dynamic> logout() async {
    await FirebaseAuth.instance.signOut();
    isGuest = false; // Reset guest status
    notifyListeners();
  }
}
