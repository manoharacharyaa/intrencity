import 'package:flutter/material.dart';
import 'package:intrencity_provider/constants/colors.dart';
import 'package:intrencity_provider/pages/admin/admin_pannel.dart';
import 'package:intrencity_provider/pages/user/my_bookings_page.dart';
import 'package:intrencity_provider/pages/user/parking_slot_page.dart';
import 'package:intrencity_provider/pages/user/space_posting_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminPannelPage(),
    const ParkingSlotPage(),
    const MyBookingsPage(),
    const SpacePostingPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Admin Panel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_parking),
            label: 'Parking Slots',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_add_rounded),
            label: 'My Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.post_add),
            label: 'Posting',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.blueGrey,
        unselectedLabelStyle: const TextStyle(
          color: Colors.blueGrey,
        ),
        onTap: _onItemTapped,
      ),
    );
  }
}
