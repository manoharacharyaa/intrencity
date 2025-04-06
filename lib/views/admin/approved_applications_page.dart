import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intrencity/models/user_profile_model.dart';
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
        );
      },
    );
  }
}
