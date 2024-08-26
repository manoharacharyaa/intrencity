import 'dart:async';
import 'package:flutter/material.dart';

class BookingProvider extends ChangeNotifier {
  Map<int, bool> isBooked = {};
  Map<int, Timer?> bookingTimers = {};

  bool getBookingStatus(int slotNumber) {
    return isBooked[slotNumber] ?? false;
  }

  void bookSlot(int slotNumber, DateTime startTime, Duration duration) {
    final now = DateTime.now();

    if (startTime.isAfter(now)) {
      // Set a timer to start booking at the future startTime
      final durationUntilStart = startTime.difference(now);

      bookingTimers[slotNumber]?.cancel();
      bookingTimers[slotNumber] = Timer(durationUntilStart, () {
        _startBooking(slotNumber, duration);
      });
    } else {
      // If start time is now or in the past, start booking immediately
      _startBooking(slotNumber, duration);
    }
    notifyListeners();
  }

  void _startBooking(int slotNumber, Duration duration) {
    isBooked[slotNumber] = true;
    notifyListeners();

    // Set a timer to unbook the slot after the duration
    bookingTimers[slotNumber]?.cancel();
    bookingTimers[slotNumber] = Timer(duration, () {
      unbookSlot(slotNumber);
    });
  }

  void unbookSlot(int slotNumber) {
    isBooked[slotNumber] = false;
    bookingTimers[slotNumber]?.cancel();
    bookingTimers.remove(slotNumber);
    notifyListeners();
  }

  void markStillParked(int slotNumber) {
    if (isBooked.containsKey(slotNumber)) {
      isBooked[slotNumber] = true;
      notifyListeners();
    }
  }

  void updateSlotStatus(int slotNumber, bool status) {
    isBooked[slotNumber] = status;
    notifyListeners();
  }
}
