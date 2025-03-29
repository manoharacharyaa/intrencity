import 'package:flutter/material.dart';

class AuthValidationProvider extends ChangeNotifier {
  bool isVisible = false;
  bool isEqual = false;
  bool isEmpty = true;
  bool error = false;
  String? selectedCountry;
  bool passwordEmpty = true;
  bool isLoading = false;

  void invertIsVisible() {
    isVisible = !isVisible;
    notifyListeners();
  }

  void validatePassword(String passsword, String confirmPassword) {
    if (passsword == confirmPassword) {
      isEqual = true;
    } else {
      isEqual = false;
    }
    notifyListeners();
  }

  void emptyCheck(String confirmPassword) {
    if (confirmPassword.isNotEmpty) {
      isEmpty = false;
    }
    notifyListeners();
  }

  void passwordIsEmpty(String password) {
    if (password.isNotEmpty) {
      passwordEmpty = false;
    }
    notifyListeners();
  }

  void country(String country) {
    selectedCountry = country;
    notifyListeners();
  }

  void setError(bool isError) {
    error = isError;
    notifyListeners();
  }

  void loading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }
}
