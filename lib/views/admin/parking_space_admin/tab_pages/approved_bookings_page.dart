import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intrencity/providers/admin/space_admin_viewmodel.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/widgets/smooth_container.dart';
import 'package:provider/provider.dart';

class ApprovedBookingsPage extends StatefulWidget {
  const ApprovedBookingsPage({
    super.key,
    required this.spaceId,
  });

  final String spaceId;

  @override
  State<ApprovedBookingsPage> createState() => _ApprovedBookingsPageState();
}

class _ApprovedBookingsPageState extends State<ApprovedBookingsPage> {
  @override
  void initState() {
    context.read<SpaceAdminViewmodel>().getConfirmedBookings(widget.spaceId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SpaceAdminViewmodel>();
    return Scaffold(
      body: provider.isLoading == true
          ? const Center(child: CupertinoActivityIndicator())
          : provider.approvedBookings.isEmpty
              ? const Center(child: Text('No Bookings Found'))
              : ListView.builder(
                  itemCount: provider.approvedBookings.length,
                  itemBuilder: (context, index) {
                    final bookingWithUser = provider.approvedBookings[index];
                    return SmoothContainer(
                      height: 160,
                      width: double.infinity,
                      verticalPadding: 12,
                      horizontalPadding: 10,
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
                            Column(
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
                                  'Booking Id: ${bookingWithUser.booking.slotNumber}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
