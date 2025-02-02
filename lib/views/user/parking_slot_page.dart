import 'package:flutter/material.dart';
import 'package:intrencity_provider/constants/colors.dart';
import 'package:intrencity_provider/widgets/booking_slot_container.dart';

class ParkingSlotPage extends StatelessWidget {
  const ParkingSlotPage({
    super.key,
    this.noOfSlots,
    this.startDate,
    this.endDate,
  });
  final int? noOfSlots;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Parking Slots',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            const Center(
              child: VerticalDivider(
                indent: 20,
                endIndent: 20,
                color: primaryBlueTransparent,
              ),
            ),
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 5 / 5,
              ),
              itemCount: noOfSlots,
              itemBuilder: (context, index) {
                return BookingSlotContainer(
                  slotNumber: index + 1,
                  startDate: startDate,
                  endDate: endDate,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
