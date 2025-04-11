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
  Future<List<ParkingSpacePostModel>> fetchMySpaces() async {
    try {
      final currentUid = FirebaseAuth.instance.currentUser!.uid;
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('spaces')
          .where('uid', isEqualTo: currentUid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        List<ParkingSpacePostModel> spaces = List.from(snapshot.docs)
            .map(
              (space) => ParkingSpacePostModel.fromJson(
                space.data() as Map<String, dynamic>,
              ),
            )
            .toList();
        print(spaces.length);
        return spaces;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('fetchMySpaces() $e');
      return [];
    }
  }

  Future<List<BookingWithUser>> fetchParkingBookings(String spaceId) async {
    List<Booking> bookingsList = [];
    List<BookingWithUser> bookingWithUsers = [];
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('spaces')
          .where('docId', isEqualTo: spaceId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          if (data.containsKey('bookings')) {
            List<dynamic> bookings = data['bookings'];
            for (var booking in bookings) {
              if (booking['is_approved'] == false &&
                  booking['is_rejected'] == false) {
                Booking bookingObj = Booking.fromJson(booking);

                bookingsList.add(bookingObj);

                DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
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
              }
            }
          }
        }
        return bookingWithUsers;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching bookings with users: $e');
      return [];
    }
  }

  Future<void> confirmBooking(String bookingId, String docId) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('spaces')
          .doc(docId)
          .get();

      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

        if (data.containsKey('bookings')) {
          List<dynamic> bookings = (data['bookings'] as List<dynamic>);
          debugPrint('Booking ID to update: $bookingId');

          int bookingIndex = bookings.indexWhere(
              (booking) => booking['booking_id'].toString() == bookingId);

          if (bookingIndex != -1) {
            bookings[bookingIndex]['is_approved'] = true;
            await FirebaseFirestore.instance
                .collection('spaces')
                .doc(docId)
                .update({'bookings': bookings});
          }
        }
      }
    } catch (e) {
      debugPrint('Error in confirmBooking(): $e');
    }
  }

  Future<void> rejectBooking(String bookingId, String docId) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('spaces')
          .doc(docId)
          .get();

      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

        if (data.containsKey('bookings')) {
          List<dynamic> bookings = (data['bookings'] as List<dynamic>);
          print('Booking ID to update: $bookingId');

          int bookingIndex = bookings.indexWhere(
              (booking) => booking['booking_id'].toString() == bookingId);

          if (bookingIndex != -1) {
            bookings[bookingIndex]['is_rejected'] = true;
            await FirebaseFirestore.instance
                .collection('spaces')
                .doc(docId)
                .update({'bookings': bookings});
          }
        }
      }
    } catch (e) {
      debugPrint('Error in confirmBooking(): $e');
    }
  }

  Future<List<BookingWithUser>> fetchConfirmedBookings(String docId) async {
    List<Booking> bookingsList = [];
    List<BookingWithUser> bookingWithUsers = [];
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('spaces')
          .doc(docId)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        if (data.containsKey('bookings')) {
          for (var booking in data['bookings']) {
            if (booking['is_approved'] == true &&
                booking['is_rejected'] == false) {
              Booking bookingObj = Booking.fromJson(booking);
              bookingsList.add(bookingObj);

              DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(bookingObj.uid)
                  .get();

              if (userSnapshot.exists) {
                UserProfileModel user = UserProfileModel.fromJson(
                  userSnapshot.data() as Map<String, dynamic>,
                );
                bookingWithUsers.add(
                  BookingWithUser(booking: bookingObj, user: user),
                );
              }
            }
          }
          return bookingWithUsers;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error getConfirmedBookings(String docId)');
      return [];
    }
  }
}
