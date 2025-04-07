import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intrencity/models/user_profile_model.dart';
import 'package:intrencity/widgets/dilogue_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider with ChangeNotifier {
  File? _imgFile;
  final ImagePicker picker = ImagePicker();
  UserProfileModel? user;
  String name = '';
  String email = '';
  String phone = '';
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  bool isEditing = false;
  bool expanded = false;
  String? profilePicUrl;
  String uid = FirebaseAuth.instance.currentUser!.uid;

  File? get imgFile => _imgFile;
  bool get isExpanded => expanded;

  ProfileProvider() {
    getTheme();
    currentUser();
  }

  void pickImage() async {
    XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _imgFile = File(image.path);
      notifyListeners();

      try {
        UploadTask uploadTask = FirebaseStorage.instance
            .ref()
            .child('profilePic/$uid')
            .putFile(_imgFile!);
        TaskSnapshot snapshot = await uploadTask;
        profilePicUrl = await snapshot.ref.getDownloadURL();
        notifyListeners();
      } catch (e) {
        print("Error uploading profile picture: $e");
      }
    }
  }

  Future<UserProfileModel?> getUserProfileInfo() async {
    try {
      final docSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        return UserProfileModel.fromJson(docSnapshot.data()!);
      }
      return null;
    } catch (e) {
      print("Error fetching user profile: $e");
      return null;
    }
  }

  void currentUser() async {
    UserProfileModel? currentUser = await getUserProfileInfo();
    if (currentUser != null) {
      name = currentUser.name;
      email = currentUser.email;
      phone = currentUser.phoneNumber;
      profilePicUrl = currentUser.profilePic;

      nameController.text = name;
      emailController.text = email;
      phoneController.text = phone;
      notifyListeners();
    }
  }

  Future<String> uploadProfilePic(String uid) async {
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('profile_pics/$uid.jpg');
      final uploadTask = await storageRef.putFile(_imgFile!);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading profile picture: $e");
      return '';
    }
  }

  Future<void> updateCurrentUser(BuildContext context) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (emailController.text != email) {
        await currentUser!.verifyBeforeUpdateEmail(emailController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Verification email sent to update email.')),
        );
      }

      Map<String, dynamic> updateData = {
        'name': nameController.text,
        'email': emailController.text,
        'phoneNumber': phoneController.text,
        if (_imgFile != null) 'profilePic': await uploadProfilePic(uid),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update(updateData)
          .then((_) => CustomDilogue.showSuccessDialog(
                context,
                'assets/animations/tick.json',
                'Successfully Updated!',
              ));

      name = nameController.text;
      email = emailController.text;
      phone = phoneController.text;
      isEditing = false;
      notifyListeners();
    } catch (e) {
      print("Error updating profile: $e");
      if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please log in again to update your email.')),
        );
      }
    }
  }

  void logOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut().then((_) {
      context.pushReplacement('/auth-page');
    });
  }

  Future<void> deleteSpaceByDocId(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('spaces').doc(docId).delete();
      notifyListeners();
    } catch (e) {
      print('Error deleting space: $e');
    }
  }

  void toggleEditing() {
    isEditing = !isEditing;
    notifyListeners();
  }

  void toggleExpanded() {
    expanded = !expanded;
    notifyListeners();
  }

  bool lightTheme = false;

  void setTheme(bool theme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('lightTheme', theme);
    lightTheme = theme;
    print(lightTheme);
    notifyListeners();
  }

  void getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    lightTheme = prefs.getBool('lightTheme') ?? false;
    print(lightTheme);
    notifyListeners();
  }
}
