import 'package:flutter/material.dart';
import 'package:intrencity_provider/constants/colors.dart';
import 'package:intrencity_provider/pages/auth/login_page.dart';
import 'package:intrencity_provider/pages/auth/signup_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          bottom: TabBar(
            dividerHeight: 0,
            enableFeedback: false,
            labelColor: primaryBlue,
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            labelStyle: Theme.of(context).textTheme.bodyMedium,
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide.none,
            ),
            tabs: const [
              Tab(
                text: 'Signup',
              ),
              Tab(
                text: 'Login',
              ),
            ],
          ),
        ),
        body: const SafeArea(
          child: TabBarView(
            children: [
              SignUpPage(),
              LoginPage(),
            ],
          ),
        ),
      ),
    );
  }
}
