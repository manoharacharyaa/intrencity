import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:intrencity/models/parking_space_post_model.dart';
import 'package:intrencity/models/user_profile_model.dart';

class BookingWithUser {
  final Booking booking;
  final UserProfileModel user;

  BookingWithUser({
    required this.booking,
    required this.user,
  });
}

class SpaceAdminServices {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Stream<List<ParkingSpacePostModel>> getMySpacesStream() {
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null) return Stream.value([]);

    return _firestore
        .collection('spaces')
        .where('uid', isEqualTo: currentUid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ParkingSpacePostModel.fromJson(
                doc.data() as Map<String, dynamic>,
              ))
          .toList();
    });
  }

  Stream<List<BookingWithUser>> getParkingBookingsStream(String spaceId) {
    return _firestore
        .collection('spaces')
        .where('docId', isEqualTo: spaceId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<BookingWithUser> bookingWithUsers = [];

      for (var doc in snapshot.docs) {
        var data = doc.data();
        if (data.containsKey('bookings')) {
          List<dynamic> bookings = data['bookings'];
          for (var booking in bookings) {
            if (booking['is_approved'] == false &&
                booking['is_rejected'] == false) {
              Booking bookingObj = Booking.fromJson(booking);

              try {
                DocumentSnapshot userSnapshot = await _firestore
                    .collection('users')
                    .doc(bookingObj.uid)
                    .get();

                if (userSnapshot.exists) {
                  UserProfileModel user = UserProfileModel.fromJson(
                    userSnapshot.data() as Map<String, dynamic>,
                  );

                  bookingWithUsers.add(
                    BookingWithUser(
                      booking: bookingObj,
                      user: user,
                    ),
                  );
                }
              } catch (e) {
                debugPrint('Error fetching user: $e');
              }
            }
          }
        }
      }
      return bookingWithUsers;
    });
  }

  Stream<List<BookingWithUser>> getConfirmedBookingsStream(String docId) {
    return _firestore
        .collection('spaces')
        .doc(docId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<BookingWithUser> bookingWithUsers = [];

      if (!snapshot.exists) return bookingWithUsers;

      final data = snapshot.data() as Map<String, dynamic>;
      if (!data.containsKey('bookings')) return bookingWithUsers;

      for (var booking in data['bookings']) {
        if (booking['is_approved'] == true && booking['is_rejected'] == false) {
          Booking bookingObj = Booking.fromJson(booking);

          try {
            DocumentSnapshot userSnapshot =
                await _firestore.collection('users').doc(bookingObj.uid).get();

            if (userSnapshot.exists) {
              UserProfileModel user = UserProfileModel.fromJson(
                userSnapshot.data() as Map<String, dynamic>,
              );
              bookingWithUsers.add(
                BookingWithUser(booking: bookingObj, user: user),
              );
            }
          } catch (e) {
            debugPrint('Error fetching user: $e');
          }
        }
      }
      return bookingWithUsers;
    });
  }

  Future<void> confirmBooking(String bookingId, String docId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot docSnapshot =
            await transaction.get(_firestore.collection('spaces').doc(docId));

        if (!docSnapshot.exists) return;

        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        if (!data.containsKey('bookings')) return;

        List<dynamic> bookings = List.from(data['bookings']);
        int bookingIndex = bookings.indexWhere(
            (booking) => booking['booking_id'].toString() == bookingId);

        if (bookingIndex != -1) {
          bookings[bookingIndex]['is_approved'] = true;
          transaction.update(_firestore.collection('spaces').doc(docId),
              {'bookings': bookings});
        }
      });
    } catch (e) {
      debugPrint('Error in confirmBooking(): $e');
      rethrow;
    }
  }

  Future<void> rejectBooking(String bookingId, String docId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot docSnapshot =
            await transaction.get(_firestore.collection('spaces').doc(docId));

        if (!docSnapshot.exists) return;

        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        if (!data.containsKey('bookings')) return;

        List<dynamic> bookings = List.from(data['bookings']);
        int bookingIndex = bookings.indexWhere(
            (booking) => booking['booking_id'].toString() == bookingId);

        if (bookingIndex != -1) {
          bookings[bookingIndex]['is_rejected'] = true;
          transaction.update(_firestore.collection('spaces').doc(docId),
              {'bookings': bookings});
        }
      });
    } catch (e) {
      debugPrint('Error in rejectBooking(): $e');
      rethrow;
    }
  }
}
