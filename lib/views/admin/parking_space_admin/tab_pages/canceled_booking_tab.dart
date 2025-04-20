import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intrencity/providers/admin/space_admin_viewmodel.dart';
import 'package:intrencity/views/admin/parking_space_admin/tab_pages/bookings_tab.dart';
import 'package:provider/provider.dart';

class CanceledBookingTab extends StatelessWidget {
  const CanceledBookingTab({
    super.key,
    required this.spaceId,
  });

  final String spaceId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: context
            .read<SpaceAdminViewmodel>()
            .getCancledBookingsStream(spaceId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            const Center(child: CupertinoActivityIndicator());
          }
          if (snapshot.hasError) {
            Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          final cancledBookings = snapshot.data ?? [];
          if (cancledBookings.isEmpty) {
            return const Center(child: Text('No Rejected Bookings Found'));
          }
          return ListView.builder(
            itemCount: cancledBookings.length,
            itemBuilder: (context, index) {
              final bookingWithUser = cancledBookings[index];
              return BookingCard(
                pageType: BookingPageType.rejected,
                bookingWithUser: bookingWithUser,
                docId: spaceId,
              );
            },
          );
        },
      ),
    );
  }
}
