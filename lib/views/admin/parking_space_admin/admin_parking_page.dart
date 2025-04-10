import 'package:flutter/material.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/views/admin/parking_space_admin/tab_pages/approved_bookings_page.dart';
import 'package:intrencity/views/admin/parking_space_admin/tab_pages/bookings_page.dart';

class AdminParkingPage extends StatefulWidget {
  const AdminParkingPage({
    super.key,
    required this.spaceId,
    required this.docId,
  });

  final String spaceId;
  final String docId;

  @override
  State<AdminParkingPage> createState() => _AdminParkingPageState();
}

class _AdminParkingPageState extends State<AdminParkingPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final List<Widget> _pages;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _pages = [
      BookingsPage(
        spaceId: widget.spaceId,
        docId: widget.docId,
      ),
      ApprovedBookingsPage(
        spaceId: widget.docId,
      ),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        bottom: TabBar(
          indicatorColor: primaryBlue,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: Theme.of(context).textTheme.bodySmall,
          overlayColor: const WidgetStatePropertyAll(null),
          controller: _tabController,
          tabs: const [
            Tab(
              child: Text('Bookings'),
            ),
            Tab(
              child: Text('Approved'),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _pages,
      ),
    );
  }
}
