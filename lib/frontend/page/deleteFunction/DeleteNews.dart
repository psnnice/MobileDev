import 'package:flutter/material.dart';
import 'package:up_transit/frontend/page/News.dart';
import 'package:up_transit/frontend/page/token.dart';

Future<void> deleteNews(BuildContext context, int id) async {
  final url = Uri.parse('http://$ip:8080/news/$id');
  final SecureStorage secureStorage = SecureStorage();

  try {
    final response = await secureStorage.deleteRequest(url.toString());

    if (response.statusCode == 200) {
      // ลบสำเร็จ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('News deleted successfully')),
      );
      // อัปเดต UI หรือรีเฟรชรายการการ์ด (สามารถเพิ่ม callback เพื่อรีเฟรชได้)
    } else {
      // ลบไม่สำเร็จ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete News: ${response.body}')),
      );
    }
  } catch (error) {
    // จัดการข้อผิดพลาด
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $error')),
    );
  }
}