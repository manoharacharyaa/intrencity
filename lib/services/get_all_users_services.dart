import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intrencity/models/user_profile_model.dart';

class GetAllUsersServices {
  static Future<List<UserProfileModel>> getAllUsers() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();

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
      debugPrint('_getAllUsers() $e');
      return [];
    }
  }
}
