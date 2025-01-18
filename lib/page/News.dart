// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // ใช้สำหรับเปิดลิงก์
import 'package:flutter/services.dart'; // ใช้สำหรับโหลดไฟล์ JSON
import 'dart:convert';// ใช้สำหรับแปลง JSON
import 'package:up_transit/page/Basepage.dart';

class News extends StatefulWidget {
  const News({super.key});

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<News> {
  List<dynamic> newsData = []; // เก็บข้อมูลข่าวจาก JSON

  @override
  void initState() {
    super.initState();
    _loadJson(); // โหลด JSON เมื่อเริ่มต้นแอป
  }

  // ฟังก์ชันสำหรับโหลด JSON
  Future<void> _loadJson() async {
    final String response =
    await rootBundle.loadString('assets/jsonFile/News.json'); // โหลด JSON
    final List<dynamic> data = json.decode(response); // แปลง JSON เป็นออบเจกต์ Dart
    setState(() {
      newsData = data; // เก็บข้อมูลไว้ใน state
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: newsData.isEmpty
          ? const Center(child: CircularProgressIndicator()) // แสดง loading ขณะโหลด
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: newsData.length,
        itemBuilder: (context, index) {
          final news = newsData[index];
          return _buildContacCard(
            imagePath: news['imagePath'],
            title: news['title'],
            content: news['content'],
            url: news['url'],
          );
        },
      ), index: 0,
    );
  }

  // ฟังก์ชันสร้างการ์ดข่าว
  Widget _buildContacCard({
    required String imagePath,
    required String title,
    required String content,
    required String url,
  }) {
    return GestureDetector(
      onTap: () async {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch $url';
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 4,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // รูปภาพด้านบนของการ์ด
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.fill,
                    width: double.infinity,
                    height: 150,
                  ),
                ),
                // ข้อความหัวข้อและเนื้อหา
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        content,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // ใช้ Positioned สำหรับไอคอนมุมล่างขวา
            const Positioned(
              bottom: 8, // ระยะห่างจากขอบล่าง
              right: 8,  // ระยะห่างจากขอบขวา
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Read more',
                    style: TextStyle(fontSize: 16),
                  ),
                  Icon(Icons.double_arrow_rounded , color: Colors.black),
                  SizedBox(width: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}