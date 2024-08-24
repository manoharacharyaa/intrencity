import 'package:flutter/material.dart';
import 'package:intrencity_provider/constants/colors.dart';
import 'package:intrencity_provider/pages/auth/auth_page.dart';
import 'package:intrencity_provider/providers/auth_provider.dart';
import 'package:intrencity_provider/widgets/booking_slot_container.dart';
import 'package:provider/provider.dart';

class ParkingSlotPage extends StatelessWidget {
  const ParkingSlotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Parking Slots',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthenticationProvider>().logout().then(
                    (_) => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AuthPage(),
                      ),
                    ),
                  );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            const Center(
              child: VerticalDivider(
                indent: 20,
                endIndent: 20,
                color: primaryBlueTransparent,
              ),
            ),
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 5 / 5,
              ),
              itemCount: 20,
              itemBuilder: (context, index) {
                return BookingSlotContainer(
                  slotNumber: index + 1,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
