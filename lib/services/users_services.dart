import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:intrencity/models/parking_space_post_model.dart';
import 'package:intrencity/models/user_profile_model.dart';

class UsersServices {
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

  static Future<List<ParkingSpacePostModel>> fetchCurrentUserSpaces() async {
    final curentuid = _auth.currentUser?.uid;
    QuerySnapshot snapshot = await _firestore
        .collection('spaces')
        .where('uid', isEqualTo: curentuid)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs
          .map((doc) => ParkingSpacePostModel.fromJson(
              doc.data() as Map<String, dynamic>))
          .toList();
    } else {
      return [];
    }
  }

  static String? get currentUserId => _auth.currentUser?.uid;
}
