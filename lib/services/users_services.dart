import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:intrencity/models/user_profile_model.dart';

class GetAllUsersServices {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<List<UserProfileModel>> getAllUsers() async {
    QuerySnapshot snapshot = await _firestore.collection('users').get();

    try {
      if (snapshot.docs.isNotEmpty) {
        List<dynamic> docs = snapshot.docs;
        final users =
            docs.map((doc) => UserProfileModel.fromJson(doc.data())).toList();
        return users;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('getAllUsers() $e');
      return [];
    }
  }

  static Stream<UserProfileModel?> getCurrentUserStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserProfileModel.fromJson(doc.data()!);
      }
      return null;
    });
  }

  static String? get currentUserId => _auth.currentUser?.uid;
}
