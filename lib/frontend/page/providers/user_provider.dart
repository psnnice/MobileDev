import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _role = '';
  String _username = '';
  int? _id = null;
  String? _profileImagePath; // เพิ่มตัวแปรสำหรับเก็บ path ของรูปโปรไฟล์

  String get username => _username;
  int? get id => _id;
  String get role => _role;
  String? get profileImagePath => _profileImagePath; // เพิ่ม getter สำหรับ profileImagePath

  void setRole(String role) {
    _role = role;
    notifyListeners();
  }

  void setUser(String username, int id) {
    _username = username;
    _id = id;
    notifyListeners(); // แจ้งเตือนให้ UI อัปเดต
  }

  void setProfileImagePath(String path) {
    _profileImagePath = path;
    notifyListeners(); // แจ้งเตือนให้ UI อัปเดต
  }

  void clearUser() {
    _username = '';
    _id = null;
    _profileImagePath = null; // ล้างข้อมูล profileImagePath ด้วย
    notifyListeners();
  }
}