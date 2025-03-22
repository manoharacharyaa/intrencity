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
  final List<Booking>? bookings;

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
    this.bookings,
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
      'bookings': bookings,
    };
  }

  factory ParkingSpacePostModel.fromJson(Map<String, dynamic> json) {
    return ParkingSpacePostModel(
      uid: json['uid'],
      docId: json['docId'],
      spaceName: json['spaceName'],
      spaceLocation: json['spaceLocation'],
      spaceSlots: json['spaceSlots'],
      spacePrice: json['spacePrice'],
      selectedCurrency: json['selectedCurrency'],
      vehicleType: List<String>.from(
        json['vehicleType'].map((e) => e.toString()),
      ),
      aminitiesType: List<String>.from(
        json['aminitiesType'].map((e) => e.toString()),
      ),
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      description: json['description'],
      spaceThumbnail: List<String>.from(json['spaceThumbnail']),
      bookings: json['bookings'] == null
          ? []
          : List<Booking>.from(
              json['bookings'].map((e) => Booking.fromJson(e)),
            ),
    );
  }
}

class Booking {
  final bool isApproved;
  final String uid;
  final String spaceId;
  final int slotNumber;
  final String startDateTime;
  final String endDateTime;

  Booking({
    this.isApproved = false,
    required this.uid,
    required this.spaceId,
    required this.slotNumber,
    required this.startDateTime,
    required this.endDateTime,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      isApproved: json['is_approved'],
      uid: json['uid'],
      spaceId: json['space_id'],
      slotNumber: json['slot_number'],
      startDateTime: json['start_time'].toString(),
      endDateTime: json['end_time'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_approved': isApproved,
      'uid': uid,
      'space_id': spaceId,
      'slot_number': slotNumber,
      'start_time': startDateTime,
      'end_time': endDateTime,
    };
  }
}
