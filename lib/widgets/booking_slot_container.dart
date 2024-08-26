import 'package:another_dashed_container/another_dashed_container.dart';
import 'package:flutter/material.dart';
import 'package:intrencity_provider/constants/colors.dart';
import 'package:intrencity_provider/pages/booking_page.dart';
import 'package:intrencity_provider/providers/booking_provider.dart';
import 'package:provider/provider.dart';

class BookingSlotContainer extends StatefulWidget {
  const BookingSlotContainer({
    super.key,
    required this.slotNumber,
  });

  final int slotNumber;

  @override
  State<BookingSlotContainer> createState() => _BookingSlotContainerState();
}

class _BookingSlotContainerState extends State<BookingSlotContainer> {
  @override
  Widget build(BuildContext context) {
    final isBooked =
        context.watch<BookingProvider>().getBookingStatus(widget.slotNumber);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: DashedContainer(
        borderRadius: 15,
        dashColor: isBooked ? Colors.grey : primaryBlue,
        strokeWidth: 2,
        child: Container(
          height: 140,
          decoration: const BoxDecoration(
            color: Color.fromARGB(52, 68, 137, 255),
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      'Slot ${widget.slotNumber}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    child: MaterialButton(
                      onPressed: isBooked
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookingPage(
                                    slotNumber: widget.slotNumber,
                                  ),
                                ),
                              );
                            },
                      minWidth: double.infinity,
                      color: isBooked ? Colors.grey : primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        isBooked ? 'Booked' : 'Book',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
