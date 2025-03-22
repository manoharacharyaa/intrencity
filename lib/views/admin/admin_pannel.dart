import 'package:flutter/material.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/views/auth/auth_page.dart';
import 'package:intrencity/providers/auth_provider.dart';
import 'package:intrencity/widgets/admin_slot_container.dart';
import 'package:provider/provider.dart';

class AdminPannelPage extends StatelessWidget {
  const AdminPannelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Slots',
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
                return AdminSlotContainer(
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
