import 'dart:io';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intrencity_provider/constants/colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _imgFile;
  final ImagePicker picker = ImagePicker();

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
                    onTap: () {
                      pickImage();
                    },
                    child: _imgFile == null
                        ? const CircleAvatar(
                            radius: 50,
                            backgroundColor: textFieldGrey,
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
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
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('User Details'),
              ),
              ClipSmoothRect(
                radius: SmoothBorderRadius(
                  cornerRadius: 16,
                  cornerSmoothing: 1,
                ),
                child: Container(
                  color: textFieldGrey,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            UserDetailsCardItem(
                              text: '  Manohar Acharya',
                              icon: Icons.person_rounded,
                            ),
                            Divider(thickness: 0.1),
                            UserDetailsCardItem(
                              text: '  manohar@gmail.com',
                              icon: Icons.email,
                            ),
                            Divider(thickness: 0.1),
                            UserDetailsCardItem(
                              text: '  +91 9645124785',
                              icon: Icons.phone,
                            ),
                          ],
                        ),
                      ],
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

//User Details Card Element Widget
class UserDetailsCardItem extends StatelessWidget {
  const UserDetailsCardItem({
    super.key,
    required this.text,
    required this.icon,
  });

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(icon),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          GestureDetector(
            child: Text(
              'Edit',
              style:
                  Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
