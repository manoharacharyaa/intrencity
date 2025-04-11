import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intrencity/providers/admin/space_admin_viewmodel.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/widgets/smooth_container.dart';
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
              return SmoothContainer(
                height: 160,
                width: double.infinity,
                verticalPadding: 12,
                horizontalPadding: 10,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 5,
                ),
                color: textFieldGrey,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.cyanAccent,
                          radius: 45,
                          backgroundImage: NetworkImage(
                            bookingWithUser.user.profilePic ?? '',
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 10,
                          children: [
                            Text(
                              'Name: ${bookingWithUser.user.name}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              'Phone: ${bookingWithUser.user.phoneNumber}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              'Email: ${bookingWithUser.user.email}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              'Booking Id: ${bookingWithUser.booking.bookingId}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              'Slot Number: ${bookingWithUser.booking.slotNumber}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              'Start Time: ${bookingWithUser.booking.startDateTime}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              'End Time: ${bookingWithUser.booking.endDateTime}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
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
