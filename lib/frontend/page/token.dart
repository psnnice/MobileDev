import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class SecureStorage {
  final _storage = const FlutterSecureStorage();

  // ฟังก์ชันสำหรับการบันทึก token
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  // ฟังก์ชันสำหรับการดึง token
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // ฟังก์ชันสำหรับการลบ token
  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
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