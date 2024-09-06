import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intrencity_provider/constants/colors.dart';
import 'package:intrencity_provider/model/user_profile_model.dart';
import 'package:intrencity_provider/pages/auth/auth_page.dart';
import 'package:intrencity_provider/pages/user/parking_space_details_page.dart';
import 'package:intrencity_provider/widgets/dilogue_widget.dart';
import 'package:intrencity_provider/widgets/profilepic_avatar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
  String? profilePicUrl;
  String uid = FirebaseAuth.instance.currentUser!.uid;

  void pickImage() async {
    XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (image == null) {
      return;
    } else {
      setState(() {
        _imgFile = File(image.path);
      });
    }

    if (_imgFile != null) {
      try {
        String uid = FirebaseAuth.instance.currentUser!.uid;
        UploadTask uploadTask = FirebaseStorage.instance
            .ref()
            .child('profilePic/$uid')
            .putFile(_imgFile!);

        TaskSnapshot snapshot = await uploadTask;
        profilePicUrl = await snapshot.ref.getDownloadURL();
      } catch (e) {
        print("Error uploading profile picture: $e");
      }
    }
  }

  Future<UserProfileModel?> getUserProfileInfo() async {
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

  void currentUser() async {
    UserProfileModel? currentUser = await getUserProfileInfo();
    if (currentUser != null) {
      setState(() {
        name = currentUser.name;
        email = currentUser.email;
        phone = currentUser.phoneNumber;
        profilePicUrl = currentUser.profilePic;

        nameController.text = name;
        emailController.text = email;
        phoneController.text = phone;
      });
    }
  }

  Future<String> uploadProfilePic(String uid) async {
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('profile_pics/$uid.jpg');
      final uploadTask = await storageRef.putFile(_imgFile!);
      String downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading profile picture: $e");
      return '';
    }
  }

  Future<void> updateCurrentUser() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      User? currentUser = FirebaseAuth.instance.currentUser;

      if (emailController.text != email) {
        await currentUser!.verifyBeforeUpdateEmail(emailController.text);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent to update email.'),
          ),
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

      setState(() {
        name = nameController.text;
        email = emailController.text;
        phone = phoneController.text;
        isEditing = false;
      });

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('Profile updated successfully'),
      //   ),
      // );
    } catch (e) {
      print("Error updating profile: $e");

      if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in again to update your email.'),
          ),
        );
      }
    }
  }

  void logOut() async {
    await FirebaseAuth.instance.signOut().then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthPage(),
        ),
      );
    });
  }

  @override
  void initState() {
    currentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
        actions: [
          TextButton(
            onPressed: logOut,
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(
                color: redAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: GestureDetector(
                    onTap: isEditing == true
                        ? () {
                            pickImage();
                          }
                        : null,
                    child: _imgFile == null
                        ? (profilePicUrl != null
                            ? ProfilePicAvatar(
                                height: size.height * 0.14,
                                width: size.width * 0.3,
                                profilePic: profilePicUrl!,
                              )
                            : const SizedBox())
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(200),
                            child: SizedBox(
                              height: size.height * 0.14,
                              width: size.width * 0.3,
                              child: Image.file(
                                _imgFile!,
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'User Details',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                  ),
                ),
              ),
              ClipSmoothRect(
                radius: SmoothBorderRadius(
                  cornerRadius: 16,
                  cornerSmoothing: 1,
                ),
                child: Container(
                  color: Colors.grey[900],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            UserDetailsCardItem(
                              controller: nameController,
                              keyboardType: TextInputType.text,
                              icon: Icons.person_rounded,
                              isEditing: isEditing,
                            ),
                            const CustomDivider(),
                            UserDetailsCardItem(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              icon: Icons.email,
                              isEditing: isEditing,
                            ),
                            const CustomDivider(),
                            UserDetailsCardItem(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              icon: Icons.phone,
                              isEditing: isEditing,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: TextButton(
                  onPressed: () {
                    if (isEditing) {
                      updateCurrentUser().then((_) {
                        setState(() {
                          isEditing = false;
                        });
                      });
                    } else {
                      setState(() {
                        isEditing = true;
                      });
                    }
                  },
                  child: Text(
                    isEditing ? 'Save Profile' : 'Edit Profile',
                    style: GoogleFonts.poppins(
                      color: Colors.blueAccent,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserDetailsCardItem extends StatelessWidget {
  const UserDetailsCardItem({
    super.key,
    this.edit,
    this.isEditing = false,
    required this.icon,
    required this.controller,
    this.keyboardType,
  });

  final IconData icon;
  final bool isEditing;
  final TextEditingController controller;
  final void Function()? edit;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Icon(icon),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            enabled: isEditing ? true : false,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
            maxLines: 1,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
