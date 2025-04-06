import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intrencity/providers/verification_provider.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/utils/smooth_corners/smooth_border_radius.dart';
import 'package:intrencity/utils/smooth_corners/smooth_rectangle_border.dart';
import 'package:intrencity/views/admin/applications_page.dart';
import 'package:intrencity/widgets/smooth_container.dart';
import 'package:provider/provider.dart';

class RejectedApplicationsPage extends StatefulWidget {
  const RejectedApplicationsPage({super.key});

  @override
  State<RejectedApplicationsPage> createState() =>
      _RejectedApplicationsPageState();
}

class _RejectedApplicationsPageState extends State<RejectedApplicationsPage> {
  @override
  void initState() {
    context.read<VerificationProvider>().getRejectedUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VerificationProvider>();

    return Scaffold(
      body: provider.rejectedUsers.isEmpty
          ? const Center(child: Text('No Rejected Users Found'))
          : ListView.builder(
              shrinkWrap: true,
              itemCount: provider.rejectedUsers.length,
              itemBuilder: (context, index) {
                final user = provider.rejectedUsers[index];
                return SmoothContainer(
                  height: 170,
                  verticalPadding: 8,
                  horizontalPadding: 10,
                  width: double.infinity,
                  color: textFieldGrey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(user.profilePic ?? ''),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user.name,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AdminPageButton(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => StatefulBuilder(
                                    builder: (context, setState) => AlertDialog(
                                      contentPadding: EdgeInsets.zero,
                                      backgroundColor: textFieldGrey,
                                      shape: SmoothRectangleBorder(
                                        borderRadius: SmoothBorderRadius(
                                          cornerRadius: 20,
                                          cornerSmoothing: 0.8,
                                        ),
                                      ),
                                      content: const SizedBox(
                                        height: 100,
                                        width: 50,
                                        child: Center(
                                          child: Text(
                                            'Confirm Approval',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      actions: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            AdminPageButton(
                                              onTap: () => provider
                                                  .confirmApproval(user.uid)
                                                  .then(
                                                    (_) => context.pop(),
                                                  ),
                                              color: greenAccent,
                                              label: 'Confirm',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              color: const Color.fromARGB(255, 0, 255, 13),
                              label: 'Approve',
                            ),
                            const SizedBox(width: 12),
                            AdminPageButton(
                              onTap: () {
                                if (user.aadhaarUrl!.contains('.pdf')) {
                                  context
                                      .read<VerificationProvider>()
                                      .fetchAndOpenPDf(user.aadhaarUrl!);
                                } else {
                                  context
                                      .read<VerificationProvider>()
                                      .fetchAndOpenImage(user.aadhaarUrl!);
                                }
                              },
                              label: 'Aadhaar',
                            ),
                            const SizedBox(width: 12),
                            AdminPageButton(
                              onTap: () {
                                if (user.documentUrl!.contains('.pdf')) {
                                  context
                                      .read<VerificationProvider>()
                                      .fetchAndOpenPDf(user.documentUrl!);
                                } else {
                                  context
                                      .read<VerificationProvider>()
                                      .fetchAndOpenImage(user.documentUrl!);
                                }
                              },
                              label: 'Document',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
