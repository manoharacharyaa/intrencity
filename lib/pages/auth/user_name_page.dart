import 'package:flutter/material.dart';
import 'package:intrencity_provider/widgets/custom_auth_field.dart';

class UserNamePage extends StatefulWidget {
  const UserNamePage({super.key});

  @override
  State<UserNamePage> createState() => _UserNamePageState();
}

final userNameController = TextEditingController();

class _UserNamePageState extends State<UserNamePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAuthField(
              controller: userNameController,
            ),
          ],
        ),
      ),
    );
  }
}
