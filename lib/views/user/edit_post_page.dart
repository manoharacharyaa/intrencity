import 'dart:io';
import 'package:another_dashed_container/another_dashed_container.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/models/parking_space_post_model.dart';
import 'package:intrencity/utils/smooth_corners/clip_smooth_rect.dart';
import 'package:intrencity/utils/smooth_corners/smooth_border_radius.dart';
import 'package:intrencity/widgets/buttons/custom_button.dart';
import 'package:intrencity/widgets/custom_chip.dart';
import 'package:intrencity/widgets/custom_text_form_field.dart';
import 'package:intrencity/widgets/dilogue_widget.dart';
import 'package:intrencity/widgets/smooth_container.dart';

enum Per { day, hr, month }

class EditPostPage extends StatefulWidget {
  const EditPostPage({super.key, this.currentUserSpace});

  final ParkingSpacePostModel? currentUserSpace;

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  List<File?> _imgFiles = [];
  List<String> selectedVehicleType = [];
  List<String> selectedAminitiesType = [];
  bool isLoading = false;
  String selectedPer = '';
  String selectedCurrency = '₹';
  bool isCurrencySelected = false;
  final ImagePicker picker = ImagePicker();
  TextEditingController spaceNameController = TextEditingController();
  TextEditingController spaceLocationController = TextEditingController();
  TextEditingController spaceSlotsController = TextEditingController();
  TextEditingController spacePriceController = TextEditingController();
  TextEditingController selectedCurrencyController = TextEditingController();
  TextEditingController spaceDescController = TextEditingController();
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
  ParkingSpacePostModel? edit;
  List<String> imgUrls = [];

  void pickImage() async {
    XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (image == null) {
      return;
    } else {
      setState(() {
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

  Future<List<String>> _fetchSelectedVehicleTypes() async {
    return widget.currentUserSpace?.vehicleType ?? [];
  }

  Future<List<String>> _fetchSelectedAminitiesTypes() async {
    return widget.currentUserSpace?.aminitiesType ?? [];
  }

  Future<void> loadChipSelection() async {
    List<String> selectedVehicleTypes = await _fetchSelectedVehicleTypes();
    List<String> selectedAminitiesTypes = await _fetchSelectedAminitiesTypes();

    setState(() {
      bikeSelected = selectedVehicleTypes.contains('Bike');
      miniSelected = selectedVehicleTypes.contains('Mini');
      sedanSelected = selectedVehicleTypes.contains('Sedan');
      suvSelected = selectedVehicleTypes.contains('SUV');
      chargingSelected = selectedAminitiesTypes.contains('EV Charging');
      cctvSelected = selectedAminitiesTypes.contains('CCTV Surveillance');
      fireSelected = selectedAminitiesTypes.contains('Fire Extinguisher');
      guardSelected = selectedAminitiesTypes.contains('Security Guard');
    });
  }

  Future<void> _fetchDatesFromFirestore() async {
    if (widget.currentUserSpace!.startDate != null &&
        widget.currentUserSpace!.endDate != null) {
      setState(() {
        startDate = widget.currentUserSpace!.startDate;
        endDate = widget.currentUserSpace!.endDate;
      });
    }
  }

  Future<void> _fetchImageUrls() async {
    if (widget.currentUserSpace != null) {
      setState(() {
        imgUrls = List<String>.from(widget.currentUserSpace!.spaceThumbnail);
        // No need to create a fixed-length list. Just make sure the lengths are initially consistent.
        _imgFiles = List<File?>.generate(imgUrls.length, (index) => null);
      });
    }
  }

  Future<void> _addImage() async {
    XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imgFiles.add(File(image.path)); // Add a new image
        imgUrls
            .add(''); // Add a placeholder to imgUrls to keep lengths consistent
      });
    }
  }

  Future<void> _replaceImage(int index) async {
    XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imgFiles[index] =
            File(image.path); // Replace the image at the tapped index
      });
    }
  }

  Future<void> populateFields() async {
    final space = widget.currentUserSpace!;
    spaceNameController = TextEditingController(text: space.spaceName);
    spaceLocationController = TextEditingController(text: space.spaceLocation);
    spacePriceController = TextEditingController(text: space.spacePrice);
    selectedCurrencyController =
        TextEditingController(text: space.selectedCurrency);
    spaceSlotsController = TextEditingController(text: space.spaceSlots);
    spaceDescController = TextEditingController(text: space.description);
  }

  Future<String> _uploadImageToFirebase(File imageFile) async {
    // Upload image to Firebase Storage and get the download URL
    String fileName =
        'editedImages/${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;

    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _updatePost() async {
    try {
      setState(() {
        isLoading = true;
      });
      final currentSpace = widget.currentUserSpace!;

      List<String> updatedThumbnails = [];

      for (int i = 0; i < _imgFiles.length; i++) {
        // If an image file is new (i.e., not null), upload it
        if (_imgFiles[i] != null) {
          String downloadUrl = await _uploadImageToFirebase(_imgFiles[i]!);
          updatedThumbnails.add(downloadUrl);
        } else {
          // Otherwise, keep the existing image URL from Firestore
          updatedThumbnails.add(imgUrls[i]);
        }
      }

      ParkingSpacePostModel updatePost = ParkingSpacePostModel(
        uid: currentSpace.uid,
        docId: currentSpace.docId,
        spaceName: spaceNameController.text,
        spaceLocation: spaceLocationController.text,
        spaceSlots: spaceSlotsController.text,
        spacePrice: spacePriceController.text,
        selectedCurrency: selectedCurrencyController.text,
        vehicleType: [
          if (bikeSelected) 'Bike',
          if (miniSelected) 'Mini',
          if (sedanSelected) 'Sedan',
          if (suvSelected) 'SUV',
        ],
        aminitiesType: [
          if (chargingSelected) 'EV Charging',
          if (cctvSelected) 'CCTV Surveillance',
          if (fireSelected) 'Fire Extinguisher',
          if (guardSelected) 'Security Guard',
        ],
        startDate: startDate,
        endDate: endDate,
        spaceThumbnail: updatedThumbnails,
        description: spaceDescController.text,
      );

      Map<String, dynamic> updateDate = updatePost.toJson();

      await FirebaseFirestore.instance
          .collection('spaces')
          .doc(updatePost.docId)
          .update(updateDate);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating post: $e')),
      );
    }
  }

  void showCountryCurrencyPicker() {
    showCurrencyPicker(
      context: context,
      showFlag: true,
      favorite: ['INR'],
      showCurrencyName: true,
      showCurrencyCode: true,
      onSelect: (Currency currency) {
        setState(() {
          selectedCurrencyController.text =
              currency.symbol.isNotEmpty ? currency.symbol.toString() : '₹';
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    loadChipSelection();
    _fetchImageUrls();
    populateFields();
    _fetchDatesFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final edit = widget.currentUserSpace!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
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
                      items: [
                        // Display prepopulated images and allow replacement
                        ...imgUrls.asMap().entries.map((entry) {
                          int index = entry.key;
                          String imgUrl = entry.value;

                          return Builder(
                            builder: (BuildContext context) {
                              return GestureDetector(
                                onTap: () => _replaceImage(index),
                                child: _imgFiles[index] != null
                                    ? DashedContainer(
                                        borderRadius: 20,
                                        strokeWidth: 4,
                                        dashColor: primaryBlue,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: SizedBox(
                                            height: height * 0.28,
                                            child: Image.file(
                                              _imgFiles[index]!,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            ),
                                          ),
                                        ),
                                      )
                                    : NetworkImageDisplayContainer(
                                        height: height * 0.27,
                                        imgUrl: imgUrl,
                                        onTap: null,
                                      ),
                              );
                            },
                          );
                        }),

                        // Dashed Container for Adding Image as the last item
                        Builder(
                          builder: (BuildContext context) {
                            return InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: _addImage,
                              child: DashedAddImageContainer(
                                height: height * 0.27,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
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
                      maxLines: 1,
                      hintText: 'no of slots',
                      prefixIcon: Icons.square_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Stack(
                      children: [
                        CustomTextFormField(
                          controller: spacePriceController,
                          keyboardType: TextInputType.text,
                          verticalPadding: 10,
                          maxLines: 1,
                          hintText: 'price',
                          prefixIcon: Icons.currency_rupee,
                          suffixIcon: PopupMenuButton(
                            onSelected: (value) {
                              setState(() {
                                selectedPer = value.name;
                                final priceWithoutPer =
                                    spacePriceController.text.split('/').first;
                                spacePriceController.text =
                                    '$priceWithoutPer/$selectedPer';
                              });
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: Per.hr,
                                child: Text('hr'),
                              ),
                              PopupMenuItem(
                                value: Per.day,
                                child: Text('day'),
                              ),
                              PopupMenuItem(
                                value: Per.month,
                                child: Text('month'),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 11, left: 5),
                          child: SmoothContainer(
                            cornerRadius: 16,
                            height: 58,
                            width: 35,
                            color: textFieldGrey,
                            child: InkWell(
                              onTap: showCountryCurrencyPicker,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: TextField(
                                    controller: selectedCurrencyController,
                                    enabled: false,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
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
                      label: 'SUV',
                      isSelected: suvSelected,
                      onTap: () {
                        setState(() {
                          suvSelected = !suvSelected;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    CustomChip(
                      label: 'Sedan',
                      isSelected: sedanSelected,
                      onTap: () {
                        setState(() {
                          sedanSelected = !sedanSelected;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    CustomChip(
                      label: 'Mini',
                      isSelected: miniSelected,
                      onTap: () {
                        setState(() {
                          miniSelected = !miniSelected;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    CustomChip(
                      label: 'Bike',
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
                      label: 'Charging',
                      isSelected: chargingSelected,
                      onTap: () {
                        setState(() {
                          chargingSelected = !chargingSelected;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    CustomChip(
                      label: 'CCTV',
                      isSelected: cctvSelected,
                      onTap: () {
                        setState(() {
                          cctvSelected = !cctvSelected;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    CustomChip(
                      label: 'Fire Extinguisher',
                      isSelected: fireSelected,
                      onTap: () {
                        setState(() {
                          fireSelected = !fireSelected;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    CustomChip(
                      label: 'Guard',
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
                      decoration: InputDecoration(
                        hintText: 'description',
                        contentPadding: const EdgeInsets.all(20),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(
                              bottom: height * 0.1, left: 10, right: 10),
                          child: const Icon(Icons.description),
                        ),
                        prefixIconConstraints: const BoxConstraints(
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
                title: 'Update',
                isLoading: isLoading,
                onTap: () {
                  _updatePost().then((_) {
                    CustomDilogue.showSuccessDialog(
                      context,
                      'assets/animations/tick.json',
                      'Edited Sucessfully!',
                    );
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashedAddImageContainer extends StatelessWidget {
  final double height;

  const DashedAddImageContainer({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
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

// You can use this widget for displaying network images
class NetworkImageDisplayContainer extends StatelessWidget {
  final String imgUrl;
  final double height;
  final VoidCallback? onTap;

  const NetworkImageDisplayContainer({
    super.key,
    required this.imgUrl,
    required this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: DashedContainer(
        dashColor: primaryBlue,
        strokeWidth: imgUrl.isNotEmpty ? 4 : 2,
        borderRadius: 20,
        child: SizedBox(
          height: height * 0.27,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              imgUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
