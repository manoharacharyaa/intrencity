import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intrencity/models/user_profile_model.dart';
import 'package:intrencity/providers/booking_provider.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/utils/smooth_corners/smooth_border_radius.dart';
import 'package:intrencity/utils/smooth_corners/smooth_radius.dart';
import 'package:intrencity/widgets/smooth_container.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApprovalsTab extends StatelessWidget {
  const ApprovalsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    return Scaffold(
      body: StreamBuilder(
        stream: provider.getApprovedBookingStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          } else {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (snapshot.data == null || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('You Have No Approved Bookings'),
              );
            }
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final userWithSpace = snapshot.data![index];
              final space = userWithSpace.space;
              // Find the booking that belongs to the current user
              final booking = space.bookings!.firstWhere((booking) =>
                  booking.uid == FirebaseAuth.instance.currentUser!.uid &&
                  booking.isApproved &&
                  !booking.isRejected);
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SmoothContainer(
                      radius: SmoothBorderRadius(
                        cornerRadius: 14,
                        cornerSmoothing: 0.8,
                      ).copyWith(
                        bottomRight: const SmoothRadius(
                          cornerRadius: 0,
                          cornerSmoothing: 0,
                        ),
                        bottomLeft: const SmoothRadius(
                          cornerRadius: 0,
                          cornerSmoothing: 0,
                        ),
                      ),
                      height: 180,
                      contentPadding: const EdgeInsets.fromLTRB(10, 10, 5, 0),
                      color: textFieldGrey,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 125,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SmoothContainer(
                                    cornerRadius: 12,
                                    height: 125,
                                    width: 125,
                                    child: Image.network(
                                      userWithSpace.space.spaceThumbnail[0],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Slot Number: ${booking.slotNumber.toString()}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Name: ${userWithSpace.space.spaceName}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Space ID: ${booking.bookingId}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Space ID: ${userWithSpace.space.uid}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        FutureBuilder<DocumentSnapshot>(
                                          future: FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(userWithSpace.space.uid)
                                              .get(),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const CupertinoActivityIndicator();
                                            }

                                            if (snapshot.hasError ||
                                                !snapshot.hasData ||
                                                !snapshot.data!.exists) {
                                              return const Text(
                                                'Phone number not available',
                                                style: TextStyle(
                                                    color: Colors.red),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              );
                                            }

                                            final userData = snapshot.data!
                                                .data() as Map<String, dynamic>;
                                            final userProfile =
                                                UserProfileModel.fromJson(
                                              userData,
                                            );
                                            return Text(
                                              'Owner Phone: ${userProfile.phoneNumber}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: SizedBox(
                                height: 30,
                                child: Marquee(
                                  text:
                                      'Location: ${userWithSpace.space.spaceLocation}',
                                  style: Theme.of(context).textTheme.titleSmall,
                                  scrollAxis: Axis.horizontal,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  blankSpace: 20.0,
                                  velocity: 50.0,
                                  pauseAfterRound: const Duration(seconds: 1),
                                  startPadding: 10.0,
                                  accelerationDuration:
                                      const Duration(seconds: 1),
                                  accelerationCurve: Curves.linear,
                                  decelerationDuration:
                                      const Duration(milliseconds: 500),
                                  decelerationCurve: Curves.easeOut,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SmoothContainer(
                      radius: SmoothBorderRadius(
                        cornerRadius: 12,
                        cornerSmoothing: 0.8,
                      ).copyWith(
                        topRight: const SmoothRadius(
                          cornerRadius: 0,
                          cornerSmoothing: 0,
                        ),
                        topLeft: const SmoothRadius(
                          cornerRadius: 0,
                          cornerSmoothing: 0,
                        ),
                      ),
                      color: primaryBlue,
                      height: 40,
                      width: double.infinity,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Verification Code: ',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            SmoothContainer(
                              cornerRadius: 6,
                              contentPadding: const EdgeInsets.all(6),
                              color: Colors.black,
                              child: Text(
                                '${booking.otp}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
