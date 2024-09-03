import 'dart:io';
import 'package:another_dashed_container/another_dashed_container.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  List<String> selectedVehicleType = [];
  List<String> selectedAminitiesType = [];
  bool isLoading = false;
  final ImagePicker picker = ImagePicker();
  final spaceNameController = TextEditingController();
  final spaceLocationController = TextEditingController();
  final spaceSlotsController = TextEditingController();
  final spacePriceController = TextEditingController();
  final spaceDescController = TextEditingController();
  bool suvSelected = false;
  bool sedanSelected = false;
  bool miniSelected = false;
  bool bikeSelected = false;
  bool chargingSelected = false;
  bool cctvSelected = false;
  bool fireSelected = false;
  bool guardSelected = false;
  DateTime? startDate;
  DateTime? endDate;

  List<String> getSelectedVehicleTypes() {
    if (suvSelected) selectedVehicleType.add('SUV');
    if (sedanSelected) selectedVehicleType.add('Sedan');
    if (miniSelected) selectedVehicleType.add('Mini');
    if (bikeSelected) selectedVehicleType.add('Bike');
    return selectedVehicleType;
  }

  List<String> getSelectedAmitiesType() {
    if (chargingSelected) selectedAminitiesType.add('EV Charging');
    if (cctvSelected) selectedAminitiesType.add('CCTV Surveillance');
    if (fireSelected) selectedAminitiesType.add('Fire Extinguisher');
    if (guardSelected) selectedAminitiesType.add('Security Guard');
    return selectedAminitiesType;
  }

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
          spacePrice: '₹${spacePriceController.text}',
          spaceLocation: spaceLocationController.text,
          spaceSlots: spaceSlotsController.text,
          vehicleType: getSelectedVehicleTypes(),
          aminitiesType: getSelectedAmitiesType(),
          startDate: startDate,
          endDate: endDate,
          description: spaceDescController.text,
          spaceThumbnail: imageUrls,
        );

        await FirebaseFirestore.instance
            .collection('spaces')
            .add(parkingSlotPost.toJson())
            .then((_) {
          setState(() {
            _imgFiles = [];
            startDate = null;
            endDate = null;
            spaceNameController.clear();
            spaceLocationController.clear();
            spaceSlotsController.clear();
            spacePriceController.clear();
            spaceDescController.clear();
            selectedVehicleType = [];
            if (miniSelected || bikeSelected || suvSelected || sedanSelected) {
              bikeSelected = false;
              miniSelected = false;
              sedanSelected = false;
              suvSelected = false;
            }
            if (chargingSelected ||
                cctvSelected ||
                fireSelected ||
                guardSelected) {
              chargingSelected = false;
              cctvSelected = false;
              fireSelected = false;
              guardSelected = false;
            }
          });
        });

        setState(() {
          isLoading = false;
        });

        showSuccessDialog(
            context, 'assets/animations/tick.json', 'Successfully Created!');
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        showSuccessDialog(
          context,
          'assets/animations/cross.json',
          'Failed To Create',
        );

        print("Error occurred while posting space: $e");
      }
    }
  }

  void showSuccessDialog(BuildContext context, String lottie, String message) {
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
                  Text(
                    message,
                    style: const TextStyle(
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

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != startDate) {
      setState(() {
        startDate = pickedDate;
        if (endDate != null && endDate!.isBefore(startDate!)) {
          endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: endDate ?? (startDate ?? DateTime.now()),
      firstDate: startDate ?? DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != endDate) {
      setState(() {
        endDate = pickedDate;
      });
    }
  }

//Format datetime dd/mm/yy
  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              SizedBox(height: height * 0.02),
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
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      controller: spaceSlotsController,
                      keyboardType: TextInputType.number,
                      verticalPadding: 10,
                      hintText: 'no of slots',
                      prefixIcon: Icons.square_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextFormField(
                      controller: spacePriceController,
                      keyboardType: TextInputType.number,
                      verticalPadding: 10,
                      hintText: 'price',
                      prefixIcon: Icons.currency_rupee,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                ' Vehicle Types Allowed',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    CustomChip(
                      vehicleType: 'SUV',
                      isSelected: suvSelected,
                      onTap: () {
                        setState(() {
                          suvSelected = !suvSelected;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    CustomChip(
                      vehicleType: 'Sedan',
                      isSelected: sedanSelected,
                      onTap: () {
                        setState(() {
                          sedanSelected = !sedanSelected;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    CustomChip(
                      vehicleType: 'Mini',
                      isSelected: miniSelected,
                      onTap: () {
                        setState(() {
                          miniSelected = !miniSelected;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    CustomChip(
                      vehicleType: 'Bike',
                      isSelected: bikeSelected,
                      onTap: () {
                        setState(() {
                          bikeSelected = !bikeSelected;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ' Aminities Provided',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    CustomChip(
                      vehicleType: 'Charging',
                      isSelected: chargingSelected,
                      onTap: () {
                        setState(() {
                          chargingSelected = !chargingSelected;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    CustomChip(
                      vehicleType: 'CCTV',
                      isSelected: cctvSelected,
                      onTap: () {
                        setState(() {
                          cctvSelected = !cctvSelected;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    CustomChip(
                      vehicleType: 'Fire Extinguisher',
                      isSelected: fireSelected,
                      onTap: () {
                        setState(() {
                          fireSelected = !fireSelected;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    CustomChip(
                      vehicleType: 'Guard',
                      isSelected: guardSelected,
                      onTap: () {
                        setState(() {
                          guardSelected = !guardSelected;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    ' Available From',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipSmoothRect(
                          radius: SmoothBorderRadius(
                            cornerRadius: 16,
                            cornerSmoothing: 1,
                          ),
                          child: CustomTextFormField(
                            hintText: 'start',
                            maxLines: 1,
                            prefixIcon: Icons.watch_later_outlined,
                            controller: TextEditingController(
                              text: _formatDate(startDate),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () => _selectStartDate(context),
                              icon: const Icon(Icons.date_range),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomTextFormField(
                          hintText: 'end',
                          maxLines: 1,
                          prefixIcon: Icons.watch_later_outlined,
                          controller: TextEditingController(
                            text: _formatDate(endDate),
                          ),
                          suffixIcon: IconButton(
                            onPressed: startDate != null
                                ? () => _selectEndDate(context)
                                : null,
                            icon: const Icon(Icons.date_range),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ClipSmoothRect(
                    radius: SmoothBorderRadius(
                      cornerRadius: 18,
                      cornerSmoothing: 1,
                    ),
                    child: TextField(
                      controller: spaceDescController,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 5,
                      cursorColor: Colors.white,
                      decoration: const InputDecoration(
                        hintText: 'description',
                        contentPadding: EdgeInsets.all(20),
                        prefixIcon: Padding(
                          padding: EdgeInsets.fromLTRB(15, 0, 10, 90),
                          child: Icon(Icons.description),
                        ),
                        prefixIconConstraints: BoxConstraints(
                          maxHeight: double.infinity,
                          maxWidth: double.infinity,
                        ),
                        filled: true,
                        fillColor: textFieldGrey,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: height * 0.029,
              ),
              CustomButton(
                isLoading: isLoading,
                onTap: postSpace,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomDivider extends StatelessWidget {
  const CustomDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Divider(
        thickness: 0.2,
      ),
    );
  }
}

class CustomChip extends StatelessWidget {
  const CustomChip({
    super.key,
    required this.vehicleType,
    this.isSelected = false,
    this.onTap,
  });

  final String vehicleType;
  final bool isSelected;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: onTap,
        child: ClipSmoothRect(
          radius: SmoothBorderRadius(
            cornerRadius: 14,
            cornerSmoothing: 1,
          ),
          child: Container(
            height: 45,
            color: isSelected ? primaryBlue : textFieldGrey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: Text(
                  vehicleType,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
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
