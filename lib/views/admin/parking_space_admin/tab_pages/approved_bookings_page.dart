import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intrencity/providers/admin/space_admin_viewmodel.dart';
import 'package:intrencity/views/admin/parking_space_admin/tab_pages/bookings_page.dart';
import 'package:provider/provider.dart';

class ApprovedBookingsPage extends StatelessWidget {
  const ApprovedBookingsPage({
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
            .getConfirmedBookingsStream(spaceId),
        builder: (context, snapshot) {
          final approvedBookings = snapshot.data ?? [];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          } else if (snapshot.data == null) {
            return const Center(child: Text('No Approved Bookings'));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (approvedBookings.isEmpty) {
            return const Center(child: Text('There Are No Active Bookings'));
          }

          return ListView.builder(
            itemCount: approvedBookings.length,
            itemBuilder: (context, index) {
              final bookingWithUser = approvedBookings[index];
              return BookingCard(
                pageType: BookingPageType.approved,
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
