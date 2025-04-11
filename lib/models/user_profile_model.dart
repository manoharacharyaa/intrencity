import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  final String uid;
  final int role;
  final String name;
  final String email;
  final String phoneNumber;
  final String? profilePic;
  final bool? isApproved;
  final String? aadhaarUrl;
  final String? documentUrl;
  final DateTime? verificationSubmittedAt;
  final bool? isVerificationPending;

  UserProfileModel({
    required this.uid,
    this.role = 0,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.profilePic,
    this.isApproved = false,
    this.aadhaarUrl,
    this.documentUrl,
    this.verificationSubmittedAt,
    this.isVerificationPending,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'role': role,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePic': profilePic,
      'is_approved': isApproved,
      'aadhaarUrl': aadhaarUrl,
      'documentUrl': documentUrl,
      'verificationSubmittedAt': verificationSubmittedAt?.toIso8601String(),
      'isVerificationPending': isVerificationPending,
    };
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      uid: json['uid'] ?? '',
      role: json['role'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      profilePic: json['profilePic'],
      isApproved: json['is_approved'],
      aadhaarUrl: json['aadhaarUrl'],
      documentUrl: json['documentUrl'],
      verificationSubmittedAt: json['verificationSubmittedAt'] != null
          ? (json['verificationSubmittedAt'] as Timestamp).toDate()
          : null,
      isVerificationPending: json['isVerificationPending'],
    );
  }

  UserProfileModel copyWith({
    String? uid,
    int? role,
    String? name,
    String? email,
    String? phoneNumber,
    String? profilePic,
    bool? isApproved,
    String? aadhaarUrl,
    String? documentUrl,
    DateTime? verificationSubmittedAt,
    bool? isVerificationPending,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      role: role ?? this.role,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePic: profilePic ?? this.profilePic,
      isApproved: isApproved ?? this.isApproved,
      aadhaarUrl: aadhaarUrl ?? this.aadhaarUrl,
      documentUrl: documentUrl ?? this.documentUrl,
      verificationSubmittedAt:
          verificationSubmittedAt ?? this.verificationSubmittedAt,
      isVerificationPending:
          isVerificationPending ?? this.isVerificationPending,
    );
  }
}
