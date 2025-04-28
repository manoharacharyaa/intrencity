import 'package:cloud_firestore/cloud_firestore.dart';

class CheckoutModel {
  final DateTime startTime;
  final DateTime endTime;
  final DateTime actualCheckoutTime;
  final double baseAmount;
  final String bookingId;
  final DateTime checkoutTime;
  final String currency;
  final double? fineAmount;
  final bool isEarlyCheckout;
  final bool isLateCheckout;
  final int? overtimeDuration;
  final int slotNumber;
  final String spaceId;
  final String spaceName;
  final String? spaceLocation;
  final double totalAmount;
  final String userId;

  CheckoutModel({
    required this.startTime,
    required this.endTime,
    required this.actualCheckoutTime,
    required this.baseAmount,
    required this.bookingId,
    required this.checkoutTime,
    required this.currency,
    this.fineAmount,
    required this.isEarlyCheckout,
    required this.isLateCheckout,
    this.overtimeDuration,
    required this.slotNumber,
    required this.spaceId,
    required this.spaceName,
    this.spaceLocation,
    required this.totalAmount,
    required this.userId,
  });

  factory CheckoutModel.fromJson(Map<String, dynamic> json) {
    return CheckoutModel(
      startTime: (json['start_time'] as Timestamp).toDate(),
      endTime: (json['end_time'] as Timestamp).toDate(),
      actualCheckoutTime: (json['actual_checkout_time'] as Timestamp).toDate(),
      baseAmount: (json['base_amount'] as num).toDouble(),
      bookingId: json['booking_id'] as String,
      checkoutTime: (json['checkout_time'] as Timestamp).toDate(),
      currency: json['currency'] as String,
      fineAmount: json['fine_amount']?.toDouble(),
      isEarlyCheckout: json['is_early_checkout'] as bool,
      isLateCheckout: json['is_late_checkout'] as bool,
      overtimeDuration: json['overtime_duration'] as int?,
      slotNumber: json['slot_number'] as int,
      spaceId: json['space_id'] as String,
      spaceName: json['space_name'] as String,
      spaceLocation: json['space_location'] as String?,
      totalAmount: (json['total_amount'] as num).toDouble(),
      userId: json['user_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_time': Timestamp.fromDate(startTime),
      'end_time': Timestamp.fromDate(endTime),
      'actual_checkout_time': Timestamp.fromDate(actualCheckoutTime),
      'base_amount': baseAmount,
      'booking_id': bookingId,
      'checkout_time': Timestamp.fromDate(checkoutTime),
      'currency': currency,
      'fine_amount': fineAmount,
      'is_early_checkout': isEarlyCheckout,
      'is_late_checkout': isLateCheckout,
      'overtime_duration': overtimeDuration,
      'slot_number': slotNumber,
      'space_id': spaceId,
      'space_name': spaceName,
      'space_location': spaceLocation,
      'total_amount': totalAmount,
      'user_id': userId,
    };
  }

  CheckoutModel copyWith({
    DateTime? startTime,
    DateTime? endTime,
    DateTime? actualCheckoutTime,
    double? baseAmount,
    String? bookingId,
    DateTime? checkoutTime,
    String? currency,
    double? fineAmount,
    bool? isEarlyCheckout,
    bool? isLateCheckout,
    int? overtimeDuration,
    int? slotNumber,
    String? spaceId,
    String? spaceName,
    String? spaceLocation,
    double? totalAmount,
    String? userId,
  }) {
    return CheckoutModel(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      actualCheckoutTime: actualCheckoutTime ?? this.actualCheckoutTime,
      baseAmount: baseAmount ?? this.baseAmount,
      bookingId: bookingId ?? this.bookingId,
      checkoutTime: checkoutTime ?? this.checkoutTime,
      currency: currency ?? this.currency,
      fineAmount: fineAmount ?? this.fineAmount,
      isEarlyCheckout: isEarlyCheckout ?? this.isEarlyCheckout,
      isLateCheckout: isLateCheckout ?? this.isLateCheckout,
      overtimeDuration: overtimeDuration ?? this.overtimeDuration,
      slotNumber: slotNumber ?? this.slotNumber,
      spaceId: spaceId ?? this.spaceId,
      spaceName: spaceName ?? this.spaceName,
      spaceLocation: spaceLocation ?? this.spaceLocation,
      totalAmount: totalAmount ?? this.totalAmount,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() {
    return 'CheckoutModel('
        'startTime: $startTime, '
        'endTime: $endTime, '
        'actualCheckoutTime: $actualCheckoutTime, '
        'baseAmount: $baseAmount, '
        'bookingId: $bookingId, '
        'checkoutTime: $checkoutTime, '
        'currency: $currency, '
        'fineAmount: $fineAmount, '
        'isEarlyCheckout: $isEarlyCheckout, '
        'isLateCheckout: $isLateCheckout, '
        'overtimeDuration: $overtimeDuration, '
        'slotNumber: $slotNumber, '
        'spaceId: $spaceId, '
        'spaceName: $spaceName, '
        'spaceLocation: $spaceLocation, '
        'totalAmount: $totalAmount, '
        'userId: $userId)';
  }
}
