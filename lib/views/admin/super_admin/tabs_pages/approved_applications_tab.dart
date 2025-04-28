import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intrencity/models/user_profile_model.dart';
import 'package:intrencity/providers/verification_provider.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/utils/smooth_corners/smooth_border_radius.dart';
import 'package:intrencity/utils/smooth_corners/smooth_rectangle_border.dart';
import 'package:intrencity/views/admin/super_admin/tabs_pages/applications_tab.dart';
import 'package:intrencity/widgets/buttons/small_button.dart';
import 'package:intrencity/widgets/smooth_container.dart';
import 'package:provider/provider.dart';

class ApprovedApplicationsTab extends StatefulWidget {
  const ApprovedApplicationsTab({super.key});

  @override
  State<ApprovedApplicationsTab> createState() =>
      _ApprovedApplicationsTabState();
}

class _ApprovedApplicationsTabState extends State<ApprovedApplicationsTab> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VerificationProvider>();

    return StreamBuilder<List<UserProfileModel>>(
      stream: context.read<VerificationProvider>().getApprovedUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return const Center(child: Text('No Approved Applications Found'));
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
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
                            backgroundColor: primaryBlue,
                            radius: 40,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            ),
                          )
                        : CircleAvatar(
                            backgroundColor: primaryBlue,
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
                        SmallButton(
                          onTap: () {
                            final TextEditingController reasonController =
                                TextEditingController();

                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                contentPadding: EdgeInsets.zero,
                                backgroundColor: textFieldGrey,
                                shape: SmoothRectangleBorder(
                                  borderRadius: SmoothBorderRadius(
                                    cornerRadius: 20,
                                    cornerSmoothing: 0.8,
                                  ),
                                ),
                                content: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Enter Rejection Reason',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      CustomMultilineFormField(
                                        controller: reasonController,
                                        hintText: 'Enter reason for rejection',
                                        maxLines: 3,
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SmallButton(
                                        onTap: () => context.pop(),
                                        color: Colors.grey,
                                        label: 'Cancel',
                                      ),
                                      SmallButton(
                                        onTap: () {
                                          if (reasonController.text
                                              .trim()
                                              .isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Please enter a rejection reason'),
                                                backgroundColor: redAccent,
                                              ),
                                            );
                                            return;
                                          }

                                          provider
                                              .rejectApproval(
                                                reasonController.text.trim(),
                                                user.uid,
                                              )
                                              .then((_) => context.pop())
                                              .catchError((error) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text('Error: $error'),
                                                backgroundColor: redAccent,
                                              ),
                                            );
                                          });
                                        },
                                        color: redAccent,
                                        label: 'Reject',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                          color: redAccent,
                          label: 'Reject',
                        ),
                        const SizedBox(width: 12),
                        SmallButton(
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
                        SmallButton(
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
        );
      },
    );
  }
}
