import 'package:flutter/material.dart';
import 'package:intrencity/utils/colors.dart';

class ProfilePicAvatar extends StatelessWidget {
  const ProfilePicAvatar({
    super.key,
    this.onTap,
    this.height,
    this.width,
    required this.profilePic,
  });

  final String profilePic;
  final void Function()? onTap;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: height ?? 45,
        width: width ?? 45,
        child: profilePic.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(
                  profilePic,
                  fit: BoxFit.cover,
                ),
              )
            : CircleAvatar(
                radius: height != null
                    ? height! / 2
                    : 22.5, // Make sure the size is consistent
                backgroundColor: textFieldGrey,
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
