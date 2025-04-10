import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intrencity/providers/admin/space_admin_viewmodel.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/widgets/buttons/small_button.dart';
import 'package:intrencity/widgets/dialogs/confirmation_dialog.dart';
import 'package:intrencity/widgets/smooth_container.dart';
import 'package:provider/provider.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({
    super.key,
    required this.spaceId,
    required this.docId,
  });

  final String spaceId;
  final String docId;

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  @override
  void initState() {
    Future.microtask(() {
      context.read<SpaceAdminViewmodel>().getParkingBookings(widget.spaceId);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SpaceAdminViewmodel>();
    final bookingWithUsers =
        context.watch<SpaceAdminViewmodel>().mySpaceBookings;
    return Scaffold(
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: bookingWithUsers.length,
        itemBuilder: (context, index) {
          final bookingWithUser = bookingWithUsers[index];
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
                      SmallButton(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => ConfirmationDialog(
                              title: 'Confirm Approval',
                              singleButtom: true,
                              buttonColor: greenAccent,
                              buttonLabel: 'Approve',
                              onTap: () {
                                provider
                                    .confirmBooking(
                                  bookingWithUser.booking.bookingId,
                                  widget.docId,
                                )
                                    .then((_) {
                                  if (context.mounted) {
                                    context.pop();
                                  }
                                });
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
                              onTap: () {
                                provider
                                    .rejectBooking(
                                  bookingWithUser.booking.bookingId,
                                  widget.docId,
                                )
                                    .then((_) {
                                  if (context.mounted) {
                                    context.pop();
                                  }
                                });
                              },
                            ),
                          );
                        },
                        color: redAccent,
                        label: 'Reject',
                      ),
                    ],
                  ),
                ),
              ),
              SmoothContainer(
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
              ),
            ],
          );
        },
      ),
    );
  }
}
