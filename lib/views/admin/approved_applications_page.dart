import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intrencity/providers/verification_provider.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/utils/smooth_corners/smooth_border_radius.dart';
import 'package:intrencity/utils/smooth_corners/smooth_rectangle_border.dart';
import 'package:intrencity/views/admin/applications_page.dart';
import 'package:intrencity/widgets/smooth_container.dart';
import 'package:provider/provider.dart';

class ApprovedApplicationsPage extends StatefulWidget {
  const ApprovedApplicationsPage({super.key});

  @override
  State<ApprovedApplicationsPage> createState() =>
      _ApprovedApplicationsPageState();
}

class _ApprovedApplicationsPageState extends State<ApprovedApplicationsPage> {
  @override
  void initState() {
    context.read<VerificationProvider>().getApprovedUsers();
    super.initState();
  }

  Future<void> confirmApproval() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'is_approved': true,
      });
    } catch (e) {
      debugPrint('Error in confirmApproval()');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VerificationProvider>();
    final read = context.read<VerificationProvider>();

    return Scaffold(
      body: provider.approvedUsers.isEmpty
          ? const Center(child: Text('No Active Applications Found'))
          : ListView.builder(
              shrinkWrap: true,
              itemCount: provider.approvedUsers.length,
              itemBuilder: (context, index) {
                final user = provider.approvedUsers[index];
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
                        user.profilePic == null
                            ? const CircleAvatar(
                                backgroundColor: Colors.cyan,
                                radius: 40,
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              )
                            : CircleAvatar(
                                backgroundColor: Colors.cyan,
                                radius: 40,
                                backgroundImage: NetworkImage(user.profilePic!),
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
                                            'Confirm Rejection',
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
                                              onTap: () {
                                                read
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
                              color: redAccent,
                              label: 'Reject',
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
