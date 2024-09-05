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

  Future<void> updateCurrentUser() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      Map<String, dynamic> updateData = {
        'name': nameController.text,
        'email': emailController.text,
        'phoneNumber': phoneController.text,
        'profilePic': profilePicUrl,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update(updateData);
      setState(() {
        name = nameController.text;
        email = emailController.text;
        phone = phoneController.text;
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated sucessfully'),
        ),
      );
    } catch (e) {
      print("Error updating profile: $e");
    }
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
                        ? profilePicUrl != null
                            ? SizedBox(
                                height: size.height * 0.14,
                                width: size.width * 0.3,
                                child: CircleAvatar(
                                  backgroundColor: textFieldGrey,
                                  backgroundImage: NetworkImage(profilePicUrl!),
                                  radius: 50,
                                ),
                              )
                            : SizedBox(
                                height: size.height * 0.14,
                                width: size.width * 0.3,
                                child: const CircleAvatar(
                                  backgroundColor: textFieldGrey,
                                  child: Icon(
                                    Icons.add_photo_alternate,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                ),
                              )
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
                    fontSize: 16,
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
                              icon: Icons.person_rounded,
                              isEditing: isEditing,
                            ),
                            const Divider(thickness: 0.1),
                            UserDetailsCardItem(
                              controller: emailController,
                              icon: Icons.email,
                              isEditing: isEditing,
                            ),
                            const Divider(thickness: 0.1),
                            UserDetailsCardItem(
                              controller: phoneController,
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
                    setState(() {
                      if (isEditing) {
                        updateCurrentUser().then((_) {
                          setState(() {
                            isEditing = false;
                          });
                        });
                      } else {
                        isEditing = true;
                      }
                    });
                  },
                  child: Text(
                    isEditing ? 'Save Profile' : 'Edit Profile',
                    style: GoogleFonts.poppins(
                      color: Colors.blueAccent,
                      fontSize: 12,
                    ),
                  ),
                ),
              )
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
  });

  final IconData icon;
  final bool isEditing;
  final TextEditingController controller;
  final void Function()? edit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Icon(icon),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: isEditing ? true : false,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
              maxLines: 1,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
