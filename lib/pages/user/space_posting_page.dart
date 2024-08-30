import 'dart:io';
import 'package:another_dashed_container/another_dashed_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intrencity_provider/constants/colors.dart';
import 'package:intrencity_provider/model/parking_space_post_model.dart';
import 'package:intrencity_provider/widgets/buttons/custom_button.dart';
import 'package:intrencity_provider/widgets/custom_text_form_field.dart';

class SpacePostingPage extends StatefulWidget {
  const SpacePostingPage({super.key});

  @override
  State<SpacePostingPage> createState() => _SpacePostingPageState();
}

class _SpacePostingPageState extends State<SpacePostingPage> {
  File? _imgFile;
  bool isLoading = false;
  final ImagePicker picker = ImagePicker();
  final spaceNameController = TextEditingController();
  final spaceLocationController = TextEditingController();
  final spacePriceController = TextEditingController();

  Future<void> postSpace() async {
    if (_imgFile != null) {
      isLoading = true;
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference =
          FirebaseStorage.instance.ref().child('space_image/$fileName');
      UploadTask uploadTask = storageReference.putFile(_imgFile!);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
      String downloadUrl = await snapshot.ref.getDownloadURL();

      ParkingSpacePost parkingSlotPost = ParkingSpacePost(
        spaceName: spaceNameController.text,
        spacePrice: '₹ ${spacePriceController.text}',
        spaceLocation: spaceLocationController.text,
        spaceThumbnail: downloadUrl,
      );

      await FirebaseFirestore.instance
          .collection('spaces')
          .add(parkingSlotPost.toJson())
          .then((_) {
        isLoading = false;
      });
    }
    setState(() {});
  }

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
    final height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Spaces'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            ImagePickerContainer(
              height: height,
              imgFile: _imgFile,
              onTap: pickImage,
            ),
            const SizedBox(height: 30),
            CustomTextFormField(
              controller: spaceNameController,
              verticalPadding: 10,
              hintText: 'name',
              prefixIcon: Icons.add_road,
            ),
            CustomTextFormField(
              controller: spaceLocationController,
              verticalPadding: 10,
              hintText: 'location',
              prefixIcon: Icons.location_on_outlined,
            ),
            CustomTextFormField(
              controller: spacePriceController,
              verticalPadding: 10,
              hintText: 'price',
              prefixIcon: Icons.currency_rupee,
            ),
            const Spacer(),
            CustomButton(
              isLoading: isLoading,
              onTap: postSpace,
            ),
          ],
        ),
      ),
    );
  }
}

class ImagePickerContainer extends StatelessWidget {
  const ImagePickerContainer({
    super.key,
    required this.height,
    required File? imgFile,
    required this.onTap,
  }) : _imgFile = imgFile;

  final double height;
  final File? _imgFile;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: SizedBox(
        height: height * 0.27,
        width: double.infinity,
        child: DashedContainer(
          dashColor: primaryBlue,
          strokeWidth: 2,
          borderRadius: 20,
          child: _imgFile == null
              ? const Center(
                  child: Icon(
                    Icons.photo,
                    size: 50,
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    _imgFile!,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
      ),
    );
  }
}
