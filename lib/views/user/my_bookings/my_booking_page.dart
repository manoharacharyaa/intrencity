import 'package:flutter/material.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/views/user/my_bookings/tabs/approvals_tab.dart';
import 'package:intrencity/views/user/my_bookings/tabs/bookings_tab.dart';

class MyBookingPage extends StatefulWidget {
  const MyBookingPage({super.key});

  @override
  State<MyBookingPage> createState() => _MyBookingPageState();
}

class _MyBookingPageState extends State<MyBookingPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('My Bookings'),
          bottom: TabBar(
            dividerHeight: 0,
            enableFeedback: false,
            labelColor: primaryBlue,
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            labelStyle: Theme.of(context).textTheme.titleSmall,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: primaryBlue,
            tabs: const [
              Tab(
                text: 'Booking',
              ),
              Tab(
                text: 'Approved',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            BookingsTab(),
            ApprovalsTab(),
          ],
        ),
      ),
    );
  }
}
