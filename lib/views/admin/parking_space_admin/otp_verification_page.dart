// ignore_for_file: prefer_is_empty
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intrencity/models/parking_space_post_model.dart';
import 'package:intrencity/providers/admin/space_admin_viewmodel.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/utils/smooth_corners/smooth_border_radius.dart';
import 'package:intrencity/utils/smooth_corners/smooth_radius.dart';
import 'package:intrencity/viewmodels/users_viewmodel.dart';
import 'package:intrencity/widgets/row_text_tile_widget.dart';
import 'package:intrencity/widgets/smooth_container.dart';
import 'package:provider/provider.dart';

class OTPVerificationPage extends StatefulWidget {
  const OTPVerificationPage({
    super.key,
    required this.mySpace,
  });

  final ParkingSpacePostModel mySpace;

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  late TabBarView _tabBarView;

  @override
  void initState() {
    super.initState();
    _tabBarView = TabBarView(
      children: [
        UnverifiedOTPUsers(mySpace: widget.mySpace),
        VerifiedOTPUsers(mySpace: widget.mySpace),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final spaces = context.watch<UsersViewmodel>().currentUserSpaces;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verify OTP'),
          bottom: const TabBar(
            indicatorColor: primaryBlue,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: primaryBlue,
            splashFactory: NoSplash.splashFactory,
            dividerColor: Colors.transparent,
            tabs: [
              Tab(
                child: Text('Unverified'),
              ),
              Tab(
                child: Text('Verified'),
              ),
            ],
          ),
        ),
        body: _tabBarView,
      ),
    );
  }
}

class UnverifiedOTPUsers extends StatefulWidget {
  const UnverifiedOTPUsers({super.key, required this.mySpace});

  final ParkingSpacePostModel mySpace;

  @override
  State<UnverifiedOTPUsers> createState() => _UnverifiedOTPUsersState();
}

class _UnverifiedOTPUsersState extends State<UnverifiedOTPUsers> {
  Map<int, bool> _expanded = {};

  void _toggleExpanded(int index) {
    setState(() {
      _expanded[index] = !(_expanded[index] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: context
            .watch<SpaceAdminViewmodel>()
            .getUserHasOTPStream(widget.mySpace.docId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.data!.isEmpty) {
            return const Center(child: Text('No Bookings Found'));
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final data = snapshot.data![index];
              final isExpanded = _expanded[index] ?? false;
              return Column(
                children: [
                  SmoothContainer(
                    radius: !isExpanded
                        ? null
                        : SmoothBorderRadius(
                            cornerRadius: 18,
                            cornerSmoothing: 0.8,
                          ).copyWith(
                            bottomLeft: const SmoothRadius(
                              cornerRadius: 0,
                              cornerSmoothing: 0,
                            ),
                            bottomRight: const SmoothRadius(
                              cornerRadius: 0,
                              cornerSmoothing: 0,
                            ),
                          ),
                    width: double.infinity,
                    color: textFieldGrey,
                    padding: const EdgeInsets.all(10).copyWith(bottom: 0),
                    contentPadding: const EdgeInsets.all(12),
                    child: Row(
                      spacing: 10,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: primaryBlue,
                          backgroundImage: data.user.profilePic == null
                              ? null
                              : NetworkImage(data.user.profilePic!),
                          child: data.user.profilePic == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        Text(data.user.name),
                        const Spacer(),
                        IconButton(
                          onPressed: () => _toggleExpanded(index),
                          icon: const Icon(Icons.arrow_circle_right_outlined),
                        )
                      ],
                    ),
                  ),
                  if (isExpanded)
                    SmoothContainer(
                      radius: SmoothBorderRadius(
                        cornerRadius: 18,
                        cornerSmoothing: 0.8,
                      ).copyWith(
                        topLeft: const SmoothRadius(
                          cornerRadius: 0,
                          cornerSmoothing: 0,
                        ),
                        topRight: const SmoothRadius(
                          cornerRadius: 0,
                          cornerSmoothing: 0,
                        ),
                      ),
                      width: double.infinity,
                      color: textFieldGrey,
                      padding: const EdgeInsets.all(10).copyWith(top: 0),
                      contentPadding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RowTextTile(
                            label: 'Name: ',
                            text: data.user.name,
                          ),
                          RowTextTile(
                            label: 'Phone: ',
                            text: data.user.phoneNumber,
                          ),
                          RowTextTile(
                            label: 'Email: ',
                            text: data.user.email,
                          ),
                          RowTextTile(
                            label: 'Booking Id: ',
                            text: data.booking.bookingId,
                          ),
                          RowTextTile(
                            label: 'Slot Number: ',
                            text: data.booking.slotNumber.toString(),
                          ),
                          RowTextTile(
                            label: 'Booking Time: ',
                            text: DateFormat('MMM dd, yyyy hh:mm a')
                                .format(data.booking.bookingTime),
                          ),
                          RowTextTile(
                            label: 'OTP: ',
                            text: data.booking.otp.toString(),
                          ),
                          if (data.booking.otp != null)
                            Align(
                              alignment: Alignment.bottomRight,
                              child: ElevatedButton(
                                onPressed: () => context.push(
                                  '/enter-otp-page',
                                  extra: {
                                    'otp': data.booking.otp,
                                    'docId': widget.mySpace.docId,
                                    'uid': data.booking.uid,
                                  },
                                ),
                                style: const ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll(primaryBlue),
                                ),
                                child: Text(
                                  'Verify OTP',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class VerifiedOTPUsers extends StatefulWidget {
  const VerifiedOTPUsers({super.key, required this.mySpace});

  final ParkingSpacePostModel mySpace;

  @override
  State<VerifiedOTPUsers> createState() => _VerifiedOTPUsersState();
}

class _VerifiedOTPUsersState extends State<VerifiedOTPUsers> {
  Map<int, bool> _expanded = {};

  void _toggleExpanded(int index) {
    setState(() {
      _expanded[index] = !(_expanded[index] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: context
              .watch<SpaceAdminViewmodel>()
              .getVerifiedOTPUsersStream(widget.mySpace.docId!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData && snapshot.data!.isEmpty ||
                snapshot.data!.length == 0) {
              return const Center(child: Text('No Bookings Found'));
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final data = snapshot.data![index];
                final isExpanded = _expanded[index] ?? false;
                return Column(
                  children: [
                    SmoothContainer(
                      radius: !isExpanded
                          ? null
                          : SmoothBorderRadius(
                              cornerRadius: 18,
                              cornerSmoothing: 0.8,
                            ).copyWith(
                              bottomLeft: const SmoothRadius(
                                cornerRadius: 0,
                                cornerSmoothing: 0,
                              ),
                              bottomRight: const SmoothRadius(
                                cornerRadius: 0,
                                cornerSmoothing: 0,
                              ),
                            ),
                      width: double.infinity,
                      color: textFieldGrey,
                      padding: const EdgeInsets.all(10).copyWith(bottom: 0),
                      contentPadding: const EdgeInsets.all(12),
                      child: Row(
                        spacing: 10,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: primaryBlue,
                            backgroundImage: data.user.profilePic == null
                                ? null
                                : NetworkImage(data.user.profilePic!),
                            child: data.user.profilePic == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          Text(data.user.name),
                          const Spacer(),
                          IconButton(
                            onPressed: () => _toggleExpanded(index),
                            icon: const Icon(Icons.arrow_circle_right_outlined),
                          )
                        ],
                      ),
                    ),
                    if (isExpanded)
                      SmoothContainer(
                        radius: SmoothBorderRadius(
                          cornerRadius: 18,
                          cornerSmoothing: 0.8,
                        ).copyWith(
                          topLeft: const SmoothRadius(
                            cornerRadius: 0,
                            cornerSmoothing: 0,
                          ),
                          topRight: const SmoothRadius(
                            cornerRadius: 0,
                            cornerSmoothing: 0,
                          ),
                        ),
                        width: double.infinity,
                        color: textFieldGrey,
                        padding: const EdgeInsets.all(10).copyWith(top: 0),
                        contentPadding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RowTextTile(
                              label: 'Name: ',
                              text: data.user.name,
                            ),
                            RowTextTile(
                              label: 'Phone: ',
                              text: data.user.phoneNumber,
                            ),
                            RowTextTile(
                              label: 'Email: ',
                              text: data.user.email,
                            ),
                            RowTextTile(
                              label: 'Booking Id: ',
                              text: data.booking.bookingId,
                            ),
                            RowTextTile(
                              label: 'Slot Number: ',
                              text: data.booking.slotNumber.toString(),
                            ),
                            RowTextTile(
                              label: 'Booking Time: ',
                              text: DateFormat('MMM dd, yyyy hh:mm a')
                                  .format(data.booking.bookingTime),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            );
          }),
    );
  }
}
