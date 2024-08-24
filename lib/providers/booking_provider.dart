import 'package:flutter/material.dart';

class BookingProvider extends ChangeNotifier {
  Map<int, Duration> slotDuration = {};
  Map<int, bool> isBooked = {};

  Duration getBookingDuration(int slotNumber) {
    return slotDuration[slotNumber] ?? Duration.zero;
  }

  bool getBookingStatus(int slotNumber) {
    return isBooked[slotNumber] ?? false;
  }

  void bookSlot(int slotNumber, Duration duration) {
    isBooked[slotNumber] = true;

    slotDuration[slotNumber] = duration;
    _startTimer(slotNumber, duration);
    notifyListeners();
  }

  void _startTimer(int slotNumber, Duration duration) {
    Future.delayed(duration, () {
      isBooked[slotNumber] = false;
      slotDuration[slotNumber] = Duration.zero;
      notifyListeners();
    });
  }
}
