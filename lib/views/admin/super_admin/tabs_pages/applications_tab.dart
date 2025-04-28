import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intrencity/models/user_profile_model.dart';
import 'package:intrencity/providers/verification_provider.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/utils/smooth_corners/clip_smooth_rect.dart';
import 'package:intrencity/utils/smooth_corners/smooth_border_radius.dart';
import 'package:intrencity/utils/smooth_corners/smooth_rectangle_border.dart';
import 'package:intrencity/widgets/buttons/small_button.dart';
import 'package:intrencity/widgets/dialogs/confirmation_dialog.dart';
import 'package:intrencity/widgets/smooth_container.dart';
import 'package:provider/provider.dart';

class ApplicationsTab extends StatefulWidget {
  const ApplicationsTab({super.key});

  @override
  State<ApplicationsTab> createState() => _ApplicationsTabState();
}

class _ApplicationsTabState extends State<ApplicationsTab> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VerificationProvider>();
    return StreamBuilder<List<UserProfileModel>>(
      stream:
          context.read<VerificationProvider>().getPendingApplicationsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return const Center(child: Text('No Active Applications Found'));
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
                            showDialog(
                              context: context,
                              builder: (context) => ConfirmationDialog(
                                title: 'Confirm Approval',
                                onConfirm: () {
                                  provider.confirmApproval(user.uid).then(
                                    (_) {
                                      if (context.mounted) {
                                        context.pop();
                                      }
                                    },
                                  );
                                },
                                onReject: () {
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
                                              hintText:
                                                  'Enter reason for rejection',
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
                                                      backgroundColor:
                                                          redAccent,
                                                    ),
                                                  );
                                                  return;
                                                }

                                                provider
                                                    .rejectApproval(
                                                  reasonController.text.trim(),
                                                  user.uid,
                                                )
                                                    .then((_) {
                                                  context
                                                      .pop(); // Close reason dialog
                                                  context
                                                      .pop(); // Close confirmation dialog
                                                }).catchError((error) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content:
                                                          Text('Error: $error'),
                                                      backgroundColor:
                                                          redAccent,
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
                              ),
                            );
                          },
                          color: const Color.fromARGB(255, 0, 255, 13),
                          label: 'Approve',
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

class CustomMultilineFormField extends StatelessWidget {
  const CustomMultilineFormField({
    super.key,
    this.controller,
    this.hintText,
    this.maxLines = 3,
    this.onChanged,
    this.validator,
    this.fillColor,
  });

  final TextEditingController? controller;
  final String? hintText;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final int? maxLines;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    return ClipSmoothRect(
      radius: SmoothBorderRadius(
        cornerRadius: 12,
        cornerSmoothing: 0.8,
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        cursorColor: Colors.white,
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontSize: 14,
            ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(16),
          filled: true,
          fillColor: Colors.grey[900],
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
          border: InputBorder.none,
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: SmoothBorderRadius(
              cornerRadius: 12,
              cornerSmoothing: 0.8,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: SmoothBorderRadius(
              cornerRadius: 12,
              cornerSmoothing: 0.8,
            ),
          ),
          errorStyle: const TextStyle(color: redAccent),
        ),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}
