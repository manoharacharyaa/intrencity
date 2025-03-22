import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/models/parking_space_post_model.dart';
import 'package:intrencity/utils/smooth_corners/clip_smooth_rect.dart';
import 'package:intrencity/utils/smooth_corners/smooth_border_radius.dart';
import 'package:intrencity/widgets/add_img_container.dart';
import 'package:intrencity/widgets/buttons/custom_button.dart';
import 'package:intrencity/widgets/custom_chip.dart';
import 'package:intrencity/widgets/custom_text_form_field.dart';
import 'package:intrencity/widgets/dilogue_widget.dart';
import 'package:intrencity/widgets/img_picker_container.dart';
import 'package:intrencity/widgets/smooth_container.dart';
import 'package:uuid/uuid.dart';

enum Per { day, hr, month }

class SpacePostingPage extends StatefulWidget {
  const SpacePostingPage({super.key});

  @override
  State<SpacePostingPage> createState() => _SpacePostingPageState();
}

class _SpacePostingPageState extends State<SpacePostingPage> {
  List<File> _imgFiles = [];
  List<String> selectedVehicleType = [];
  List<String> selectedAminitiesType = [];
  String selectedPer = '';
  bool isLoading = false;
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

  @override
  void dispose() {
    spaceNameController.dispose();
    spaceLocationController.dispose();
    spaceSlotsController.dispose();
    spacePriceController.dispose();
    selectedCurrencyController.dispose();
    spaceDescController.dispose();
    super.dispose();
  }

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
        // Upload images and get URLs
        for (var imgFile in _imgFiles) {
          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          Reference storageReference =
              FirebaseStorage.instance.ref().child('space_image/$fileName');
          UploadTask uploadTask = storageReference.putFile(imgFile);
          TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
          String downloadUrl = await snapshot.ref.getDownloadURL();
          imageUrls.add(downloadUrl);
        }

        final docId = const Uuid().v1();
        ParkingSpacePostModel parkingSlotPost = ParkingSpacePostModel(
          uid: FirebaseAuth.instance.currentUser!.uid,
          docId: docId,
          spaceName: spaceNameController.text,
          spacePrice: spacePriceController.text,
          selectedCurrency: selectedCurrencyController.text.isEmpty
              ? '₹'
              : selectedCurrencyController.text,
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
            .doc(docId)
            .set(parkingSlotPost.toJson())
            .then(
              (value) => Future.delayed(
                const Duration(seconds: 2),
                () => Navigator.pop,
              ),
            );

        setState(() {
          _imgFiles = [];
          startDate = null;
          endDate = null;
          spaceNameController.clear();
          spaceLocationController.clear();
          spaceSlotsController.clear();
          spacePriceController.clear();
          selectedCurrencyController.clear();
          spaceDescController.clear();
          selectedVehicleType = [];
          bikeSelected = miniSelected = sedanSelected = suvSelected = false;
          chargingSelected =
              cctvSelected = fireSelected = guardSelected = false;
          isLoading = false;
        });

        CustomDilogue.showSuccessDialog(
          context,
          'assets/animations/tick.json',
          'Successfully Created!',
        );
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        CustomDilogue.showSuccessDialog(
          context,
          'assets/animations/cross.json',
          'Failed To Create',
        );
        print("Error occurred while posting space: $e");
      }
    }
  }

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

  void showCountryCurrencyPicker() {
    showCurrencyPicker(
      context: context,
      showFlag: true,
      showCurrencyName: true,
      showCurrencyCode: true,
      favorite: ['INR'],
      onSelect: (Currency currency) {
        setState(() {
          selectedCurrencyController.text = currency.symbol.toString();
        });
      },
    );
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
                          keyboardType: TextInputType.number,
                          verticalPadding: 10,
                          hintText: 'price',
                          maxLines: 1,
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
                                  child: selectedCurrencyController.text.isEmpty
                                      ? const Text('₹')
                                      : TextField(
                                          controller:
                                              selectedCurrencyController,
                                          enabled: false,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
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
                title: 'Post',
                isLoading: isLoading,
                onTap: () async {
                  await postSpace();
                  await Future.delayed(const Duration(seconds: 2));
                  Navigator.pop;
                  Navigator.pop;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
