import 'package:flutter/material.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/views/admin/applications_page.dart';
import 'package:intrencity/views/admin/approved_applications_page.dart';
import 'package:intrencity/views/admin/rejected_applications_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    List<Widget> views = [
      const ApplicationsPage(),
      const ApprovedApplicationsPage(),
      const RejectedApplicationsPage(),
    ];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Page'),
          bottom: TabBar(
            dividerHeight: 0,
            enableFeedback: false,
            labelColor: primaryBlue,
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            labelStyle: Theme.of(context).textTheme.bodySmall,
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide.none,
            ),
            tabs: const [
              Tab(text: 'Applications'),
              Tab(text: 'Approved'),
              Tab(text: 'Rejected'),
            ],
          ),
        ),
        body: TabBarView(children: views),
      ),
    );
  }
}
