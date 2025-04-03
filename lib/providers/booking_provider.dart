import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:intrencity/models/parking_space_post_model.dart';
import 'package:intrencity/models/user_profile_model.dart';

class BookingProvider extends ChangeNotifier {
  BookingProvider() {
    _getMyBookedSpace();
  }

  final _uid = FirebaseAuth.instance.currentUser!.uid;
  List<Booking> _bookings = [];
  List<ParkingSpacePostModel> _parkings = [];
  List<UserProfileModel> _bookedUsers = [];
  bool _bookingExists = false;

  List<Booking> get bookings => _bookings;
  bool get bookingExists => _bookingExists;
  List<UserProfileModel> get bookedUsers => _bookedUsers;
  List<ParkingSpacePostModel> get parkings => _parkings;

  Future<void> _getMyBookedSpace() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('spaces').get();

    List<ParkingSpacePostModel> userBookedSpaces = [];

    if (snapshot.docs.isNotEmpty) {
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('bookings')) {
          List<dynamic> bookings = data['bookings'];
          bool hasBooking = bookings.any(
            (booking) => booking['uid'] == _uid,
          );

          if (hasBooking) {
            ParkingSpacePostModel space = ParkingSpacePostModel.fromJson(data);
            userBookedSpaces.add(space);
          }
        }
      }
    }
    _parkings = userBookedSpaces;
    notifyListeners();
  }

  Future<bool> doesBookingExist(String spaceId, int slotNumber) async {
    await _getMyBookedSpace();
    for (var booking in _bookings) {
      if (booking.spaceId == spaceId &&
          booking.slotNumber == slotNumber &&
          booking.uid == _uid) {
        return true;
      }
    }
    return false;
  }

  Future<void> _getSpaceData() async {
    final QuerySnapshot spanshot =
        await FirebaseFirestore.instance.collection('spaces').get();

    if (spanshot.docs.isNotEmpty) {}
  }
}
