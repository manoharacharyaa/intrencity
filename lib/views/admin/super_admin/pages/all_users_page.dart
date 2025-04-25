import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intrencity/models/user_profile_model.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/utils/smooth_corners/clip_smooth_rect.dart';
import 'package:intrencity/utils/smooth_corners/smooth_border_radius.dart';
import 'package:intrencity/utils/smooth_corners/smooth_radius.dart';
import 'package:intrencity/utils/smooth_corners/smooth_rectangle_border.dart';
import 'package:intrencity/viewmodels/users_viewmodel.dart';
import 'package:intrencity/widgets/custom_text_form_field.dart';
import 'package:intrencity/widgets/smooth_container.dart';
import 'package:provider/provider.dart';

class AllUsersPage extends StatefulWidget {
  const AllUsersPage({super.key});

  @override
  State<AllUsersPage> createState() => _AllUsersPageState();
}

class _AllUsersPageState extends State<AllUsersPage> {
  final TextEditingController _userController = TextEditingController();
  List<UserProfileModel> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    final allUsers = context.read<UsersViewmodel>().users;
    filteredUsers = List.from(allUsers);
  }

  void searchUsers(String query) {
    final allUsers = context.read<UsersViewmodel>().users;
    setState(() {
      if (query.isEmpty) {
        filteredUsers = List.from(allUsers);
      } else {
        filteredUsers = allUsers.where((user) {
          final nameLower = user.name.toLowerCase();
          final emailLower = user.email.toLowerCase();
          final phoneLower = user.phoneNumber.toLowerCase();
          final searchLower = query.toLowerCase();

          return nameLower.contains(searchLower) ||
              emailLower.contains(searchLower) ||
              phoneLower.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _userController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: Column(
        children: [
          CustomTextFormField(
            controller: _userController,
            horizontalPadding: 10,
            prefixIcon: Icons.search,
            hintText: 'Search by name, email or phone',
            onChanged: searchUsers,
          ),
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(
                    child: Text('No users found'),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return GestureDetector(
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                insetPadding: EdgeInsets.zero,
                                backgroundColor: textFieldGrey,
                                shape: const SmoothRectangleBorder(
                                  borderRadius: SmoothBorderRadius.all(
                                    SmoothRadius(
                                      cornerRadius: 20,
                                      cornerSmoothing: 0.8,
                                    ),
                                  ),
                                ),
                                content: SizedBox(
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.18,
                                  width: MediaQuery.sizeOf(context).width * 0.8,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Name: ${user.name}'),
                                        Text('Phone: ${user.phoneNumber}'),
                                        Text('Email: ${user.email}'),
                                        Text('User ID: ${user.uid}'),
                                        Text('Is Approved: ${user.isApproved}'),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: SmoothContainer(
                          height: 100,
                          width: double.infinity,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: ClipSmoothRect(
                                  radius: SmoothBorderRadius(
                                    cornerRadius: 18,
                                    cornerSmoothing: 0.8,
                                  ),
                                  child: Image.network(
                                    height: 75,
                                    width: 75,
                                    fit: BoxFit.cover,
                                    user.profilePic ?? '',
                                    errorBuilder: (context, error, stackTrace) {
                                      return const SmoothContainer(
                                        height: 75,
                                        width: 75,
                                        color: textFieldGrey,
                                        child: Icon(Icons.person),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  user.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        shape: SmoothRectangleBorder(
                                          borderRadius: SmoothBorderRadius(
                                            cornerRadius: 20,
                                            cornerSmoothing: 0.8,
                                          ),
                                        ),
                                        child: SizedBox(
                                          height: 150,
                                          child: Column(
                                            spacing: 15,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text('Are you sure'),
                                              ElevatedButton(
                                                style: const ButtonStyle(
                                                  backgroundColor:
                                                      WidgetStatePropertyAll(
                                                    redAccent,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  FirebaseFirestore.instance
                                                      .collection('users')
                                                      .doc(user.uid)
                                                      .delete();
                                                },
                                                child: Text(
                                                  'Delete',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(
                                  Icons.delete_rounded,
                                  color: redAccent,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.uid)
                                      .delete();
                                },
                                icon: const Icon(
                                  Icons.person_off,
                                  color: redAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
