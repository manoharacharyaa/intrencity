import 'package:flutter/material.dart';
import 'package:intrencity/providers/booking_provider.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:provider/provider.dart';

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
            MyBooking(),
            Approval(),
          ],
        ),
      ),
    );
  }
}

class MyBooking extends StatefulWidget {
  const MyBooking({super.key});

  @override
  State<MyBooking> createState() => _MyBookingState();
}

class _MyBookingState extends State<MyBooking> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    return Scaffold(
      body: provider.parkings.isEmpty
          ? const Center(
              child: Text('You Have No Bookings'),
            )
          : ListView.builder(
              shrinkWrap: true,
              itemCount: provider.parkings.length,
              itemBuilder: (context, index) {
                final booking = provider.parkings[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    tileColor: Colors.amber,
                    title: Text(booking.spaceName),
                  ),
                );
              },
            ),
    );
  }
}

class Approval extends StatelessWidget {
  const Approval({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('No Bookings'),
      ),
    );
  }
}
