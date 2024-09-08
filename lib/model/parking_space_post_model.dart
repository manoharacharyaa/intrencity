import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingSpacePostModel {
  final String uid;
  final String docId;
  final String spaceName;
  final String spaceLocation;
  final String spaceSlots;
  final String spacePrice;
  final List<String> vehicleType;
  final List<String> aminitiesType;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? description;
  final List<String> spaceThumbnail;

  ParkingSpacePostModel({
    required this.uid,
    required this.docId,
    required this.spaceName,
    required this.spaceLocation,
    required this.spaceSlots,
    required this.spacePrice,
    required this.vehicleType,
    required this.aminitiesType,
    this.startDate,
    this.endDate,
    this.description,
    required this.spaceThumbnail,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'docId': docId,
      'spaceName': spaceName,
      'spaceLocation': spaceLocation,
      'spaceSlots': spaceSlots,
      'spacePrice': spacePrice,
      'vehicleType': vehicleType,
      'aminitiesType': aminitiesType,
      'spaceThumbnail': spaceThumbnail,
      'startDate': startDate,
      'endDate': endDate,
      'description': description,
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
    );
  }
}
