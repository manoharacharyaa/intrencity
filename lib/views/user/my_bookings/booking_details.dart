import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intrencity/models/checkout_model.dart';
import 'package:intrencity/models/parking_space_post_model.dart';
import 'package:intrencity/providers/booking_provider.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/utils/smooth_corners/clip_smooth_rect.dart';
import 'package:intrencity/utils/smooth_corners/smooth_border_radius.dart';
import 'package:intrencity/utils/smooth_corners/smooth_rectangle_border.dart';
import 'package:intrencity/widgets/row_text_tile_widget.dart';
import 'package:intrencity/widgets/smooth_container.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BookingDetails extends StatefulWidget {
  const BookingDetails({
    super.key,
    required this.space,
    required this.booking,
    this.onBookingUpdated,
  });

  final SpaceWithUser space;
  final Booking booking;
  final Function(Booking)? onBookingUpdated;

  @override
  State<BookingDetails> createState() => BookingDetailsState();
}

class BookingDetailsState extends State<BookingDetails> {
  Timer? _timer;
  String _timeRemaining = 'Calculating...';
  bool _showExtendButton = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _calculateTimeRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateTimeRemaining();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _calculateTimeRemaining() {
    final endDateTime = widget.booking.endDateTime;
    final now = DateTime.now();

    if (endDateTime.isAfter(now)) {
      final difference = endDateTime.difference(now);
      final days = difference.inDays;
      final hours = difference.inHours % 24;
      final minutes = difference.inMinutes % 60;
      final seconds = difference.inSeconds % 60;

      setState(() {
        _showExtendButton = difference.inMinutes <= 10;

        if (days > 0) {
          _timeRemaining =
              '$days days, $hours hrs\n$minutes mins, $seconds secs';
        } else if (hours > 0) {
          _timeRemaining = '$hours hrs, $minutes mins, $seconds secs';
        } else if (minutes > 0) {
          _timeRemaining = '$minutes mins, $seconds secs';
        } else {
          _timeRemaining = '$seconds seconds';
        }
      });
    } else {
      setState(() {
        _timeRemaining = 'Booking expired';
        _showExtendButton = false;
      });
      _timer?.cancel();
    }
  }

  Future<void> _extendBooking() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bool hasConflict = await _checkForBookingConflicts();

      if (hasConflict) {
        Fluttertoast.showToast(
          msg: 'Cannot extend booking as another user has reserved this space.',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } else {
        _showExtensionDialog();
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error checking availability: ${e.toString()}',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _checkForBookingConflicts() async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      return false;
    } catch (e) {
      print('Error checking booking conflicts: $e');
      rethrow;
    }
  }

  void _showExtensionDialog() {
    int additionalHours = 1;
    int additionalMinutes = 10;
    bool useMinutes = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: textFieldGrey,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 20,
              cornerSmoothing: 0.8,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Extend Booking',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'How long do you want to extend?',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                SmoothContainer(
                  color: const Color.fromARGB(255, 31, 31, 31),
                  padding: const EdgeInsets.all(15),
                  contentPadding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Radio<bool>(
                            value: false,
                            groupValue: useMinutes,
                            activeColor: primaryBlue,
                            onChanged: (value) {
                              setDialogState(() {
                                useMinutes = false;
                              });
                            },
                          ),
                          Text(
                            'Hours',
                            style: GoogleFonts.poppins(),
                          ),
                        ],
                      ),
                      if (!useMinutes)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(left: 50),
                          child: ClipSmoothRect(
                            radius: SmoothBorderRadius(
                              cornerRadius: 12,
                              cornerSmoothing: 0.8,
                            ),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: primaryBlue,
                                borderRadius: SmoothBorderRadius(
                                  cornerRadius: 12,
                                  cornerSmoothing: 0.8,
                                ),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButton<int>(
                                dropdownColor: Colors.grey[900],
                                borderRadius: SmoothBorderRadius(
                                  cornerRadius: 10,
                                  cornerSmoothing: 0.8,
                                ),
                                value: additionalHours,
                                isExpanded: true,
                                underline: Container(),
                                items: [1, 2, 3, 4, 6, 12, 24].map((hours) {
                                  return DropdownMenuItem<int>(
                                    value: hours,
                                    child: Text(
                                      '$hours hour${hours > 1 ? 's' : ''}',
                                      style: GoogleFonts.poppins(),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setDialogState(() {
                                    if (value != null) {
                                      additionalHours = value;
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Radio<bool>(
                            value: true,
                            groupValue: useMinutes,
                            activeColor: primaryBlue,
                            onChanged: (value) {
                              setDialogState(() {
                                useMinutes = true;
                              });
                            },
                          ),
                          Text(
                            'Minutes',
                            style: GoogleFonts.poppins(),
                          ),
                        ],
                      ),
                      if (useMinutes)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(left: 50),
                          child: ClipSmoothRect(
                            radius: SmoothBorderRadius(
                              cornerRadius: 12,
                              cornerSmoothing: 0.8,
                            ),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: primaryBlue,
                                borderRadius: SmoothBorderRadius(
                                  cornerRadius: 12,
                                  cornerSmoothing: 0.8,
                                ),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButton<int>(
                                dropdownColor: Colors.grey[900],
                                borderRadius: SmoothBorderRadius(
                                  cornerRadius: 10,
                                  cornerSmoothing: 0.8,
                                ),
                                value: additionalMinutes,
                                isExpanded: true,
                                underline: Container(),
                                items: [10, 15, 20, 30, 45].map((minutes) {
                                  return DropdownMenuItem<int>(
                                    value: minutes,
                                    child: Text(
                                      '$minutes minutes',
                                      style: GoogleFonts.poppins(),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setDialogState(() {
                                    if (value != null) {
                                      additionalMinutes = value;
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
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
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    MaterialButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        final duration = useMinutes
                            ? additionalMinutes / 60.0
                            : additionalHours.toDouble();
                        await _confirmExtension(duration);
                      },
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 8,
                          cornerSmoothing: 0.8,
                        ),
                      ),
                      color: greenAccent,
                      child: Text(
                        'Confirm',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmExtension(double hours) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final spaceRef = FirebaseFirestore.instance
          .collection('spaces')
          .doc(widget.booking.spaceId);

      final spaceDoc = await spaceRef.get();
      if (!spaceDoc.exists) {
        throw Exception('Space not found');
      }

      final data = spaceDoc.data() as Map<String, dynamic>;
      List<dynamic> bookings = List.from(data['bookings'] ?? []);

      int bookingIndex = bookings.indexWhere(
        (booking) => booking['booking_id'] == widget.booking.bookingId,
      );

      if (bookingIndex == -1) {
        throw Exception('Booking not found');
      }

      final newEndTime = widget.booking.endDateTime.add(
        Duration(minutes: (hours * 60).round()),
      );

      Map<String, dynamic> updatedBooking = Map.from(bookings[bookingIndex]);
      updatedBooking['end_time'] = Timestamp.fromDate(newEndTime);

      bookings[bookingIndex] = updatedBooking;

      await spaceRef.update({'bookings': bookings});

      final updatedBookingObj =
          widget.booking.copyWith(endDateTime: newEndTime);

      widget.onBookingUpdated!(updatedBookingObj);

      if (mounted) {
        final minutes = (hours * 60).round();
        String message;
        if (minutes >= 60) {
          final wholeHours = minutes ~/ 60;
          final remainingMinutes = minutes % 60;
          message =
              'Booking extended by $wholeHours hour${wholeHours > 1 ? 's' : ''}';
          if (remainingMinutes > 0) {
            message +=
                ' and $remainingMinutes minute${remainingMinutes > 1 ? 's' : ''}';
          }
        } else {
          message =
              'Booking extended by $minutes minute${minutes > 1 ? 's' : ''}';
        }

        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }

      _calculateTimeRemaining();
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Failed to extend booking: ${e.toString()}',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<double> _calculateTotalAmount() async {
    final spacePrice = widget.space.space.spacePrice;

    // More robust price extraction
    final cleanPrice = spacePrice.replaceAll(RegExp(r'[^0-9.]'), '');
    final basePrice = double.tryParse(cleanPrice) ?? 0.0;

    // Enhanced unit detection
    final unitStr = spacePrice.toLowerCase();
    final PricingUnit unit;

    if (unitStr.contains('hour') ||
        unitStr.contains('hr') ||
        unitStr.contains('/h')) {
      unit = PricingUnit.hourly;
    } else if (unitStr.contains('day') || unitStr.contains('/d')) {
      unit = PricingUnit.daily;
    } else if (unitStr.contains('month') || unitStr.contains('/m')) {
      unit = PricingUnit.monthly;
    } else {
      // Default to hourly if unit can't be determined
      unit = PricingUnit.hourly;
    }

    final startTime = widget.booking.startDateTime;
    final endTime = widget.booking.endDateTime;
    final actualCheckoutTime = DateTime.now();

    // Calculate durations
    final originalDuration = endTime.difference(startTime);
    final actualDuration = actualCheckoutTime.difference(startTime);

    debugPrint(
        'Base Price: $basePrice, Unit: $unit, Original Duration: ${originalDuration.inHours} hours, '
        'Actual Duration: ${actualDuration.inHours} hours');

    double totalAmount = 0.0;

    switch (unit) {
      case PricingUnit.hourly:
        // Round up to the nearest hour with a minimum of 1 hour
        final hours = max(1, (actualDuration.inMinutes / 60.0).ceil());
        totalAmount = basePrice * hours;
        break;

      case PricingUnit.daily:
        // Calculate in days - consider partial days
        final originalDays = (originalDuration.inHours / 24.0).ceil();
        final actualDays = actualDuration.inHours / 24.0;

        if (actualDays <= 0.125) {
          // Less than 3 hours
          totalAmount = basePrice * 0.25; // 25% of daily rate
        } else if (actualDays <= 0.5) {
          // Less than 12 hours
          totalAmount = basePrice * 0.5; // Half day rate
        } else {
          // Round up to nearest day, but don't exceed original booking
          totalAmount = basePrice * min(originalDays, actualDays.ceil());
        }
        break;

      case PricingUnit.monthly:
        // Calculate in months - consider partial months
        final originalMonths = (originalDuration.inDays / 30.0).ceil();
        final actualDays = actualDuration.inDays;

        if (actualDays <= 1) {
          totalAmount = basePrice * (1 / 30); // One day rate
        } else if (actualDays <= 7) {
          totalAmount = basePrice * (7 / 30); // One week rate
        } else if (actualDays <= 15) {
          totalAmount = basePrice * 0.5; // Half month rate
        } else {
          // Full month rate, but don't exceed original booking
          final actualMonths = actualDays / 30.0;
          totalAmount = basePrice * min(originalMonths, actualMonths.ceil());
        }
        break;
    }

    debugPrint('Calculated total amount: $totalAmount');
    return totalAmount;
  }

  Future<void> _handleCheckout({bool isLateCheckout = false}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final spaceRef = FirebaseFirestore.instance
          .collection('spaces')
          .doc(widget.booking.spaceId);

      final spaceDoc = await spaceRef.get();
      if (!spaceDoc.exists) {
        throw Exception('Space not found');
      }

      final data = spaceDoc.data() as Map<String, dynamic>;
      List<dynamic> bookings = List.from(data['bookings'] ?? []);

      int bookingIndex = bookings.indexWhere(
        (booking) => booking['booking_id'] == widget.booking.bookingId,
      );

      if (bookingIndex == -1) {
        throw Exception('Booking not found');
      }

      Duration? overtimeDuration;
      double? fineAmount;
      double baseAmount = await _calculateTotalAmount();

      if (isLateCheckout) {
        final endDateTime = widget.booking.endDateTime;
        final now = DateTime.now();
        overtimeDuration = now.difference(endDateTime);

        final overtimeHours = (overtimeDuration.inMinutes / 60).ceil();
        fineAmount = overtimeHours * 10.0;

        await FirebaseFirestore.instance.collection('fines').add({
          'booking_id': widget.booking.bookingId,
          'user_id': widget.booking.uid,
          'space_id': widget.booking.spaceId,
          'amount': fineAmount,
          'overtime_duration': overtimeDuration.inMinutes,
          'created_at': FieldValue.serverTimestamp(),
          'paid': false,
        });
      }

      bookings[bookingIndex] = {
        ...bookings[bookingIndex],
        'is_checked_out': true,
        'checkout_time': DateTime.now().toIso8601String(),
        'early_checkout': !isLateCheckout &&
            DateTime.now().isBefore(widget.booking.endDateTime),
      };

      await spaceRef.update({'bookings': bookings});

      final checkout = CheckoutModel(
        actualCheckoutTime: DateTime.now(),
        baseAmount: baseAmount,
        bookingId: widget.booking.bookingId,
        checkoutTime: DateTime.now(),
        currency: widget.space.space.selectedCurrency ?? '',
        endTime: widget.booking.endDateTime,
        fineAmount: fineAmount,
        isEarlyCheckout: !isLateCheckout &&
            DateTime.now().isBefore(widget.booking.endDateTime),
        isLateCheckout: isLateCheckout,
        overtimeDuration: isLateCheckout ? overtimeDuration?.inMinutes : null,
        slotNumber: widget.booking.slotNumber,
        spaceId: widget.booking.spaceId,
        spaceName: widget.space.space.spaceName,
        startTime: widget.booking.startDateTime,
        totalAmount: baseAmount + (fineAmount ?? 0.0),
        userId: widget.booking.uid,
      );

      await FirebaseFirestore.instance
          .collection('checkouts')
          .add(checkout.toJson());

      if (mounted) {
        Navigator.pop(context);

        if (isLateCheckout) {
          Fluttertoast.showToast(
            msg:
                'Late checkout processed.\nBase amount: ${widget.space.space.selectedCurrency}${baseAmount.toStringAsFixed(2)}\nFine amount: ${widget.space.space.selectedCurrency}${fineAmount?.toStringAsFixed(2)}\nTotal: ${widget.space.space.selectedCurrency}${(baseAmount + (fineAmount ?? 0.0)).toStringAsFixed(2)}',
            backgroundColor: Colors.orange,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_LONG,
          );
        } else {
          Fluttertoast.showToast(
            msg:
                'Checkout successful.\nTotal amount: ${widget.space.space.selectedCurrency}${baseAmount.toStringAsFixed(2)}',
            backgroundColor: Colors.green,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_LONG,
          );
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error during checkout: ${e.toString()}',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Details'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SmoothContainer(
                color: textFieldGrey,
                padding: const EdgeInsets.all(10),
                contentPadding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RowTextTile(
                      widget: widget,
                      label: 'Space Name: ',
                      text: widget.space.space.spaceName,
                    ),
                    RowTextTile(
                      widget: widget,
                      label: 'Slot Number: ',
                      text: widget.space.space.spaceSlots.toString(),
                    ),
                    RowTextTile(
                      widget: widget,
                      label: 'Price: ',
                      text:
                          '${widget.space.space.selectedCurrency} ${widget.space.space.spacePrice}',
                    ),
                    RowTextTile(
                      widget: widget,
                      label: 'End Time: ',
                      text: DateFormat('MMM dd, yyyy hh:mm a')
                          .format(widget.booking.endDateTime),
                    ),
                    const SizedBox(height: 10),
                    SmoothContainer(
                      color: Colors.grey[900],
                      cornerRadius: 12,
                      width: double.infinity,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Lottie.asset(
                              'assets/animations/clock.json',
                              height: 100,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _timeRemaining == 'Booking expired'
                                    ? const Icon(
                                        Icons.warning_amber,
                                        color: Colors.red,
                                      )
                                    : const Text(
                                        'Time Remaining',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                const SizedBox(height: 5),
                                Text(
                                  _timeRemaining,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: _timeRemaining == 'Booking expired'
                                        ? Colors.red
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_showExtendButton &&
                        _timeRemaining != 'Booking expired')
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.timer_outlined),
                          label: Text(
                            'Extend Time',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: _isLoading ? null : _extendBooking,
                        ),
                      ),
                    if (_timeRemaining == 'Booking expired')
                      SmoothContainer(
                        cornerRadius: 12,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        contentPadding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 12,
                            cornerSmoothing: 0.8,
                          ),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning_amber,
                                    color: Colors.red[700]),
                                const SizedBox(width: 8),
                                Text(
                                  'Late Checkout',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.red[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'You have exceeded your booking time. A fine will be applied according to our policy (\$10/hour).',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(color: Colors.red),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: _isLoading
                                    ? null
                                    : () =>
                                        _handleCheckout(isLateCheckout: true),
                                child: Text(
                                  'Checkout Now',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_timeRemaining != 'Booking expired')
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed:
                              _isLoading ? null : () => _handleCheckout(),
                          child: Text(
                            'Checkout',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CupertinoActivityIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

// Define pricing unit enum for clearer code
enum PricingUnit { hourly, daily, monthly }
