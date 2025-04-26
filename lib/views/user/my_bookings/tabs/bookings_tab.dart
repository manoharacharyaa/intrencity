import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intrencity/providers/booking_provider.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/utils/smooth_corners/smooth_border_radius.dart';
import 'package:intrencity/utils/smooth_corners/smooth_radius.dart';
import 'package:intrencity/widgets/dialogs/confirmation_dialog.dart';
import 'package:intrencity/widgets/smooth_container.dart';
import 'package:provider/provider.dart';

class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key});

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    return Scaffold(
      body: StreamBuilder<List<SpaceWithUser>>(
        stream: provider.getMyBookedSpace(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          } else {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (snapshot.data == null || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('You Have No Bookings'),
              );
            }
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final spaceWithUser = snapshot.data![index];
              final space = spaceWithUser.space;
              final booking = spaceWithUser.booking;

              if (booking == null) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SmoothContainer(
                      onTap: () => context.push(
                        '/parking-space-details',
                        extra: {
                          'spaceDetails': space,
                          'viewedByCurrentUser': true,
                        },
                      ),
                      width: double.infinity,
                      radius: SmoothBorderRadius(
                        cornerRadius: 14,
                        cornerSmoothing: 0.8,
                      ).copyWith(
                        bottomRight: const SmoothRadius(
                          cornerRadius: 0,
                          cornerSmoothing: 0,
                        ),
                      ),
                      height: 100,
                      contentPadding: const EdgeInsets.all(10),
                      color: textFieldGrey,
                      child: Row(
                        spacing: 12,
                        children: [
                          SmoothContainer(
                            height: 80,
                            width: 80,
                            cornerRadius: 10,
                            child: Image.network(
                              space.spaceThumbnail[0],
                              fit: BoxFit.cover,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Space: ${space.spaceName}',
                                style: Theme.of(context).textTheme.titleSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Slot Number: ${booking.slotNumber}',
                                style: Theme.of(context).textTheme.titleSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Booking ID: ${booking.bookingId}',
                                style: Theme.of(context).textTheme.titleSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SmoothContainer(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => ConfirmationDialog(
                            singleButtom: true,
                            title: 'Confirm Cancelation',
                            buttonLabel: 'Cancel',
                            buttonColor: redAccent,
                            onTap: () async {
                              await context
                                  .read<BookingProvider>()
                                  .cancelBooking(
                                    space.docId!,
                                    booking.bookingId,
                                  );
                              if (context.mounted) {
                                context.pop();
                              }
                            },
                          ),
                        );
                      },
                      height: 38,
                      width: 100,
                      color: redAccent,
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                      radius: SmoothBorderRadius(
                        cornerRadius: 8,
                        cornerSmoothing: 0.8,
                      ).copyWith(
                        topRight: const SmoothRadius(
                          cornerRadius: 0,
                          cornerSmoothing: 0,
                        ),
                        topLeft: const SmoothRadius(
                          cornerRadius: 0,
                          cornerSmoothing: 0,
                        ),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text(
                                'Cancel',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const Spacer(),
                              const Icon(Icons.cancel_outlined),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
