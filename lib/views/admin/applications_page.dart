import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intrencity/providers/verification_provider.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/utils/smooth_corners/smooth_border_radius.dart';
import 'package:intrencity/utils/smooth_corners/smooth_rectangle_border.dart';
import 'package:intrencity/widgets/smooth_container.dart';
import 'package:provider/provider.dart';

class ApplicationsPage extends StatefulWidget {
  const ApplicationsPage({super.key});

  @override
  State<ApplicationsPage> createState() => _ApplicationsPageState();
}

class _ApplicationsPageState extends State<ApplicationsPage> {
  @override
  void initState() {
    context.read<VerificationProvider>().listOfApplicationsSubmitted();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VerificationProvider>();
    return Scaffold(
      body: provider.docSubmittedUsers.isEmpty
          ? const Center(child: Text('No Active Applications Found'))
          : ListView.builder(
              shrinkWrap: true,
              itemCount: provider.docSubmittedUsers.length,
              itemBuilder: (context, index) {
                final user = provider.docSubmittedUsers[index];
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
                                            AdminPageButton(
                                              onTap: () {
                                                provider
                                                    .rejectApproval(
                                                      'rejectionReason',
                                                      user.uid,
                                                    )
                                                    .then(
                                                      (_) => context.pop(),
                                                    );
                                              },
                                              color: redAccent,
                                              label: 'Reject',
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

class AdminPageButton extends StatelessWidget {
  const AdminPageButton({
    super.key,
    this.onTap,
    this.color,
    this.label,
  });

  final void Function()? onTap;
  final Color? color;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return SmoothContainer(
      onTap: onTap,
      cornerRadius: 10,
      height: 35,
      width: 90,
      color: color ?? primaryBlue,
      child: Center(
        child: Text(
          label ?? '',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
