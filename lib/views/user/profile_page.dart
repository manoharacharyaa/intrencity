import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intrencity/providers/profile_provider.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/utils/smooth_corners/clip_smooth_rect.dart';
import 'package:intrencity/utils/smooth_corners/smooth_border_radius.dart';
import 'package:intrencity/widgets/cutsom_divider.dart';
import 'package:intrencity/widgets/smooth_container.dart';
import 'package:provider/provider.dart';

enum Value { edit, delete }

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
                        SmoothContainer(
                          contentPadding:
                              const EdgeInsets.fromLTRB(15, 0, 8, 0),
                          cornerRadius: 14,
                          color: textFieldGrey,
                          height: 53,
                          width: double.infinity,
                          child: Row(
                            children: [
                              Text(
                                provider.lightTheme ? 'Light' : 'Dark',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const Spacer(),
                              CupertinoSwitch(
                                value: provider.lightTheme,
                                onChanged: (value) {
                                  provider.setTheme(value);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        SmoothContainer(
                          height: 55,
                          cornerRadius: 14,
                          color: textFieldGrey,
                          onTap: () => context.push('/booking-history'),
                          contentPadding:
                              const EdgeInsets.fromLTRB(12, 8, 12, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Booking History',
                                style: GoogleFonts.poppins(fontSize: 18),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 24,
                                color: primaryBlue,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
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
