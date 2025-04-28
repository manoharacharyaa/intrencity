import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/widgets/smooth_container.dart';
import 'package:intrencity/widgets/row_text_tile_widget.dart';

class BookingHistoryPage extends StatelessWidget {
  const BookingHistoryPage({super.key});

  Stream<List<Map<String, dynamic>>> getBookingHistory() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('checkouts')
        .where('user_id', isEqualTo: uid)
        .orderBy('checkout_time', descending: true)
        .snapshots()
        .asyncMap((checkouts) async {
      List<Map<String, dynamic>> history = [];

      for (var checkout in checkouts.docs) {
        final checkoutData = checkout.data();

        try {
          // Get space details
          final spaceDoc = await FirebaseFirestore.instance
              .collection('spaces')
              .doc(checkoutData['space_id'])
              .get();

          if (!spaceDoc.exists) continue;

          final spaceData = spaceDoc.data()!;

          // Calculate total price including extensions and fines
          double basePrice = checkoutData['base_amount'] ?? 0.0;
          double fineAmount = checkoutData['fine_amount'] ?? 0.0;
          int overtimeDuration = checkoutData['overtime_duration'] ?? 0;

          // Add to history list
          history.add({
            'booking_id': checkoutData['booking_id'],
            'space_name': spaceData['spaceName'],
            'space_location': spaceData['spaceLocation'],
            'slot_number': checkoutData['slot_number'],
            'checkout_time': checkoutData['checkout_time'],
            'is_late_checkout': checkoutData['is_late_checkout'] ?? false,
            'overtime_duration': overtimeDuration,
            'base_price': basePrice,
            'fine_amount': fineAmount,
            'total_price':
                checkoutData['total_amount'] ?? (basePrice + fineAmount),
            'currency': checkoutData['currency'] ??
                spaceData['selectedCurrency'] ??
                '\$',
            'start_time': checkoutData['start_time'],
            'end_time': checkoutData['end_time'],
          });
        } catch (e) {
          debugPrint('Error processing checkout: $e');
          continue;
        }
      }

      return history;
    });
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getBookingHistory(),
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
              final isLateCheckout = booking['is_late_checkout'] ?? false;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RowTextTile(
                        label: 'Space Name: ',
                        text: booking['space_name'] ?? 'N/A',
                      ),
                      RowTextTile(
                        label: 'Location: ',
                        text: booking['space_location'] ?? 'N/A',
                      ),
                      RowTextTile(
                        label: 'Slot Number: ',
                        text: booking['slot_number']?.toString() ?? 'N/A',
                      ),
                      RowTextTile(
                        label: 'Start Time: ',
                        text: DateFormat('MMM dd, yyyy hh:mm a').format(
                          (booking['start_time'] as Timestamp).toDate(),
                        ),
                      ),
                      RowTextTile(
                        label: 'End Time: ',
                        text: DateFormat('MMM dd, yyyy hh:mm a').format(
                          (booking['end_time'] as Timestamp).toDate(),
                        ),
                      ),
                      RowTextTile(
                        label: 'Checkout Time: ',
                        text: DateFormat('MMM dd, yyyy hh:mm a').format(
                          (booking['checkout_time'] as Timestamp).toDate(),
                        ),
                      ),
                      RowTextTile(
                        label: 'Base Price: ',
                        text: '${booking['currency']}${booking['base_price']}',
                      ),
                      if (isLateCheckout) ...[
                        RowTextTile(
                          label: 'Overtime Duration: ',
                          text: '${booking['overtime_duration']} minutes',
                        ),
                        RowTextTile(
                          label: 'Fine Amount: ',
                          text:
                              '${booking['currency']}${booking['fine_amount']}',
                        ),
                      ],
                      RowTextTile(
                        label: 'Total Amount: ',
                        text: '${booking['currency']}${booking['total_price']}',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
