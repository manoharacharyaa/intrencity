class ParkingSpacePost {
  final String spaceName;
  final String spacePrice;
  final String spaceLocation;
  final List<String> spaceThumbnail;

  ParkingSpacePost({
    required this.spaceName,
    required this.spacePrice,
    required this.spaceLocation,
    required this.spaceThumbnail,
  });

  Map<String, dynamic> toJson() {
    return {
      'spaceName': spaceName,
      'spacePrice': spacePrice,
      'spaceLocation': spaceLocation,
      'spaceThumbnail': spaceThumbnail,
    };
  }

  factory ParkingSpacePost.fromJson(Map<String, dynamic> json) {
    return ParkingSpacePost(
      spaceName: json['spaceName'],
      spacePrice: json['spacePrice'],
      spaceLocation: json['spaceLocation'],
      spaceThumbnail: List<String>.from(json['spaceThumbnail']),
    );
  }
}
