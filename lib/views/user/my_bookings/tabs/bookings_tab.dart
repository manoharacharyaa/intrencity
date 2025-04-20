import 'package:flutter/material.dart';
import 'package:intrencity/providers/booking_provider.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/utils/smooth_corners/clip_smooth_rect.dart';
import 'package:intrencity/utils/smooth_corners/smooth_border_radius.dart';
import 'package:intrencity/views/user/parking_space_details_page.dart';
import 'package:intrencity/widgets/smooth_container.dart';
import 'package:provider/provider.dart';

class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key});

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    return Scaffold(
      body: provider.parkings.isEmpty
          ? const Center(
              child: Text('You Have No Bookings'),
            )
          : ListView.builder(
              shrinkWrap: true,
              itemCount: provider.parkings.length,
              itemBuilder: (context, index) {
                final booking = provider.parkings[index];
                return SmoothContainer(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ParkingSpaceDetailsPage(
                        spaceDetails: booking,
                        viewedByCurrentUser: true,
                        alreadyBooked: true,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.all(10),
                  height: 150,
                  width: double.infinity,
                  color: textFieldGrey,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipSmoothRect(
                          radius: SmoothBorderRadius(
                            cornerRadius: 10,
                            cornerSmoothing: 0.8,
                          ),
                          child: Image.network(
                            booking.spaceThumbnail[0],
                            height: 130,
                            width: 130,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(booking.spaceName),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
