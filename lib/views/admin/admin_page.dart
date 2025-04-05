import 'package:another_dashed_container/another_dashed_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:intrencity/providers/verification_provider.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intrencity/widgets/smooth_container.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  void initState() {
    context.read<VerificationProvider>().listOfDocsSubmitted();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VerificationProvider>();

    return Scaffold(
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: provider.docSubmittedUsers.length,
        itemBuilder: (context, index) {
          final user = provider.docSubmittedUsers[index];
          return SmoothContainer(
            height: 150,
            verticalPadding: 12,
            horizontalPadding: 10,
            width: double.infinity,
            color: textFieldGrey,
            child: Row(
              children: [
                const SizedBox(width: 2),
                SmoothContainer(
                  padding: EdgeInsets.all(8),
                  height: 140,
                  width: 100,
                  color: primaryBlue,
                ),
                GestureDetector(
                  onTap: () {
                    context
                        .read<VerificationProvider>()
                        .fetchAndOpenPDf(user.aadhaarUrl!);
                  },
                  child: SmoothContainer(
                    padding: EdgeInsets.all(8),
                    height: 140,
                    width: 100,
                    color: primaryBlue,
                    child: PDFView(
                      filePath:
                          'https://firebasestorage.googleapis.com/v0/b/intrencity.appspot.com/o/verification_documents%2FJnZt8QdMWjM8pHW5tC30hVPgyi93%2FJnZt8QdMWjM8pHW5tC30hVPgyi93_aadhaar_1743791667992.pdf?alt=media&token=74c18f3c-d681-4292-9734-5f69137614d1',
                      enableSwipe: true,
                      swipeHorizontal: true,
                      autoSpacing: false,
                      pageFling: false,
                      onRender: (pages) {
                        // PDF is rendered
                      },
                      // onError: (error) {
                      //   setState(() {
                      //     errorMessage = error.toString();
                      //   });
                      // },
                      // onPageError: (page, error) {
                      //   setState(() {
                      //     errorMessage = '$page: ${error.toString()}';
                      //   });
                      // },
                      // onViewCreated: (PDFViewController controller) {
                      //   // You can store the controller for later use
                      // },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
