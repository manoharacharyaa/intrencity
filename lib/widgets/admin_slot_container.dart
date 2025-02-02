import 'package:another_dashed_container/another_dashed_container.dart';
import 'package:flutter/material.dart';
import 'package:intrencity_provider/constants/colors.dart';
import 'package:provider/provider.dart';
import 'package:intrencity_provider/providers/admin_provider.dart';
import 'package:intrencity_provider/providers/booking_provider.dart';

class AdminSlotContainer extends StatefulWidget {
  const AdminSlotContainer({
    super.key,
    required this.slotNumber,
  });

  final int slotNumber;

  @override
  State<AdminSlotContainer> createState() => AdminSlotContainerState();
}

class AdminSlotContainerState extends State<AdminSlotContainer> {
  @override
  Widget build(BuildContext context) {
    var adminProvider = context.watch<AdminProvide>();
    var bookingProvider = context.watch<BookingProvider>();

    bool isStillParked = bookingProvider.getBookingStatus(widget.slotNumber);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: DashedContainer(
        borderRadius: 15,
        dashColor: isStillParked ? Colors.grey : primaryBlue,
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
                      onPressed: () {
                        adminProvider.toggleStillParked(
                          widget.slotNumber,
                          context,
                        );
                      },
                      minWidth: double.infinity,
                      color: isStillParked ? Colors.grey : primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        isStillParked ? 'Still Parked' : 'Park',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
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
