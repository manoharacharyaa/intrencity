import 'package:another_dashed_container/another_dashed_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intrencity/models/parking_space_post_model.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/utils/smooth_corners/smooth_border_radius.dart';
import 'package:intrencity/utils/smooth_corners/smooth_rectangle_border.dart';
import 'package:intrencity/views/user/booking_page.dart';

class ParkingSlotPage extends StatefulWidget {
  const ParkingSlotPage({
    super.key,
    required this.space,
  });

  final ParkingSpacePostModel space;

  @override
  State<ParkingSlotPage> createState() => _ParkingSlotPageState();
}

class _ParkingSlotPageState extends State<ParkingSlotPage> {
  Set<int> bookedSlotNumber = {};
  bool isTimePassed = false;

  Stream<void> getBookings() async* {
    final currentUser = FirebaseAuth.instance.currentUser!.uid;
    final currentDateTime = DateTime.now();

    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('spaces')
        .doc(widget.space.docId)
        .get();

    if (docSnapshot.exists) {
      var data = docSnapshot.data() as Map<String, dynamic>;

      if (data.containsKey('bookings')) {
        List<dynamic> bookingsList = data['bookings'];
        List<Booking> bookings =
            bookingsList.map((booking) => Booking.fromJson(booking)).toList();

        List<Booking> validBookings = bookings.where((booking) {
          DateTime endTime = booking.endDateTime;
          return endTime.isAfter(currentDateTime);
        }).toList();

        if (validBookings.isEmpty) return;
        if (mounted) {
          setState(() {
            bookedSlotNumber = validBookings
                .where((booking) => booking.uid == currentUser)
                .map((booking) => booking.slotNumber)
                .toSet();
          });
        }
      }
    }
  }

  Future<void> isBookingTimePassed() async {
    final DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('spaces')
        .doc(widget.space.docId)
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

  @override
  void initState() {
    isBookingTimePassed().then(
      (_) => getBookings(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Parking Slots',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      body: SafeArea(
        child: isTimePassed
            ? const Center(
                child: Text(
                  'The booking has closed\nfor this space',
                  textAlign: TextAlign.center,
                ),
              )
            : Stack(
                children: [
                  const Center(
                    child: VerticalDivider(
                      indent: 20,
                      endIndent: 20,
                      color: primaryBlueTransparent,
                    ),
                  ),
                  StreamBuilder(
                    stream: getBookings(),
                    builder: (context, snapshot) => GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 5 / 5,
                      ),
                      itemCount: int.tryParse(widget.space.spaceSlots),
                      itemBuilder: (context, index) {
                        int slotNumber = index + 1;
                        bool isBooked = bookedSlotNumber.contains(slotNumber);
                        return BookingSlotContainer(
                          slotNumber: slotNumber,
                          isBooked: isBooked,
                          spaceId: widget.space.docId ?? '',
                          startDate: widget.space.startDate,
                          endDate: widget.space.endDate,
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class BookingSlotContainer extends StatefulWidget {
  const BookingSlotContainer({
    super.key,
    required this.isBooked,
    required this.slotNumber,
    required this.spaceId,
    this.startDate,
    this.endDate,
  });

  final bool isBooked;
  final int slotNumber;
  final String spaceId;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  State<BookingSlotContainer> createState() => _BookingSlotContainerState();
}

class _BookingSlotContainerState extends State<BookingSlotContainer> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: DashedContainer(
        borderRadius: 15,
        dashColor: widget.isBooked ? Colors.grey : primaryBlue,
        strokeWidth: 2,
        child: Container(
          height: 140,
          decoration: const BoxDecoration(
            color: Color.fromARGB(52, 68, 137, 255),
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      'Slot ${widget.slotNumber}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    child: MaterialButton(
                      onPressed: widget.isBooked
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookingPage(
                                    slotNumber: widget.slotNumber,
                                    spaceId: widget.spaceId,
                                    startDate: widget.startDate!,
                                    endDate: widget.endDate!,
                                  ),
                                ),
                              );
                            },
                      minWidth: double.infinity,
                      color: widget.isBooked ? Colors.grey : primaryBlue,
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 10,
                          cornerSmoothing: 1,
                        ),
                      ),
                      child: Text(
                        widget.isBooked ? 'Booked' : 'Book',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
