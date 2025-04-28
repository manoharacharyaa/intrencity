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
      if (searchController.text != _lastWords) {
        _lastWords = searchController.text;
        voiceSearchSpace();
      }
    });
  }

  Future<void> _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onError: (error) {
          debugPrint("Speech-to-Text Error: $error");
          _isListening = false;
          notifyListeners();
        },
        onStatus: (status) {
          debugPrint("Speech-to-Text Status: $status");
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            notifyListeners();
          }
        },
      );
      notifyListeners();
    } catch (e) {
      debugPrint("Error initializing Speech-to-Text: $e");
      _speechEnabled = false;
      _isListening = false;
      notifyListeners();
    }
  }

  Future<void> startListening() async {
    try {
      if (!_speechEnabled) {
        await _initSpeech();
      }

      if (_speechEnabled) {
        _isListening = true;
        notifyListeners();

        await _speechToText.listen(
          onResult: _onSpeechResult,
          listenFor: const Duration(seconds: 30),
          localeId: "en_US",
          cancelOnError: true,
          partialResults: true,
        );

        _timer?.cancel();
        _timer = Timer(const Duration(seconds: 5), stopListening);
      } else {
        debugPrint("Speech recognition not enabled");
      }
    } catch (e) {
      debugPrint("Error in startListening: $e");
      _isListening = false;
      notifyListeners();
    }
  }

  Future<void> stopListening() async {
    _timer?.cancel();
    await _speechToText.stop();
    _isListening = false;
    notifyListeners();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    debugPrint("Speech result: ${result.recognizedWords}");
    _lastWords = result.recognizedWords;
    searchController.text = _lastWords;
    if (result.finalResult) {
      voiceSearchSpace();
      stopListening();
    }
  }

  Future<void> voiceSearchSpace() async {
    try {
      String searchTerm = _lastWords.toLowerCase().trim();
      if (searchTerm.isEmpty) {
        searchParkingSpace = [];
      } else {
        List<ParkingSpacePostModel> spaces = await fetchSpaces();
        searchParkingSpace = spaces.where((space) {
          return space.spaceLocation.toLowerCase().contains(searchTerm) ||
              space.spaceName.toLowerCase().contains(searchTerm);
        }).toList();
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error in voiceSearchSpace: $e");
      searchParkingSpace = [];
      notifyListeners();
    }
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
    _lastWords = '';
    searchParkingSpace = [];
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    _timer?.cancel();
    _speechToText.cancel();
    super.dispose();
  }
}
