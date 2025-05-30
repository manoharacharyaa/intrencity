import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingSpacePostModel {
  final String uid;
  final String? docId;
  final String spaceName;
  final String spaceLocation;
  final String spaceSlots;
  final String spacePrice;
  final String? selectedCurrency;
  final List<String> vehicleType;
  final List<String> aminitiesType;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? description;
  final List<String> spaceThumbnail;
  final List<Booking> bookings;
  final bool? isBlacklisted;
  final String? ownerName;

  ParkingSpacePostModel({
    required this.uid,
    this.docId,
    required this.spaceName,
    required this.spaceLocation,
    required this.spaceSlots,
    required this.spacePrice,
    this.selectedCurrency,
    required this.vehicleType,
    required this.aminitiesType,
    this.startDate,
    this.endDate,
    this.description,
    required this.spaceThumbnail,
    this.bookings = const [],
    this.isBlacklisted,
    this.ownerName,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'docId': docId,
      'spaceName': spaceName,
      'spaceLocation': spaceLocation,
      'spaceSlots': spaceSlots,
      'spacePrice': spacePrice,
      'selectedCurrency': selectedCurrency,
      'vehicleType': vehicleType,
      'aminitiesType': aminitiesType,
      'spaceThumbnail': spaceThumbnail,
      'startDate': startDate,
      'endDate': endDate,
      'description': description,
      'bookings': bookings?.map((booking) => booking.toJson()).toList(),
      'isBlacklisted': isBlacklisted,
      'ownerName': ownerName,
    };
  }

  factory ParkingSpacePostModel.fromJson(Map<String, dynamic> json) {
    return ParkingSpacePostModel(
      uid: json['uid'] ?? '',
      docId: json['docId'],
      spaceName: json['spaceName'] ?? '',
      spaceLocation: json['spaceLocation'] ?? '',
      spaceSlots: json['spaceSlots']?.toString() ?? '',
      spacePrice: json['spacePrice']?.toString() ?? '',
      selectedCurrency: json['selectedCurrency'],
      vehicleType: json['vehicleType'] != null
          ? List<String>.from(json['vehicleType'].map((e) => e.toString()))
          : [],
      aminitiesType: json['aminitiesType'] != null
          ? List<String>.from(json['aminitiesType'].map((e) => e.toString()))
          : [],
      startDate: json['startDate'] != null
          ? (json['startDate'] is Timestamp
              ? (json['startDate'] as Timestamp).toDate()
              : DateTime.parse(json['startDate']))
          : null,
      endDate: json['endDate'] != null
          ? (json['endDate'] is Timestamp
              ? (json['endDate'] as Timestamp).toDate()
              : DateTime.parse(json['endDate']))
          : null,
      description: json['description'],
      spaceThumbnail: json['spaceThumbnail'] != null
          ? List<String>.from(json['spaceThumbnail'])
          : [],
      bookings: json['bookings'] != null
          ? List<Booking>.from(
              (json['bookings'] as List).map((e) => Booking.fromJson(e)))
          : [],
      isBlacklisted: json['isBlacklisted'] ?? false,
      ownerName: json['ownerName'],
    );
  }
}

class Booking {
  final bool isApproved;
  final bool isRejected;
  final bool isOtpVerified;
  final String uid;
  final String spaceId;
  final int slotNumber;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final DateTime bookingTime;
  final String bookingId;
  final int? otp;
  // Add new optional checkout fields
  final bool? isCheckedOut;
  final String? checkoutTime;
  final bool? earlyCheckout;

  Booking({
    this.isApproved = false,
    this.isRejected = false,
    this.isOtpVerified = false,
    required this.uid,
    required this.spaceId,
    required this.slotNumber,
    required this.startDateTime,
    required this.endDateTime,
    required this.bookingTime,
    required this.bookingId,
    this.otp,
    this.isCheckedOut,
    this.checkoutTime,
    this.earlyCheckout,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      isApproved: json['is_approved'] ?? false,
      isRejected: json['is_rejected'] ?? false,
      isOtpVerified: json['is_otp_verified'] ?? false,
      uid: json['uid'] ?? '',
      spaceId: json['space_id'] ?? '',
      slotNumber: json['slot_number'] ?? 0,
      startDateTime: (json['start_time'] as Timestamp).toDate(),
      endDateTime: (json['end_time'] as Timestamp).toDate(),
      bookingTime: (json['booking_time'] as Timestamp).toDate(),
      bookingId: json['booking_id'] ?? '',
      otp: json['otp'],
      isCheckedOut: json['is_checked_out'],
      checkoutTime: json['checkout_time'],
      earlyCheckout: json['early_checkout'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_approved': isApproved,
      'is_rejected': isRejected,
      'is_otp_verified': isOtpVerified,
      'uid': uid,
      'space_id': spaceId,
      'slot_number': slotNumber,
      'start_time': Timestamp.fromDate(startDateTime),
      'end_time': Timestamp.fromDate(endDateTime),
      'booking_time': Timestamp.fromDate(bookingTime),
      'booking_id': bookingId,
      'otp': otp,
      'is_checked_out': isCheckedOut,
      'checkout_time': checkoutTime,
      'early_checkout': earlyCheckout,
    };
  }

  Booking copyWith({
    bool? isApproved,
    bool? isRejected,
    bool? isOtpVerified,
    String? uid,
    String? spaceId,
    int? slotNumber,
    DateTime? startDateTime,
    DateTime? endDateTime,
    DateTime? bookingTime,
    String? bookingId,
    int? otp,
    bool? isCheckedOut,
    String? checkoutTime,
    bool? earlyCheckout,
  }) {
    return Booking(
      isApproved: isApproved ?? this.isApproved,
      isRejected: isRejected ?? this.isRejected,
      isOtpVerified: isOtpVerified ?? this.isOtpVerified,
      uid: uid ?? this.uid,
      spaceId: spaceId ?? this.spaceId,
      slotNumber: slotNumber ?? this.slotNumber,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      bookingTime: bookingTime ?? this.bookingTime,
      bookingId: bookingId ?? this.bookingId,
      otp: otp ?? this.otp,
      isCheckedOut: isCheckedOut ?? this.isCheckedOut,
      checkoutTime: checkoutTime ?? this.checkoutTime,
      earlyCheckout: earlyCheckout ?? this.earlyCheckout,
    );
  }
}
