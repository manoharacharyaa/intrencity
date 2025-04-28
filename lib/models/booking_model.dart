import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String bookingId;
  final String uid;
  final String spaceId;
  final int slotNumber;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final bool isApproved;
  final bool isRejected;
  final bool? isCheckedOut;
  final String? otp;
  final bool? isOtpVerified;

  Booking({
    required this.bookingId,
    required this.uid,
    required this.spaceId,
    required this.slotNumber,
    required this.startDateTime,
    required this.endDateTime,
    required this.isApproved,
    required this.isRejected,
    this.isCheckedOut,
    this.otp,
    this.isOtpVerified,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      bookingId: json['booking_id'],
      uid: json['uid'],
      spaceId: json['space_id'],
      slotNumber: json['slot_number'],
      startDateTime: (json['start_datetime'] as Timestamp).toDate(),
      endDateTime: (json['end_datetime'] as Timestamp).toDate(),
      isApproved: json['is_approved'] ?? false,
      isRejected: json['is_rejected'] ?? false,
      isCheckedOut: json['is_checked_out'], // Add this
      otp: json['otp'],
      isOtpVerified: json['is_otp_verified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'uid': uid,
      'space_id': spaceId,
      'slot_number': slotNumber,
      'start_datetime': startDateTime,
      'end_datetime': endDateTime,
      'is_approved': isApproved,
      'is_rejected': isRejected,
      'is_checked_out': isCheckedOut, // Add this
      'otp': otp,
      'is_otp_verified': isOtpVerified,
    };
  }
}
