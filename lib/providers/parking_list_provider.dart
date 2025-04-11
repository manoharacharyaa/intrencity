import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intrencity/models/parking_space_post_model.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ParkingListProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SpeechToText _speechToText = SpeechToText();
  final TextEditingController searchController = TextEditingController();

  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';
  final String _profilePic = '';
  Timer? _timer;
  List<ParkingSpacePostModel> searchParkingSpace = [];
  late Future<List<ParkingSpacePostModel>> _fetchSpaces;

  // Getters
  bool get isListening => _isListening;
  bool get speechEnabled => _speechEnabled;
  String get lastWords => _lastWords;
  String get profilePic => _profilePic;
  String? get uid => _auth.currentUser?.uid;
  bool get isUserLoggedIn => _auth.currentUser != null;

  ParkingListProvider() {
    _initSpeech();
    _setupSearchListener();
    _fetchSpaces = fetchSpaces();
  }

  void _setupSearchListener() {
    searchController.addListener(() {
      _lastWords = searchController.text;
      voiceSearchSpace();
    });
  }

  void _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onError: (error) => debugPrint("Speech-to-Text Error: $error"),
        onStatus: (status) => debugPrint("Speech-to-Text Status: $status"),
      );
      notifyListeners();
    } catch (e) {
      debugPrint("Error initializing Speech-to-Text: $e");
    }
  }

  void startListening() async {
    if (_speechEnabled) {
      _isListening = true;
      notifyListeners();

      await _speechToText.listen(onResult: _onSpeechResult);
      _timer = Timer(const Duration(seconds: 5), stopListening);
    }
  }

  void stopListening() async {
    _timer?.cancel();
    await _speechToText.stop();
    _isListening = false;
    notifyListeners();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    _lastWords = result.recognizedWords;
    searchController.text = _lastWords;
    voiceSearchSpace();
    stopListening();
  }

  void voiceSearchSpace() async {
    String searchTerm = _lastWords.toLowerCase();
    List<ParkingSpacePostModel> spaces = await fetchSpaces();
    searchParkingSpace = spaces.where((space) {
      return space.spaceLocation.toLowerCase().contains(searchTerm);
    }).toList();
    notifyListeners();
  }

  Future<List<ParkingSpacePostModel>> fetchSpaces() async {
    QuerySnapshot querySnapshot = await _firestore.collection('spaces').get();
    return querySnapshot.docs.map((doc) {
      return ParkingSpacePostModel.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  Stream<DocumentSnapshot> getUserStream() {
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  Stream<QuerySnapshot> getSpacesStream() {
    return _firestore.collection('spaces').snapshots();
  }

  void clearSearch() {
    searchController.clear();
  }

  @override
  void dispose() {
    searchController.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
