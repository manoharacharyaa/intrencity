import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/models/parking_space_post_model.dart';
import 'package:intrencity/models/user_profile_model.dart';
import 'package:intrencity/providers/auth_provider.dart';
import 'package:intrencity/utils/smooth_corners/clip_smooth_rect.dart';
import 'package:intrencity/utils/smooth_corners/smooth_border_radius.dart';
import 'package:intrencity/views/user/parking_slot_page.dart';
import 'package:intrencity/widgets/buttons/custom_button.dart';
import 'package:intrencity/widgets/cutsom_divider.dart';
import 'package:intrencity/widgets/smooth_container.dart';
import 'package:provider/provider.dart';

class ParkingSpaceDetailsPage extends StatefulWidget {
  const ParkingSpaceDetailsPage({
    super.key,
    required this.spaceDetails,
    required this.viewedByCurrentUser,
  });

  final ParkingSpacePostModel spaceDetails;
  final bool viewedByCurrentUser;

  @override
  State<ParkingSpaceDetailsPage> createState() =>
      _ParkingSpaceDetailsPageState();
}

class _ParkingSpaceDetailsPageState extends State<ParkingSpaceDetailsPage> {
  UserProfileModel? host;
  String profilePic = '';
  bool currentUser = false;
  bool isGuest = false;

  @override
  void initState() {
    super.initState();
    fetchHostUser();
    isCurrentUser();
  }

  void isCurrentUser() {
    bool guest = context.read<AuthenticationProvider>().isGuest;
    setState(() {
      isGuest = guest;
    });
    if (!isGuest) {
      if (widget.spaceDetails.uid == FirebaseAuth.instance.currentUser!.uid) {
        setState(() {
          currentUser = true;
        });
      }
    }
  }

  Future<void> fetchHostUser() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot usersSnapshot = await firestore.collection('users').get();

      for (var user in usersSnapshot.docs) {
        if (user['uid'] == widget.spaceDetails.uid) {
          setState(() {
            host =
                UserProfileModel.fromJson(user.data() as Map<String, dynamic>);
            profilePic = host?.profilePic ?? '';
          });
          break;
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> images = widget.spaceDetails.spaceThumbnail;
    final startDate = DateTime.parse(widget.spaceDetails.startDate.toString());
    final endDate = DateTime.parse(widget.spaceDetails.endDate.toString());
    final formatedStartDate = DateFormat('dd-MM-yy').format(startDate);
    final formatedEndDate = DateFormat('dd-MM-yy').format(endDate);
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    bool isGuest = context.watch<AuthenticationProvider>().isGuest;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Details',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height * 0.015),
            CarouselSlider(
              options: CarouselOptions(
                height: height * 0.3,
                autoPlay: true,
                enlargeCenterPage: true,
                autoPlayInterval: const Duration(seconds: 2),
              ),
              items: images
                  .map((image) => ClipSmoothRect(
                        radius: SmoothBorderRadius(
                          cornerRadius: 10,
                          cornerSmoothing: 0.8,
                        ),
                        child: Image.network(
                          image,
                          fit: BoxFit.cover,
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 30),
            Column(
              children: [
                Text(
                  widget.spaceDetails.spaceName,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 15),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ClipSmoothRect(
                    radius: SmoothBorderRadius(
                      cornerRadius: 15,
                      cornerSmoothing: 0.8,
                    ),
                    child: Container(
                      color: Colors.grey[900],
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SpaceDetailInfo(
                            label: 'Name',
                            info: widget.spaceDetails.spaceName,
                          ),
                          const CustomDivider(),
                          SpaceDetailInfo(
                            label: 'Location',
                            info: widget.spaceDetails.spaceLocation,
                          ),
                          const CustomDivider(),
                          SpaceDetailInfo(
                            label: 'Vehicle Tpes',
                            info: widget.spaceDetails.vehicleType.join(', '),
                          ),
                          const CustomDivider(),
                          SpaceDetailInfo(
                            label: 'Slots & Price',
                            info:
                                'No of slots (${widget.spaceDetails.spaceSlots}) & ${widget.spaceDetails.selectedCurrency}${widget.spaceDetails.spacePrice}',
                          ),
                          const CustomDivider(),
                          SpaceDetailInfo(
                            label: 'Aminities',
                            info: widget.spaceDetails.aminitiesType.join(', '),
                          ),
                          const CustomDivider(),
                          SpaceDetailInfo(
                            label: 'Available From',
                            info: '$formatedStartDate  To  $formatedEndDate',
                          ),
                          const CustomDivider(),
                          SpaceDetailInfo(
                            label: 'Space Description',
                            info: widget.spaceDetails.description!,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                //Hosted Persons Card
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: SmoothContainer(
                    padding: const EdgeInsets.fromLTRB(17, 10, 10, 0),
                    height: height * 0.155,
                    width: double.infinity,
                    cornerRadius: 14,
                    color: Colors.grey[900],
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: height * 0.008),
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Stack(
                                      children: [
                                        SmoothContainer(
                                          height: height * 0.115,
                                          width: width * 0.25,
                                          cornerRadius: 10,
                                          color: textFieldGrey,
                                          child: host == null
                                              ? const SizedBox()
                                              : Image.network(
                                                  profilePic,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                        ClipSmoothRect(
                                          radius: SmoothBorderRadius(
                                              cornerRadius: 8),
                                          child: Container(
                                            height: height * 0.1155,
                                            width: width * 0.25,
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.transparent,
                                                  Color.fromARGB(60, 0, 0, 0),
                                                  Color.fromARGB(120, 0, 0, 0),
                                                  Color.fromARGB(180, 0, 0, 0),
                                                  Color.fromARGB(240, 0, 0, 0),
                                                ],
                                                begin: Alignment.center,
                                                end: Alignment.bottomCenter,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.verified,
                                          size: 18,
                                          color:
                                              Color.fromARGB(255, 12, 225, 19),
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          'Verified',
                                          style:
                                              GoogleFonts.poppins(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Padding(
                            padding: EdgeInsets.only(top: height * 0.0080),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hosted By',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color: primaryBlue, fontSize: 18),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Icon(Icons.person, size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      host == null ? '' : host!.name,
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Icon(Icons.email, size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      host == null ? '' : host!.email,
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Icon(Icons.phone, size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      host == null ? '' : host!.phoneNumber,
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            (currentUser || isGuest)
                ? const SizedBox()
                : CustomButton(
                    title: 'Book',
                    horizontalPadding: 10,
                    verticalPadding: 20,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ParkingSlotPage(
                            space: widget.spaceDetails,
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

class SpaceDetailInfo extends StatelessWidget {
  const SpaceDetailInfo({
    super.key,
    required this.label,
    required this.info,
  });

  final String label;
  final String info;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: primaryBlue,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          info,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
