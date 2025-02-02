import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intrencity_provider/constants/colors.dart';
import 'package:intrencity_provider/model/parking_space_post_model.dart';
import 'package:intrencity_provider/model/user_profile_model.dart';
import 'package:intrencity_provider/views/auth/auth_page.dart';
import 'package:intrencity_provider/views/user/edit_post_page.dart';
import 'package:intrencity_provider/views/user/parking_space_details_page.dart';
import 'package:intrencity_provider/widgets/cutsom_divider.dart';
import 'package:intrencity_provider/widgets/dilogue_widget.dart';
import 'package:intrencity_provider/widgets/smooth_container.dart';

enum Value {
  edit,
  delete,
}

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
  bool expanded = false;
  String? profilePicUrl;
  String uid = FirebaseAuth.instance.currentUser!.uid;
  Value? selectedItem;

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

  Future<void> deleteSpaceByDocId(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('spaces').doc(docId).delete();
    } catch (e) {
      print('Error deleting space: $e');
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
                      color: primaryBlue,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipSmoothRect(
                    radius: expanded
                        ? const SmoothBorderRadius.only(
                            topLeft: SmoothRadius(
                                cornerRadius: 14, cornerSmoothing: 1),
                            topRight: SmoothRadius(
                                cornerRadius: 14, cornerSmoothing: 1))
                        : const SmoothBorderRadius.all(
                            SmoothRadius(cornerRadius: 14, cornerSmoothing: 1)),
                    child: Container(
                      color: Colors.grey[900],
                      padding: const EdgeInsets.fromLTRB(12, 2, 0, 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'My Postings',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                expanded = !expanded;
                              });
                            },
                            icon: Icon(
                              size: 35,
                              color: primaryBlue,
                              expanded
                                  ? Icons.arrow_drop_down_circle_outlined
                                  : Icons.arrow_circle_right_outlined,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  expanded
                      ? ClipSmoothRect(
                          radius: const SmoothBorderRadius.only(
                            bottomLeft: SmoothRadius(
                                cornerRadius: 14, cornerSmoothing: 1),
                            bottomRight: SmoothRadius(
                                cornerRadius: 14, cornerSmoothing: 1),
                          ),
                          child: Container(
                            height: size.height * 0.35,
                            width: double.infinity,
                            color: Colors.grey[900],
                            child: FutureBuilder(
                              future: FirebaseFirestore.instance
                                  .collection('spaces')
                                  .where('uid', isEqualTo: uid)
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CupertinoActivityIndicator(
                                    radius: 20,
                                  ));
                                }
                                if (!snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return const Center(
                                    child: Text('No Spaces Found'),
                                  );
                                }

                                final spaces = snapshot.data!.docs
                                    .map((space) =>
                                        ParkingSpacePostModel.fromJson(
                                            space.data()))
                                    .toList();

                                return ListView.builder(
                                  itemCount: spaces.length,
                                  itemBuilder: (context, index) {
                                    final ParkingSpacePostModel space =
                                        spaces[index];
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 0, 0, 10),
                                      child: InkWell(
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ParkingSpaceDetailsPage(
                                              spaceDetails: space,
                                              viewedByCurrentUser: true,
                                            ),
                                          ),
                                        ),
                                        child: SmoothContainer(
                                          color: Colors.grey[900],
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 0, 0, 0),
                                          cornerRadius: 20,
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      bottom: 5,
                                                    ),
                                                    child: SmoothContainer(
                                                      height:
                                                          size.height * 0.08,
                                                      width: size.width * 0.18,
                                                      color: primaryBlue,
                                                      cornerRadius: 14,
                                                      child: Image.network(
                                                        space.spaceThumbnail[0],
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 20),
                                                  Text(space.spaceName),
                                                  const Spacer(),
                                                  PopupMenuButton<Value>(
                                                    initialValue: selectedItem,
                                                    onSelected: (Value item) {
                                                      setState(() {
                                                        selectedItem = item;
                                                      });
                                                    },
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        10,
                                                      ),
                                                    ),
                                                    color: textFieldGrey,
                                                    itemBuilder: (context) => [
                                                      PopupMenuItem(
                                                        value: Value.edit,
                                                        child: const Center(
                                                          child: Text('Edit'),
                                                        ),
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  EditPostPage(
                                                                currentUserSpace:
                                                                    space,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      PopupMenuItem(
                                                        onTap: () {
                                                          setState(() {
                                                            deleteSpaceByDocId(
                                                              space.docId!,
                                                            );
                                                          });
                                                        },
                                                        value: Value.delete,
                                                        child: const Center(
                                                          child: Text('Delete'),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const CustomDivider(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        )
                      : const SizedBox(),
                ],
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
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isEditing ? Colors.amber : Colors.white,
            ),
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
