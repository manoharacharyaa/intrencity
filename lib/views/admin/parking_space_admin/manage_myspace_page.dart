import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intrencity/models/parking_space_post_model.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/widgets/smooth_container.dart';

class ManageMyspacePage extends StatefulWidget {
  const ManageMyspacePage({super.key, required this.space});

  final ParkingSpacePostModel space;

  @override
  State<ManageMyspacePage> createState() => _ManageMyspacePageState();
}

class _ManageMyspacePageState extends State<ManageMyspacePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage My Space'),
      ),
      body: Column(
        children: [
          SmoothContainer(
            padding: const EdgeInsets.all(10),
            contentPadding: const EdgeInsets.all(20),
            onTap: () => context.push(
              '/admin-parking-page',
              extra: {
                'spaceId': widget.space.docId,
                'docId': widget.space.docId,
              },
            ),
            color: textFieldGrey,
            height: 80,
            width: double.infinity,
            child: const Row(
              spacing: 15,
              children: [
                Icon(
                  Icons.book,
                  color: primaryBlue,
                ),
                Text('Approve Bookings'),
                Spacer(),
                Icon(Icons.arrow_forward_ios_rounded),
              ],
            ),
          ),
          SmoothContainer(
            padding: const EdgeInsets.all(10),
            contentPadding: const EdgeInsets.all(20),
            onTap: () => context.push(
              '/otp-verification-page',
              extra: {
                'space': widget.space,
              },
            ),
            color: textFieldGrey,
            height: 80,
            width: double.infinity,
            child: const Row(
              spacing: 15,
              children: [
                Icon(
                  Icons.verified_user,
                  color: primaryBlue,
                ),
                Text('Verify OTP'),
                Spacer(),
                Icon(Icons.arrow_forward_ios_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
