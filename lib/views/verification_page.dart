import 'package:firebase_auth/firebase_auth.dart';
import 'package:intrencity/providers/verification_provider.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/widgets/buttons/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:intrencity/widgets/add_img_container.dart';
import 'package:intrencity/widgets/dilogue_widget.dart';
import 'package:provider/provider.dart';

class VerificationPage extends StatelessWidget {
  const VerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VerificationProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 25),
                    const DocumentUploader(
                      title: 'Upload Aadhaar',
                      allowedFormats: '(pdf, png, jpg)',
                      documentId: 'aadhaar',
                    ),
                    const SizedBox(height: 25),
                    const DocumentUploader(
                      title: 'Upload Document',
                      allowedFormats: '(pdf, png, jpg)',
                      documentId: 'document',
                    ),
                    const SizedBox(height: 25),
                    Text(
                      'Note: The documents uploaded will be just used for verification purpose and will not be shared with anyone.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
            CustomButton(
              onTap: () {
                String uid = FirebaseAuth.instance.currentUser!.uid;
                provider.submmitDocuments().then((_) {
                  return CustomDilogue.showSuccessDialog(
                    context,
                    'assets/animations/tick.json',
                    ' Uploaded Successfully!',
                  );
                });
              },
              isLoading: provider.isLoading,
              title: 'Upload',
              enableIcon: true,
              icon: Icons.upload_file_rounded,
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

class DocumentUploader extends StatelessWidget {
  final String title;
  final String allowedFormats;
  final String documentId;

  const DocumentUploader({
    super.key,
    required this.title,
    required this.allowedFormats,
    required this.documentId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<VerificationProvider>(
      builder: (context, provider, child) {
        final state = provider.getOrCreateState(documentId);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.file_present_rounded,
                  size: 30,
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '  $title ',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      TextSpan(
                        text: allowedFormats,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(fontSize: 12),
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (state.file != null && state.containsPDF)
              AddImageContainer(
                onTap: () => provider.openPDF(documentId, state.file!.path),
                height: 250,
                child: provider.buildPDFView(documentId),
              )
            else if (state.file != null && !state.containsPDF)
              AddImageContainer(
                onTap: () {},
                height: 250,
                child: Image.file(
                  state.file!,
                  fit: BoxFit.cover,
                ),
              )
            else
              AddImageContainer(
                onTap: () => provider.pickFiles(documentId),
                height: 250,
              ),
            if (state.file != null && state.containsPDF && state.pdfReady)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Page ${state.currentPage + 1} of ${state.totalPages}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            if (state.file != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconButton(
                      state: state,
                      documentId: documentId,
                      label: 'Remove',
                      color: redAccent,
                      icon: Icons.highlight_remove_rounded,
                      onPressed: () => provider.removeFile(documentId),
                    ),
                    CustomIconButton(
                      state: state,
                      documentId: documentId,
                      label: 'Preview',
                      color: greenAccent,
                      icon: Icons.visibility,
                      onPressed: () {
                        provider.openPDF(documentId, state.file!.path);
                      },
                    ),
                  ],
                ),
              )
          ],
        );
      },
    );
  }
}

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.documentId,
    required this.state,
    this.label,
    this.onPressed,
    this.icon,
    this.color,
  });

  final String documentId;
  final DocumentState state;
  final String? label;
  final void Function()? onPressed;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.85,
      child: Center(
        child: TextButton.icon(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(color),
          ),
          onPressed: onPressed,
          label: Text(
            label ?? '',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          icon: Icon(
            icon,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
