import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intrencity/providers/users_provider.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/views/user/my_booking_page.dart';
import 'package:intrencity/views/user/parking_list_page.dart';
import 'package:provider/provider.dart';

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
    final approved = context.watch<UsersProvider>().approved;
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
      floatingActionButton: !approved
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

      // floatingActionButton: StreamBuilder<Object>(
      //   stream: context.watch<UsersProvider>().getCurrentUser(),
      //   builder: (context, snapshot) {
      //     return snapshot.data == false
      //         ? TextButton(
      //             style: const ButtonStyle(
      //               backgroundColor: WidgetStatePropertyAll(
      //                 primaryBlue,
      //               ),
      //             ),
      //             onPressed: () => context.push('/verification-page'),
      //             child: Text(
      //               'Verify',
      //               style: Theme.of(context).textTheme.bodySmall,
      //             ),
      //           )
      //         : FloatingActionButton(
      //             onPressed: () => context.push('/space-posting-page'),
      //             backgroundColor: primaryBlue,
      //             shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(100),
      //             ),
      //             child: const Icon(
      //               Icons.add,
      //               color: Colors.white,
      //             ),
      //           );
      //   },
      // ),