import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intrencity/providers/admin/space_admin_services.dart';
import 'package:intrencity/providers/admin/space_admin_viewmodel.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/widgets/buttons/small_button.dart';
import 'package:intrencity/widgets/dialogs/confirmation_dialog.dart';
import 'package:intrencity/widgets/smooth_container.dart';
import 'package:provider/provider.dart';

class BookingsPage extends StatelessWidget {
  const BookingsPage({
    super.key,
    required this.spaceId,
    required this.docId,
  });

  final String spaceId;
  final String docId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: context
            .read<SpaceAdminViewmodel>()
            .getParkingBookingsStream(spaceId),
        builder: (context, snapshot) {
          final bookingWithUsers = snapshot.data ?? [];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          } else if (snapshot.data == null) {
            return const Center(child: Text('No Bookings Found'));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (bookingWithUsers.isEmpty) {
            return const Center(child: Text('There Are No Active Bookings'));
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: bookingWithUsers.length,
            itemBuilder: (context, index) {
              final bookingWithUser = bookingWithUsers[index];
              return BookingCard(
                bookingWithUser: bookingWithUser,
                docId: docId,
              );
            },
          );
        },
      ),
    );
  }
}

enum BookingPageType {
  pending,
  approved,
  rejected,
}

class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.bookingWithUser,
    required this.docId,
    this.pageType = BookingPageType.pending,
  });

  final BookingWithUser bookingWithUser;
  final String docId;
  final BookingPageType pageType;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SmoothContainer(
          height: 210,
          verticalPadding: 12,
          horizontalPadding: 10,
          color: const Color.fromARGB(255, 50, 50, 50),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                if (pageType == BookingPageType.pending) ...[
                  SmallButton(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => ConfirmationDialog(
                          title: 'Confirm Approval',
                          singleButtom: true,
                          buttonColor: greenAccent,
                          buttonLabel: 'Approve',
                          onTap: () async {
                            await context
                                .read<SpaceAdminViewmodel>()
                                .confirmBooking(
                                  bookingWithUser.booking.bookingId,
                                  docId,
                                );
                            if (context.mounted) {
                              context.pop();
                            }
                          },
                        ),
                      );
                    },
                    color: greenAccent,
                    label: 'Approve',
                  ),
                  SmallButton(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => ConfirmationDialog(
                          title: 'Confirm Rejection',
                          singleButtom: true,
                          buttonColor: redAccent,
                          buttonLabel: 'Reject',
                          onTap: () async {
                            await context
                                .read<SpaceAdminViewmodel>()
                                .rejectBooking(
                                  bookingWithUser.booking.bookingId,
                                  docId,
                                );
                            if (context.mounted) {
                              context.pop();
                            }
                          },
                        ),
                      );
                    },
                    color: redAccent,
                    label: 'Reject',
                  ),
                ],
                if (pageType == BookingPageType.approved) ...[
                  SmallButton(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => ConfirmationDialog(
                          title: 'Confirm Rejection',
                          singleButtom: true,
                          buttonColor: redAccent,
                          buttonLabel: 'Reject',
                          onTap: () async {
                            await context
                                .read<SpaceAdminViewmodel>()
                                .rejectBooking(
                                  bookingWithUser.booking.bookingId,
                                  docId,
                                );
                            if (context.mounted) {
                              context.pop();
                            }
                          },
                        ),
                      );
                    },
                    color: redAccent,
                    label: 'Reject',
                  ),
                ] else if (pageType == BookingPageType.rejected) ...[
                  SmallButton(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => ConfirmationDialog(
                          title: 'Confirm Approval',
                          singleButtom: true,
                          buttonColor: greenAccent,
                          buttonLabel: 'Approve',
                          onTap: () async {
                            await context
                                .read<SpaceAdminViewmodel>()
                                .confirmBooking(
                                  bookingWithUser.booking.bookingId,
                                  docId,
                                );
                            if (context.mounted) {
                              context.pop();
                            }
                          },
                        ),
                      );
                    },
                    color: greenAccent,
                    label: 'Approve',
                  ),
                ]
              ],
            ),
          ),
        ),
        SmoothContainer(
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
        ),
      ],
    );
  }
}
