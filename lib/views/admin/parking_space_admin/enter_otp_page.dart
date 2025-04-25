import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intrencity/utils/colors.dart';

class EnterOTPPage extends StatefulWidget {
  const EnterOTPPage({
    super.key,
    required this.otp,
    required this.docId,
    required this.uid,
  });

  final int otp;
  final String docId;
  final String uid;

  @override
  State<EnterOTPPage> createState() => _EnterOTPPageState();
}

class _EnterOTPPageState extends State<EnterOTPPage> {
  Future<void> _verifyOTP(String otp) async {
    try {
      final spaceRef =
          FirebaseFirestore.instance.collection('spaces').doc(widget.docId);

      DocumentSnapshot snapshot = await spaceRef.get();

      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        if (data.containsKey('bookings')) {
          List<dynamic> bookings = List.from(data['bookings']);
          int bookingIndex = bookings.indexWhere(
            (booking) =>
                booking['uid'] == widget.uid &&
                booking['otp'].toString() == otp,
          );

          if (bookingIndex != -1) {
            Map<String, dynamic> updatedBooking =
                Map.from(bookings[bookingIndex]);

            updatedBooking['is_otp_verified'] = true;
            updatedBooking['start_time'] = Timestamp.now();

            bookings[bookingIndex] = updatedBooking;

            await spaceRef.update({
              'bookings': bookings,
            });

            if (mounted) {
              Navigator.pop(context);
              Fluttertoast.showToast(msg: 'OTP Verified');
            }
          } else {
            if (mounted) {
              Fluttertoast.showToast(msg: 'Innvalid OTP');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error verifying OTP')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 50),
          OtpTextField(
            numberOfFields: 4,
            borderColor: primaryBlue,
            filled: true,
            fillColor: textFieldGrey,
            enabledBorderColor: Colors.transparent,
            disabledBorderColor: Colors.transparent,
            focusedBorderColor: Colors.transparent,
            cursorColor: Colors.white,
            showFieldAsBox: true,
            onCodeChanged: (String code) {},
            onSubmit: (String otp) {
              _verifyOTP(otp);
            },
          ),
        ],
      ),
    );
  }
}
