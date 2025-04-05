import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intrencity/models/user_profile_model.dart';

class UsersProvider extends ChangeNotifier {
  UsersProvider() {
    _getCurrentUser();
  }
  final String _uid = FirebaseAuth.instance.currentUser!.uid;
  UserProfileModel? _user;
  bool _approved = false;

  String get uid => _uid;
  UserProfileModel? get user => _user;
  bool get approved => _approved;

  void _setApproved(bool status) {
    _approved = status;
    notifyListeners();
  }

  Future<void> _getCurrentUser() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(_uid).get();

    if (snapshot.exists) {
      final userData = snapshot.data();
      _user = UserProfileModel.fromJson(userData!);
      notifyListeners();
      if (_user!.isApproved == true) {
        _setApproved(true);
      } else {
        _setApproved(false);
      }
    }
  }
}
