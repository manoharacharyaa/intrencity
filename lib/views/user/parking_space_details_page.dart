import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:go_router/go_router.dart';
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
import 'package:intrencity/widgets/contact_button.dart';
import 'package:intrencity/widgets/cutsom_divider.dart';
import 'package:intrencity/widgets/smooth_container.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';

class ParkingSpaceDetailsPage extends StatefulWidget {
  const ParkingSpaceDetailsPage({
    super.key,
    required this.spaceDetails,
    required this.viewedByCurrentUser,
    this.alreadyBooked = false,
  });

  final ParkingSpacePostModel spaceDetails;
  final bool viewedByCurrentUser;
  final bool alreadyBooked;

  @override
  State<ParkingSpaceDetailsPage> createState() =>
      _ParkingSpaceDetailsPageState();
}

class _ParkingSpaceDetailsPageState extends State<ParkingSpaceDetailsPage> {
  UserProfileModel? host;
  String profilePic = '';
  bool currentUser = false;
  bool isGuest = false;
  bool isTimePassed = false;
  bool hasBooking = false;

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

  Future<void> isBookingTimePassed() async {
    final DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('spaces')
        .doc(widget.spaceDetails.docId)
        .get();

    if (snapshot.exists) {
      var data = snapshot.data() as Map<String, dynamic>;
      if (data.containsKey('endDate')) {
        DateTime endDate = data['endDate'].toDate();
        if (endDate.isBefore(DateTime.now())) {
          setState(() {
            isTimePassed = true;
          });
        }
      }
    }
  }

  Future<void> userHasBooking() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final now = DateTime.now();
    setState(() {
      hasBooking = false;
    });

    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('spaces').get();

    for (var doc in snapshot.docs) {
      final space = doc.data() as Map<String, dynamic>;
      if (space.containsKey('bookings')) {
        List<dynamic> bookings = space['bookings'] ?? [];

        for (var booking in bookings) {
          if (booking['uid'] != currentUserId) continue;

          if (booking.containsKey('is_checked_out') &&
              booking['is_checked_out'] == true) {
            continue;
          }

          final startDateTime = (booking['start_time'] as Timestamp).toDate();
          final endDateTime = (booking['end_time'] as Timestamp).toDate();

          if (now.isAfter(startDateTime) && now.isBefore(endDateTime)) {
            setState(() {
              hasBooking = true;
            });
            return;
          }
        }
      }
    }
  }

  _callNumber(String phoneNumber) async {
    await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }

  @override
  void initState() {
    super.initState();
    userHasBooking();
    fetchHostUser();
    isCurrentUser();
    isBookingTimePassed();
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
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isCurrentUserOwner = widget.spaceDetails.uid == currentUserId;

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
                isTimePassed
                    ? SizedBox(
                        height: 30,
                        width: double.infinity,
                        child: Marquee(
                          text:
                              'Booking for ${widget.spaceDetails.spaceName} has closed',
                          style: const TextStyle(color: Colors.red),
                          scrollAxis: Axis.horizontal,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          blankSpace: 20.0,
                          velocity: 100.0,
                          pauseAfterRound: const Duration(seconds: 1),
                          startPadding: 10.0,
                          accelerationDuration: const Duration(seconds: 1),
                          accelerationCurve: Curves.linear,
                          decelerationDuration:
                              const Duration(milliseconds: 500),
                          decelerationCurve: Curves.easeOut,
                        ),
                      )
                    : const SizedBox.shrink(),
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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Stack(
                    children: [
                      SmoothContainer(
                        height: height * 0.155,
                        width: double.infinity,
                        cornerRadius: 14,
                        color: Colors.grey[900],
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(width: 15),
                              Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Stack(
                                    children: [
                                      SmoothContainer(
                                        height: height * 0.120,
                                        width: width * 0.25,
                                        cornerRadius: 8,
                                        color: primaryBlue,
                                        child: host == null
                                            ? const SizedBox()
                                            : Image.network(
                                                profilePic,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return const Icon(
                                                      Icons.person);
                                                },
                                              ),
                                      ),
                                      ClipSmoothRect(
                                        radius: SmoothBorderRadius(
                                          cornerRadius: 8,
                                        ),
                                        child: Container(
                                          height: height * 0.120,
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
                                        color: Color.fromARGB(255, 12, 225, 19),
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
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                        style:
                                            GoogleFonts.poppins(fontSize: 14),
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
                                        style:
                                            GoogleFonts.poppins(fontSize: 14),
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
                                        style:
                                            GoogleFonts.poppins(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                !isCurrentUserOwner
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            ContactButton(
                              label: 'Chat',
                              icon: Icons.chat,
                              onPressed: () {
                                if (currentUserId == null) {
                                  context.push('/auth-page');
                                  return;
                                }
                                context.push(
                                  '/chat',
                                  extra: {
                                    'receiverId': widget.spaceDetails.uid,
                                    'receiverName':
                                        widget.spaceDetails.ownerName ??
                                            'Space Owner',
                                  },
                                );
                              },
                            ),
                            const SizedBox(width: 10),
                            ContactButton(
                              label: 'Call',
                              icon: Icons.phone,
                              onPressed: () => _callNumber(host!.phoneNumber),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(),
                hasBooking
                    ? Column(
                        children: [
                          const SizedBox(height: 20),
                          SmoothContainer(
                            onTap: () => context.pop(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            color: textFieldGrey,
                            height: 60,
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                'You already have a booking',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(color: primaryBlue),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      )
                    : (currentUser ||
                            isGuest ||
                            isTimePassed ||
                            widget.alreadyBooked)
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
                const SizedBox(height: 20),
              ],
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
