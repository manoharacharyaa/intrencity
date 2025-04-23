import 'package:flutter/material.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/views/admin/super_admin/tabs_pages/applications_tab.dart';
import 'package:intrencity/views/admin/super_admin/tabs_pages/approved_applications_tab.dart';
import 'package:intrencity/views/admin/super_admin/tabs_pages/rejected_applications_tab.dart';

class ApplicationApprovalPage extends StatefulWidget {
  const ApplicationApprovalPage({super.key});

  @override
  State<ApplicationApprovalPage> createState() =>
      _ApplicationApprovalPageState();
}

class _ApplicationApprovalPageState extends State<ApplicationApprovalPage> {
  @override
  Widget build(BuildContext context) {
    List<Widget> views = [
      const ApplicationsTab(),
      const ApprovedApplicationsTab(),
      const RejectedApplicationsTab(),
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
