import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intrencity/models/user_profile_model.dart';
import 'package:intrencity/services/users_services.dart';

class GetAllUsersViewmodel extends ChangeNotifier {
  GetAllUsersViewmodel() {
    _fetchAllUsers();
    _initializeCurrentUserStream();
  }

  bool _isLoading = false;
  List<UserProfileModel> _users = [];
  UserProfileModel? _currentUser;
  StreamSubscription<UserProfileModel?>? _userSubscription;

  // Getters
  List<UserProfileModel> get users => _users;
  bool get isLoading => _isLoading;
  UserProfileModel? get currentUser => _currentUser;
  bool get isApproved => _currentUser?.isApproved ?? false;
  String? get uid => GetAllUsersServices.currentUserId;

  void _setIsLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> _fetchAllUsers() async {
    try {
      _setIsLoading(true);
      _users = await GetAllUsersServices.getAllUsers();
      notifyListeners();
    } catch (e) {
      debugPrint('_fetchAllUsers() $e');
    } finally {
      _setIsLoading(false);
    }
  }

  void _initializeCurrentUserStream() {
    _userSubscription = GetAllUsersServices.getCurrentUserStream().listen(
      (user) {
        _currentUser = user;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error in user stream: $error');
      },
    );
  }

  void clearCurrentUser() {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> resetCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get the current user snapshot once
      _currentUser = await GetAllUsersServices.getCurrentUserStream().first;
    } catch (e) {
      debugPrint('Error resetting current user: $e');
      _currentUser = null; // Ensure current user is cleared on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
