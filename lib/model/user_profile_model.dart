class UserProfile {
  final String name;
  final String email;
  final String password;
  final String phoneNumber;
  final String? profilePic;

  UserProfile({
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    this.profilePic,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'profilePic': profilePic,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      email: json['email'],
      password: json['password'],
      phoneNumber: json['phoneNumber'],
      profilePic: json['profilePic'],
    );
  }
}
