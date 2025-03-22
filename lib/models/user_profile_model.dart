class UserProfileModel {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String? profilePic;

  UserProfileModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.profilePic,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePic': profilePic,
    };
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profilePic: json['profilePic'],
    );
  }
}
