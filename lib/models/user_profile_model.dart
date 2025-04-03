class UserProfileModel {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String? profilePic;
  final bool? isApproved;

  UserProfileModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.profilePic,
    this.isApproved = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePic': profilePic,
      'is_approved': isApproved,
    };
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profilePic: json['profilePic'],
      isApproved: json['is_approved'],
    );
  }
}
