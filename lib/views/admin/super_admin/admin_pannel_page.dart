import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/widgets/smooth_container.dart';

class AdminPannelPage extends StatefulWidget {
  const AdminPannelPage({super.key});

  @override
  State<AdminPannelPage> createState() => _AdminPannelPageState();
}

class _AdminPannelPageState extends State<AdminPannelPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Pannel'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AdminPannelTile(
              onTap: () => context.push('/application-approval-page'),
              label: 'Applications',
              icon: Icons.article_rounded,
            ),
            AdminPannelTile(
              onTap: () => context.push('/all-users-page'),
              label: 'Applications',
              icon: Icons.people_alt_rounded,
            ),
            AdminPannelTile(
              onTap: () => context.push('/application-approval-page'),
              label: 'Applications',
              icon: Icons.article_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class AdminPannelTile extends StatelessWidget {
  const AdminPannelTile({
    super.key,
    this.label,
    this.onTap,
    this.icon,
  });

  final void Function()? onTap;
  final String? label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SmoothContainer(
      onTap: onTap,
      height: 100,
      width: double.infinity,
      color: textFieldGrey,
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 8,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Icon(
              icon,
              size: 50,
            ),
          ),
          Text(label ?? ''),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Icon(Icons.arrow_forward_ios_rounded),
          ),
        ],
      ),
    );
  }
}
