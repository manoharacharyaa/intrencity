import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intrencity/providers/profile_provider.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/models/parking_space_post_model.dart';
import 'package:intrencity/utils/smooth_corners/clip_smooth_rect.dart';
import 'package:intrencity/utils/smooth_corners/smooth_border_radius.dart';
import 'package:intrencity/utils/smooth_corners/smooth_radius.dart';
import 'package:intrencity/widgets/cutsom_divider.dart';
import 'package:intrencity/widgets/smooth_container.dart';
import 'package:provider/provider.dart';

enum Value { edit, delete }

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider(),
      child: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Profile Page'),
              actions: [
                TextButton(
                  onPressed: () => provider.logOut(context),
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
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: GestureDetector(
                          onTap: provider.isEditing ? provider.pickImage : null,
                          child: provider.imgFile == null
                              ? provider.profilePicUrl != null
                                  ? SizedBox(
                                      height: size.height * 0.14,
                                      width: size.width * 0.3,
                                      child: CircleAvatar(
                                        backgroundColor: textFieldGrey,
                                        backgroundImage: NetworkImage(
                                          provider.profilePicUrl!,
                                        ),
                                        radius: 50,
                                      ),
                                    )
                                  : SizedBox(
                                      height: size.height * 0.14,
                                      width: size.width * 0.3,
                                      child: const CircleAvatar(
                                        backgroundColor: textFieldGrey,
                                        child: Icon(
                                          CupertinoIcons.photo,
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
                                      provider.imgFile!,
                                      fit: BoxFit.cover,
                                      filterQuality: FilterQuality.high,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        provider.name,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ClipSmoothRect(
                      radius: SmoothBorderRadius(
                          cornerRadius: 16, cornerSmoothing: 0.8),
                      child: Container(
                        color: Colors.grey[900],
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              UserDetailsCardItem(
                                controller: provider.nameController,
                                keyboardType: TextInputType.text,
                                icon: Icons.person_rounded,
                                isEditing: provider.isEditing,
                              ),
                              const CustomDivider(),
                              UserDetailsCardItem(
                                controller: provider.emailController,
                                keyboardType: TextInputType.emailAddress,
                                icon: Icons.email,
                                isEditing: provider.isEditing,
                              ),
                              const CustomDivider(),
                              UserDetailsCardItem(
                                controller: provider.phoneController,
                                keyboardType: TextInputType.phone,
                                icon: Icons.phone,
                                isEditing: provider.isEditing,
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
                          if (provider.isEditing) {
                            provider.updateCurrentUser(context);
                          } else {
                            provider.toggleEditing();
                          }
                        },
                        child: Text(
                          provider.isEditing ? 'Save Profile' : 'Edit Profile',
                          style: GoogleFonts.poppins(
                              color: primaryBlue, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipSmoothRect(
                          radius: provider.isExpanded
                              ? const SmoothBorderRadius.only(
                                  topLeft: SmoothRadius(
                                      cornerRadius: 14, cornerSmoothing: 0.8),
                                  topRight: SmoothRadius(
                                      cornerRadius: 14, cornerSmoothing: 0.8),
                                )
                              : const SmoothBorderRadius.all(
                                  SmoothRadius(
                                    cornerRadius: 14,
                                    cornerSmoothing: 0.8,
                                  ),
                                ),
                          child: Container(
                            color: Colors.grey[900],
                            padding: const EdgeInsets.fromLTRB(12, 2, 0, 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'My Postings',
                                  style: GoogleFonts.poppins(fontSize: 18),
                                ),
                                IconButton(
                                  onPressed: provider.toggleExpanded,
                                  icon: Icon(
                                    size: 35,
                                    color: primaryBlue,
                                    provider.isExpanded
                                        ? Icons.arrow_drop_down_circle_outlined
                                        : Icons.arrow_circle_right_outlined,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        provider.isExpanded
                            ? MySpaceWidget(
                                size: size,
                                provider: provider,
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class MySpaceWidget extends StatelessWidget {
  const MySpaceWidget({
    super.key,
    required this.size,
    required this.provider,
  });

  final Size size;
  final ProfileProvider provider;

  @override
  Widget build(BuildContext context) {
    return ClipSmoothRect(
      radius: const SmoothBorderRadius.only(
        bottomLeft: SmoothRadius(cornerRadius: 14, cornerSmoothing: 0.8),
        bottomRight: SmoothRadius(cornerRadius: 14, cornerSmoothing: 0.8),
      ),
      child: Container(
        height: size.height * 0.35,
        width: double.infinity,
        color: Colors.grey[900],
        child: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('spaces')
              .where('uid', isEqualTo: provider.uid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CupertinoActivityIndicator(radius: 14),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No Spaces Found'),
              );
            }
            final spaces = snapshot.data!.docs
                .map(
                  (space) => ParkingSpacePostModel.fromJson(
                    space.data(),
                  ),
                )
                .toList();
            return ListView.builder(
              itemCount: spaces.length,
              itemBuilder: (context, index) {
                final space = spaces[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: InkWell(
                    onTap: () => context.push(
                      '/parking-space-details',
                      extra: {
                        'spaceDetails': space,
                        'viewedByCurrentUser': true,
                      },
                    ),
                    child: SmoothContainer(
                      color: Colors.grey[900],
                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                      cornerRadius: 20,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: SmoothContainer(
                                  height: size.height * 0.08,
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
                                onSelected: (Value item) {
                                  if (item == Value.edit) {
                                    context.push('/edit-post-page',
                                        extra: space);
                                  } else if (item == Value.delete) {
                                    provider.deleteSpaceByDocId(
                                      space.docId!,
                                    );
                                  }
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                color: textFieldGrey,
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: Value.edit,
                                    child: Center(child: Text('Edit')),
                                  ),
                                  const PopupMenuItem(
                                    value: Value.delete,
                                    child: Center(child: Text('Delete')),
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
    );
  }
}

class UserDetailsCardItem extends StatelessWidget {
  const UserDetailsCardItem({
    super.key,
    required this.icon,
    required this.isEditing,
    required this.controller,
    this.keyboardType,
  });

  final IconData icon;
  final bool isEditing;
  final TextEditingController controller;
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
            enabled: isEditing,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isEditing ? Colors.amber : Colors.white,
            ),
            maxLines: 1,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
      ],
    );
  }
}
