import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intrencity/models/checkout_model.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/utils/smooth_corners/smooth_border_radius.dart';
import 'package:intrencity/widgets/smooth_container.dart';
import 'package:intrencity/widgets/row_text_tile_widget.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  List<CheckoutModel> bookingHistory = [];

  Future<List<CheckoutModel>> getBookingHistory() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('checkouts')
        .where('user_id', isEqualTo: uid)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return bookingHistory = snapshot.docs
          .map(
            (doc) => CheckoutModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } else {
      return [];
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
  }

  Widget _buildBookingCard(CheckoutModel booking) {
    return SmoothContainer(
      padding: const EdgeInsets.only(bottom: 16),
      contentPadding: const EdgeInsets.all(16),
      color: textFieldGrey,
      radius: SmoothBorderRadius(
        cornerRadius: 14,
        cornerSmoothing: 0.8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            booking.spaceName,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          RowTextTile(
            label: 'Location: ',
            text: booking.spaceLocation ?? 'N/A',
          ),
          RowTextTile(
            label: 'Slot Number: ',
            text: booking.slotNumber.toString(),
          ),
          const Divider(height: 24),
          RowTextTile(
            label: 'Start Time: ',
            text: _formatDateTime(booking.startTime),
          ),
          RowTextTile(
            label: 'End Time: ',
            text: _formatDateTime(booking.endTime),
          ),
          RowTextTile(
            label: 'Checkout Time: ',
            text: _formatDateTime(
                booking.actualCheckoutTime), // Changed from checkoutTime
          ),
          const Divider(height: 24),
          RowTextTile(
            label: 'Base Price: ',
            text: '${booking.currency}${booking.baseAmount.toStringAsFixed(2)}',
          ),
          if (booking.isLateCheckout) ...[
            RowTextTile(
              label: 'Overtime Duration: ',
              text: '${booking.overtimeDuration} minutes',
            ),
            RowTextTile(
              label: 'Fine Amount: ',
              text:
                  '${booking.currency}${booking.fineAmount?.toStringAsFixed(2)}',
            ),
          ],
          if (booking.isEarlyCheckout)
            const RowTextTile(
              label: 'Status: ',
              text: 'Early Checkout',
            ),
          const Divider(height: 24),
          RowTextTile(
            label: 'Total Amount: ',
            text:
                '${booking.currency}${booking.totalAmount.toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Booking History',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      body: FutureBuilder<List<CheckoutModel>>(
        future: getBookingHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CupertinoActivityIndicator(radius: 14),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No booking history found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final booking = snapshot.data![index];
              return _buildBookingCard(booking);
            },
          );
        },
      ),
    );
  }
}
