import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class SecureStorage {
  final _storage = const FlutterSecureStorage();

  // ฟังก์ชันสำหรับการบันทึก token
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
    
  }

    Future<void> saveUsername(String username) async {
    await _storage.write(key: 'username', value: username);
  }

  // ฟังก์ชันสำหรับการบันทึก userId
  Future<void> saveUserId(int id) async {
    await _storage.write(key: 'user_id', value: id.toString());
  }

  // ฟังก์ชันสำหรับการดึง token
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

    // ฟังก์ชันสำหรับการดึง username
  Future<String?> getUsername() async {
    return await _storage.read(key: 'username');
  }

  // ฟังก์ชันสำหรับการดึง userId
  Future<int?> getUserId() async {
    String? idString = await _storage.read(key: 'user_id');
    return idString != null ? int.tryParse(idString) : null;
  }

  // ฟังก์ชันสำหรับการลบ token
  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

    // ฟังก์ชันสำหรับการลบ username
  Future<void> deleteUsername() async {
    await _storage.delete(key: 'username');
  }

  // ฟังก์ชันสำหรับการลบ userId
  Future<void> deleteUserId() async {
    await _storage.delete(key: 'user_id');
  }

  Future<bool> hasToken() async {
    String? token = await _storage.read(key: 'auth_token');
    return token != null;
  }
  

  // ฟังก์ชันสำหรับการทำคำสั่ง HTTP GET
  Future<http.Response> getRequest(String url) async {
    String? token = await getToken();
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }

  // ฟังก์ชันสำหรับการทำคำสั่ง HTTP POST

  // ฟังก์ชันสำหรับการทำคำสั่ง HTTP DELETE
  Future<http.Response> deleteRequest(String url) async {
    String? token = await getToken();
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }


}