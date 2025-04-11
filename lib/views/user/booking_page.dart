import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intrencity/models/parking_space_post_model.dart';
import 'package:intrencity/providers/booking_provider.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/utils/smooth_corners/clip_smooth_rect.dart';
import 'package:intrencity/utils/smooth_corners/smooth_border_radius.dart';
import 'package:intrencity/utils/smooth_corners/smooth_rectangle_border.dart';
import 'package:intrencity/widgets/buttons/custom_button.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({
    super.key,
    required this.slotNumber,
    required this.spaceId,
    required this.startDate,
    required this.endDate,
  });

  final int slotNumber;
  final String spaceId;
  final DateTime startDate;
  final DateTime endDate;

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? startDateTime;
  DateTime? endDateTime;

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    DateTime? selectedDateTime = isStart ? startDateTime : endDateTime;

    DateTime effectiveMinimumDate = isStart
        ? (DateTime.now().isAfter(widget.startDate)
            ? DateTime.now()
            : widget.startDate)
        : (startDateTime != null
            ? startDateTime!.add(const Duration(minutes: 30))
            : widget.startDate);

    if (!isStart && effectiveMinimumDate.isBefore(widget.startDate)) {
      effectiveMinimumDate = widget.startDate;
    }

    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return ClipSmoothRect(
          radius: SmoothBorderRadius(cornerRadius: 15, cornerSmoothing: 0.8),
          child: Container(
            height: 300,
            color: const Color.fromARGB(255, 26, 26, 26),
            child: Column(
              children: [
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.dateAndTime,
                    initialDateTime: selectedDateTime ?? effectiveMinimumDate,
                    minimumDate: effectiveMinimumDate,
                    maximumDate: widget.endDate,
                    backgroundColor: const Color.fromARGB(255, 26, 26, 26),
                    onDateTimeChanged: (DateTime newDateTime) {
                      selectedDateTime = newDateTime;
                    },
                    use24hFormat: true,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MaterialButton(
                      onPressed: () => Navigator.pop(context),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 8,
                          cornerSmoothing: 0.8,
                        ),
                      ),
                      color: redAccent,
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                    const SizedBox(width: 40),
                    MaterialButton(
                      color: greenAccent,
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 8,
                          cornerSmoothing: 0.8,
                        ),
                      ),
                      onPressed: () {
                        if (selectedDateTime != null) {
                          if (!isStart &&
                              startDateTime != null &&
                              selectedDateTime!.isBefore(startDateTime!
                                  .add(const Duration(minutes: 30)))) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'End time must be at least 30 minutes after start time'),
                              ),
                            );
                            return;
                          }
                          setState(() {
                            if (isStart) {
                              startDateTime = selectedDateTime!;
                            } else {
                              endDateTime = selectedDateTime!;
                            }
                          });
                        }
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Confirm',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final provider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Booking Page",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: provider.doesBookingExist(widget.spaceId, widget.slotNumber),
          builder: (context, snapshot) {
            final bookingExists = snapshot.data ?? false;
            return bookingExists
                ? const Center(
                    child: Text('You Are On The Wait List'),
                  )
                : SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'assets/animations/car_animation.json',
                          height: height * 0.4,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () => _selectDateTime(context, true),
                                child: ClipSmoothRect(
                                  radius: SmoothBorderRadius(
                                    cornerRadius: 14,
                                    cornerSmoothing: 0.8,
                                  ),
                                  child: Container(
                                    height: 55,
                                    color: textFieldGrey,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          startDateTime == null
                                              ? 'Select start date & time'
                                              : '${startDateTime!.toLocal()}'
                                                  .split('.')[0],
                                          style: const TextStyle(
                                            fontSize: 17,
                                          ),
                                        ),
                                        const Icon(Icons.calendar_today),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: () {
                                  if (startDateTime == null) {
                                    Fluttertoast.showToast(
                                      msg: 'Select Start Date & Time',
                                    );
                                    return;
                                  }
                                  _selectDateTime(context, false);
                                },
                                child: ClipSmoothRect(
                                  radius: SmoothBorderRadius(
                                    cornerRadius: 14,
                                    cornerSmoothing: 0.8,
                                  ),
                                  child: Container(
                                    height: 55,
                                    color: textFieldGrey,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          endDateTime == null
                                              ? 'Select end date & time'
                                              : '${endDateTime!.toLocal()}'
                                                  .split('.')[0],
                                          style: const TextStyle(
                                            fontSize: 17,
                                          ),
                                        ),
                                        const Icon(Icons.calendar_today),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        CustomButton(
                          horizontalPadding: 10,
                          title: 'Book',
                          onTap: () {
                            if (startDateTime == null || endDateTime == null) {
                              Fluttertoast.showToast(
                                msg: "Start & End Date Cant Be Null",
                              );
                              return;
                            } else if (endDateTime!.isBefore(startDateTime!)) {
                              Fluttertoast.showToast(
                                msg: "End time cannot be before start time.",
                              );
                              return;
                            } else if (startDateTime!
                                .isBefore(DateTime.now())) {
                              Fluttertoast.showToast(
                                msg: "The time selected has already passed.",
                              );
                              return;
                            } else {
                              FirebaseFirestore.instance
                                  .collection('spaces')
                                  .doc(widget.spaceId)
                                  .update({
                                'bookings': FieldValue.arrayUnion([
                                  Booking(
                                    isApproved: false,
                                    uid: FirebaseAuth.instance.currentUser!.uid,
                                    spaceId: widget.spaceId,
                                    slotNumber: widget.slotNumber,
                                    startDateTime: startDateTime!,
                                    endDateTime: endDateTime!,
                                    bookingTime: DateTime.now(),
                                    bookingId: Random().nextInt(6).toString(),
                                  ).toJson(),
                                ])
                              }).then(
                                (_) {
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                },
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  );
          },
        ),
      ),
    );
  }
}
