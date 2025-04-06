import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:intrencity/models/user_profile_model.dart';
import 'package:open_filex/open_filex.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DocumentState {
  File? file;
  bool containsPDF = false;
  bool pdfReady = false;
  int? totalPages;
  int currentPage = 0;
  String? downloadUrl;

  void reset() {
    file = null;
    containsPDF = false;
    pdfReady = false;
    totalPages = null;
    currentPage = 0;
    downloadUrl = null;
  }
}

class VerificationProvider extends ChangeNotifier {
  // VerificationProvider() {
  //   listOfDocsSubmitted();
  // }
  final Map<String, DocumentState> documents = {};
  List<UserProfileModel> docSubmittedUsers = [];
  List<UserProfileModel> approvedUsers = [];
  List<UserProfileModel> rejectedUsers = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setIsLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  DocumentState getOrCreateState(String documentId) {
    return documents[documentId] ??= DocumentState();
  }

  void pickFiles(String documentId) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'doc', 'png', 'jpeg'],
      );

      if (result != null) {
        final state = getOrCreateState(documentId);
        state.file = File(result.files.single.path!);
        String fileExtension = state.file!.path.split('.').last.toLowerCase();
        state.containsPDF = fileExtension == 'pdf';
        if (state.containsPDF) {
          state.pdfReady = false;
          debugPrint('PDF path: ${state.file!.path}');
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  void openPDF(String documentId, String path) async {
    try {
      final result = await OpenFilex.open(path);
      debugPrint('Open PDF result: ${result.message}');
    } catch (e) {
      debugPrint('Error opening PDF: $e');
    }
  }

  void setCurrentPage(String documentId, int? page) {
    final state = getOrCreateState(documentId);
    state.currentPage = page ?? 0;
    notifyListeners();
  }

  void setPdfReady(String documentId, bool status) {
    final state = getOrCreateState(documentId);
    state.pdfReady = status;
    notifyListeners();
  }

  void setTotalPages(String documentId, int? pages) {
    final state = getOrCreateState(documentId);
    state.totalPages = pages;
    state.pdfReady = true;
    notifyListeners();
  }

  void removeFile(String documentId) {
    final state = getOrCreateState(documentId);
    state.reset();
    notifyListeners();
  }

  Widget buildPDFView(String documentId) {
    final state = getOrCreateState(documentId);
    return Stack(
      children: [
        PDFView(
          filePath: state.file!.path,
          enableSwipe: true,
          swipeHorizontal: true,
          autoSpacing: true,
          pageSnap: true,
          pageFling: true,
          onRender: (pages) => setTotalPages(documentId, pages),
          onError: (error) {
            setPdfReady(documentId, false);
            debugPrint('PDF Error: $error');
          },
          onPageError: (page, error) {
            debugPrint('PDF Page Error: $error');
          },
          onViewCreated: (PDFViewController pdfViewController) {
            // You can store the controller for future use
          },
          onPageChanged: (int? page, int? total) {
            setCurrentPage(documentId, page);
          },
        ),
        if (!state.pdfReady)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  Future<String?> uploadDocument(String documentId) async {
    final state = getOrCreateState(documentId);
    if (state.file == null) return null;
    String uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      final fileName =
          '${uid}_${documentId}_${DateTime.now().millisecondsSinceEpoch}';
      final extention = state.file!.path.split('.').last.toLowerCase();
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('verification_documents/$uid/$fileName.$extention');

      final uploadTask = await storageRef.putFile(state.file!);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      state.downloadUrl = downloadUrl;
      return downloadUrl;
    } catch (e) {
      debugPrint('Error in uploading documents: $e');
      return null;
    }
  }

  Future<void> submmitDocuments() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      _setIsLoading(true);

      final aadhaarUrl = await uploadDocument('aadhaar');
      final documentUrl = await uploadDocument('document');

      if (aadhaarUrl == null || documentUrl == null) {
        throw Exception('Please upload both the documents');
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'aadhaarUrl': aadhaarUrl,
        'documentUrl': documentUrl,
        'verificationSubmittedAt': FieldValue.serverTimestamp(),
      });

      _setIsLoading(false);
      DocumentState().reset();
      notifyListeners();
    } catch (e) {
      debugPrint('Error submitting documents: $e');
      _setIsLoading(false);
    }
  }

  Future<void> listOfApplicationsSubmitted() async {
    try {
      QuerySnapshot snapshots =
          await FirebaseFirestore.instance.collection('users').get();

      if (snapshots.docs.isNotEmpty) {
        List docs = snapshots.docs;

        List<UserProfileModel> users = docs
            .where((doc) => (doc.data() as Map<String, dynamic>)
                .containsKey('verificationSubmittedAt'))
            .where((doc) =>
                doc.data()['is_approved'] == false &&
                doc.data()['is_rejected'] == false)
            .map(
              (doc) => UserProfileModel.fromJson(doc.data()),
            )
            .toList();

        docSubmittedUsers = users;
        notifyListeners();
      } else {
        debugPrint('No users Docs Found');
      }
    } catch (e) {
      debugPrint('No User Doc Found: $e');
    }
  }

  Future<void> getApprovedUsers() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      if (snapshot.docs.isNotEmpty) {
        List docs = snapshot.docs;
        List<UserProfileModel> users = docs
            .where((doc) => (doc.data()['is_approved']) == true)
            .map(
              (doc) => UserProfileModel.fromJson(doc.data()),
            )
            .toList();
        approvedUsers = users;
        notifyListeners();
      } else {
        debugPrint('No users Docs Found');
      }
    } catch (e) {
      debugPrint('No User Doc Found: $e');
    }
  }

  Future<void> getRejectedUsers() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      if (snapshot.docs.isNotEmpty) {
        List docs = snapshot.docs;
        List<UserProfileModel> users = docs
            .where((doc) => (doc.data()['is_rejected']) == true)
            .map(
              (doc) => UserProfileModel.fromJson(doc.data()),
            )
            .toList();
        rejectedUsers = users;
        notifyListeners();
      } else {
        debugPrint('No users Docs Found');
      }
    } catch (e) {
      debugPrint('No User Doc Found: $e');
    }
  }

  Future<void> fetchAndOpenPDf(String documentUrl) async {
    try {
      final response = await http.get(Uri.parse(documentUrl));
      final bytes = response.bodyBytes;

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/temp.pdf');

      await file.writeAsBytes(bytes);

      openPDF('temp', file.path);
    } catch (e) {
      debugPrint('Error in fetching PDF $e');
    }
  }

  Future<void> fetchAndOpenImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final bytes = response.bodyBytes;
      final dir = await getTemporaryDirectory();
      final fileType =
          imageUrl.split('?').first.split('%2f').last.split('.').last;

      final file = File('${dir.path}/temp.$fileType');
      await file.writeAsBytes(bytes);

      final result = await OpenFilex.open(file.path);
    } catch (e) {
      debugPrint('Error in fetching image: $e');
    }
  }

  Future<void> confirmApproval(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'is_approved': true,
        'is_rejected': false,
      });
    } catch (e) {
      debugPrint('Error in confirmApproval()');
    }
  }

  Future<void> rejectApproval(String rejectionReason, String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'is_rejected': true,
        'is_approved': false,
        'rejection_reason': rejectionReason,
      });
    } catch (e) {
      debugPrint('Error in rejectApproval(String rejectionReason)');
    }
  }
}
