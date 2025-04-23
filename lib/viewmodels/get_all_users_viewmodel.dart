import 'package:flutter/material.dart';
import 'package:intrencity/models/user_profile_model.dart';
import 'package:intrencity/services/get_all_users_services.dart';

class GetAllUsersViewmodel extends ChangeNotifier {
  GetAllUsersViewmodel() {
    _fetchAllUsers();
  }

  bool _isLoading = false;
  List<UserProfileModel> _users = [];
  List<UserProfileModel> get users => _users;
  bool get isLoading => _isLoading;

  void _setIsLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> _fetchAllUsers() async {
    try {
      _setIsLoading(true);
      _users = await GetAllUsersServices.getAllUsers();
      notifyListeners();
      _setIsLoading(false);
    } catch (e) {
      debugPrint('_fetchAllUsers() $e');
      _setIsLoading(false);
    }
  }
}
