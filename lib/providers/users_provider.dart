import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intrencity/models/user_profile_model.dart';

class UsersProvider extends ChangeNotifier {
  UserProfileModel? _user;
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  UserProfileModel? get user => _user;
  bool get approved => _user?.isApproved ?? false;

  void resetUser() {
    _user = null;
    _userSubscription?.cancel();
    notifyListeners();
  }

  void fetchUserData() {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      final uid = auth.currentUser!.uid;
      _userSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots()
          .listen((doc) {
        if (doc.exists) {
          _user = UserProfileModel.fromJson(doc.data()!);
          notifyListeners();
        }
      });
    }
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
