import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/views/user/my_bookings/my_booking_page.dart';
import 'package:intrencity/views/user/parking_list_page.dart';
import 'package:provider/provider.dart';
import 'package:intrencity/viewmodels/users_viewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ParkingListPage(),
    const MyBookingPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.watch<GetAllUsersViewmodel>();

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_parking_rounded),
            label: 'Parkings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Bookings',
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
      floatingActionButton: !userViewModel.isApproved
          ? null
          : FloatingActionButton(
              onPressed: () => context.push('/space-posting-page'),
              backgroundColor: primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }
}
