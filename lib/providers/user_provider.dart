import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intrencity_provider/model/user_profile_model.dart';

class UserProvider extends ChangeNotifier {
  UserProfileModel? currentUser;
  String currentUserName = '';
  String currentUserEmail = '';
  String currentUserPhone = '';
  String currentUserProfilePic = '';

  Future<UserProfileModel?> getCurrentUser() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      final docSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        return UserProfileModel.fromJson(docSnapshot.data()!);
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching user profile: $e");
      return null;
    }
  }

  void currentUserInfo() async {
    currentUser = await getCurrentUser();
    currentUserName = currentUser!.name;
    currentUserEmail = currentUser!.email;
    currentUserPhone = currentUser!.phoneNumber;
    currentUserProfilePic = currentUser!.profilePic!;
    notifyListeners();
  }
}
