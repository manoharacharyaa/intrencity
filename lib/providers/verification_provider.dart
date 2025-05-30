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
  VerificationProvider() {
    alreadyUploaded();
    wasApplicationRejected();
  }

  final Map<String, DocumentState> documents = {};

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _pendingApproval = false;
  bool get pendingApproval => _pendingApproval;

  bool _applicationWasRejected = false;
  bool get wasRejected => _applicationWasRejected;

  String _rejectionReason = '';
  String get rejectionReason => _rejectionReason;

  void _setIsLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  DocumentState getOrCreateState(String documentId) {
    return documents[documentId] ??= DocumentState();
  }

  Future<void> alreadyUploaded() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (snapshot.exists) {
      final userData = snapshot.data() as Map<String, dynamic>;
      if (userData['aadhaarUrl'] != null && userData['documentUrl'] != null) {
        _pendingApproval = true;
        notifyListeners();
      }
    }
  }

  Future<void> wasApplicationRejected() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (snapshot.exists) {
      final userData = snapshot.data() as Map<String, dynamic>;
      if (userData['aadhaarUrl'] == null &&
          userData['documentUrl'] == null &&
          userData.containsKey('rejection_reason') &&
          userData['verificationSubmittedAt'] != null) {
        _applicationWasRejected = true;
        _rejectionReason =
            '${userData['rejection_reason']} re-upload documents';
        notifyListeners();
      }
    }
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
          onViewCreated: (PDFViewController pdfViewController) {},
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

      documents['aadhaar']?.reset();
      documents['document']?.reset();

      _setIsLoading(false);
      notifyListeners();
    } catch (e) {
      debugPrint('Error submitting documents: $e');
      _setIsLoading(false);
      rethrow;
    }
  }

  Stream<List<UserProfileModel>> getPendingApplicationsStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('is_approved', isEqualTo: false)
        // .where('is_rejected', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .where((doc) {
            final data = doc.data();
            return data['aadhaarUrl'] != null && data['documentUrl'] != null;
          })
          .map((doc) => UserProfileModel.fromJson(doc.data()))
          .toList();
    });
  }

  Stream<List<UserProfileModel>> getApprovedUsersStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('is_approved', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserProfileModel.fromJson(doc.data()))
          .toList();
    });
  }

  Stream<List<UserProfileModel>> getRejectedUsersStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('is_rejected', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserProfileModel.fromJson(doc.data()))
          .toList();
    });
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

      await OpenFilex.open(file.path);
    } catch (e) {
      debugPrint('Error in fetching image: $e');
    }
  }

  Future<void> confirmApproval(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'is_approved': true,
        'is_rejected': false,
        'rejection_reason': null,
      });
    } catch (e) {
      debugPrint('Error in confirmApproval()');
    }
  }

  Future<void> rejectApproval(String rejectionReason, String uid) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userData = userDoc.data();

      if (userData?['aadhaarUrl'] != null) {
        final aadhaarRef =
            FirebaseStorage.instance.refFromURL(userData!['aadhaarUrl']);
        await aadhaarRef.delete();
      }

      if (userData?['documentUrl'] != null) {
        final documentRef =
            FirebaseStorage.instance.refFromURL(userData!['documentUrl']);
        await documentRef.delete();
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'is_rejected': true,
        'is_approved': false,
        'rejection_reason': rejectionReason,
        'aadhaarUrl': null,
        'documentUrl': null,
      });
    } catch (e) {
      debugPrint('Error in rejectApproval(): $e');
      rethrow;
    }
  }
}
