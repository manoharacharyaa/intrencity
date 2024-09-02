import 'dart:io';
import 'package:another_dashed_container/another_dashed_container.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intrencity_provider/constants/colors.dart';
import 'package:intrencity_provider/model/parking_space_post_model.dart';
import 'package:intrencity_provider/widgets/buttons/custom_button.dart';
import 'package:intrencity_provider/widgets/custom_text_form_field.dart';
import 'package:lottie/lottie.dart';

class SpacePostingPage extends StatefulWidget {
  const SpacePostingPage({super.key});

  @override
  State<SpacePostingPage> createState() => _SpacePostingPageState();
}

class _SpacePostingPageState extends State<SpacePostingPage> {
  List<File> _imgFiles = [];
  bool isLoading = false;
  final ImagePicker picker = ImagePicker();
  final spaceNameController = TextEditingController();
  final spaceLocationController = TextEditingController();
  final spacePriceController = TextEditingController();

  Future<void> postSpace() async {
    if (_imgFiles.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      List<String> imageUrls = [];

      try {
        for (var imgFile in _imgFiles) {
          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          Reference storageReference =
              FirebaseStorage.instance.ref().child('space_image/$fileName');
          UploadTask uploadTask = storageReference.putFile(imgFile);
          TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
          String downloadUrl = await snapshot.ref.getDownloadURL();
          imageUrls.add(downloadUrl);
        }

        ParkingSpacePost parkingSlotPost = ParkingSpacePost(
          spaceName: spaceNameController.text,
          spacePrice: '₹ ${spacePriceController.text}',
          spaceLocation: spaceLocationController.text,
          spaceThumbnail: imageUrls,
        );

        await FirebaseFirestore.instance
            .collection('spaces')
            .add(parkingSlotPost.toJson())
            .then((_) {
          setState(() {
            spaceNameController.clear();
            spaceLocationController.clear();
            spacePriceController.clear();
            _imgFiles = [];
          });
        });

        setState(() {
          isLoading = false;
        });

        showSuccessDialog(context, 'assets/animations/tick.json');
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        showSuccessDialog(context, 'assets/animations/cross.json');

        print("Error occurred while posting space: $e");
      }
    }
  }

  void showSuccessDialog(BuildContext context, String lottie) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ClipSmoothRect(
          radius: SmoothBorderRadius(
            cornerRadius: 5,
            cornerSmoothing: 5,
          ),
          child: Dialog(
            backgroundColor: Colors.grey[900],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    lottie,
                    width: 120,
                    height: 120,
                    repeat: false,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Successfully Created!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ClipSmoothRect(
                    radius: SmoothBorderRadius(
                      cornerRadius: 12,
                      cornerSmoothing: 1,
                    ),
                    child: SizedBox(
                      width: 70,
                      height: 45,
                      child: MaterialButton(
                        padding: const EdgeInsets.all(8),
                        color: primaryBlue,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'OK',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void pickImage() async {
    XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (image == null) {
      return;
    } else {
      setState(() {
        // _imgFile = File(image.path);
        _imgFiles.add(File(image.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Space'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: ListView(
          children: [
            SizedBox(
              height: height * 0.28,
              child: CarouselSlider(
                options: CarouselOptions(
                  height: height * 0.27,
                  enableInfiniteScroll: false,
                  enlargeCenterPage: true,
                  autoPlay: false,
                  scrollDirection: Axis.horizontal,
                ),
                items: _imgFiles.map((imgFile) {
                  return Builder(
                    builder: (BuildContext context) {
                      return ImagePickerContainer(
                        height: height * 0.27,
                        imgFile: imgFile,
                        onTap: null,
                      );
                    },
                  );
                }).toList()
                  ..add(
                    Builder(
                      builder: (BuildContext context) {
                        return AddImageContainer(
                          height: height * 0.27,
                          onTap: pickImage,
                        );
                      },
                    ),
                  ),
              ),
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
              keyboardType: TextInputType.number,
              verticalPadding: 10,
              hintText: 'price',
              prefixIcon: Icons.currency_rupee,
            ),
            SizedBox(
              height: height * 0.11,
            ),
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

class AddImageContainer extends StatelessWidget {
  const AddImageContainer({
    super.key,
    required this.onTap,
    this.height = 0,
  });

  final void Function()? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: DashedContainer(
          dashColor: primaryBlue,
          strokeWidth: 2,
          borderRadius: 20,
          child: const Center(
            child: Icon(
              Icons.add_photo_alternate,
              size: 50,
              color: primaryBlue,
            ),
          ),
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
          strokeWidth: _imgFile != null ? 4 : 2,
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
                    _imgFile,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
      ),
    );
  }
}
