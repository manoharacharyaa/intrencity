import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'booking_provider.dart';

class AdminProvide extends ChangeNotifier {
  void toggleStillParked(int slotNumber, BuildContext context) {
    var bookingProvider = context.read<BookingProvider>();
    bool currentStatus = bookingProvider.getBookingStatus(slotNumber);
    bookingProvider.updateSlotStatus(slotNumber, !currentStatus);
  }
}
