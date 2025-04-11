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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final approvedBookings = snapshot.data ?? [];

          if (approvedBookings.isEmpty) {
            return const Center(child: Text('No Bookings Found'));
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
