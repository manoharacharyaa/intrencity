import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:intrencity/models/parking_space_post_model.dart';
import 'package:intrencity/models/user_profile_model.dart';

class SpaceWithUser {
  final ParkingSpacePostModel space;
  final UserProfileModel user;
  SpaceWithUser({
    required this.space,
    required this.user,
  });
}

class BookingProvider extends ChangeNotifier {
  BookingProvider() {
    _getMyBookedSpace();
  }

  final _uid = FirebaseAuth.instance.currentUser!.uid;
  final List<Booking> _bookings = [];
  List<ParkingSpacePostModel> _parkings = [];
  final List<UserProfileModel> _bookedUsers = [];
  final bool _bookingExists = false;
  List<SpaceWithUser> _bookingWithUsers = [];

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

  Stream<List<SpaceWithUser>> getMyBookingStream() {
    if (_uid.isEmpty) {
      debugPrint('UID is empty');
      return Stream.value([]);
    }

    return FirebaseFirestore.instance.collection('spaces').snapshots().asyncMap(
      (snapshots) async {
        _bookingWithUsers.clear();
        List<SpaceWithUser> spaceWithUsers = [];

        for (var doc in snapshots.docs) {
          var data = doc.data();

          if (data.containsKey('bookings')) {
            List<dynamic> bookings = data['bookings'];

            bool hasUserBooking = bookings.any(
              (booking) =>
                  booking['uid'] == _uid &&
                  booking['is_approved'] == true &&
                  booking['is_rejected'] == false,
            );

            if (hasUserBooking) {
              ParkingSpacePostModel space =
                  ParkingSpacePostModel.fromJson(data);

              try {
                DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(_uid)
                    .get();

                if (userSnapshot.exists) {
                  UserProfileModel user = UserProfileModel.fromJson(
                      userSnapshot.data() as Map<String, dynamic>);

                  spaceWithUsers.add(
                    SpaceWithUser(
                      space: space,
                      user: user,
                    ),
                  );
                  debugPrint('Added space with user: ${user.name}');
                }
              } catch (e) {
                debugPrint('Error fetching user: $e');
              }
            }
          }
        }

        debugPrint('Final spaces with users count: ${spaceWithUsers.length}');
        return spaceWithUsers;
      },
    );
  }

  Future<void> cancelBooking(String docId, String bookingId) async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('spaces').doc(docId).get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;

      if (data.containsKey('bookings')) {
        List<dynamic> bookings = data['bookings'];
        List<dynamic> updatedBookings = List.from(bookings);
        updatedBookings.removeWhere(
          (booking) => booking['booking_id'] == bookingId,
        );

        await FirebaseFirestore.instance
            .collection('spaces')
            .doc(docId)
            .update({'bookings': updatedBookings});
      }
    }
  }
}
