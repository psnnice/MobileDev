import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _role = '';
  String _username = '';
  int? _id = null;

  String get username => _username;
  int? get id => _id;
  String get role => _role;

  void setRole(String role) {
    _role = role;
    notifyListeners();
  }

  void setUser(String username, int id) {
    _username = username;
    _id = id;
    notifyListeners(); // แจ้งเตือนให้ UI อัปเดต
  }

  void clearUser() {
    _username = '';
    _id = null;
    notifyListeners();
  }
}