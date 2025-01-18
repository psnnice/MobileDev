// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // ใช้สำหรับเปิดลิงก์
import 'package:flutter/services.dart'; // ใช้สำหรับโหลดไฟล์ JSON
import 'dart:convert';// ใช้สำหรับแปลง JSON
import 'package:up_transit/page/Basepage.dart';
class Contact extends StatefulWidget {
  const Contact({super.key});

  @override
  
  _ContacPageState createState() => _ContacPageState();
}

class _ContacPageState extends State<Contact> {
  List<dynamic> contactData = []; // เก็บข้อมูลข่าวจาก JSON

  @override
  void initState() {
    super.initState();
    _loadJson(); // โหลด JSON เมื่อเริ่มต้นแอป
  }

  // ฟังก์ชันสำหรับโหลด JSON
  Future<void> _loadJson() async {
    final String response =
    await rootBundle.loadString('assets/jsonFile/Contact.json'); // โหลด JSON
    final List<dynamic> data = json.decode(response); // แปลง JSON เป็นออบเจกต์ Dart
    setState(() {
      contactData = data; // เก็บข้อมูลไว้ใน state
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: contactData.isEmpty
          ? const Center(child: CircularProgressIndicator()) // แสดง loading ขณะโหลด
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: contactData.length,
        itemBuilder: (context, index) {
          final contact = contactData[index];
          return _buildContacCard(
            imagePath: contact['imagePath'],
            profileImage: contact['profileImage'],
            title: contact['title'],
            email: contact['email'],
            phoneNumber: contact['phoneNumber'],
            url: contact['url'],
          );
        },
      ), index: 4,
    );
  }

  // ฟังก์ชันสร้างการ์ดข่าว
  Widget _buildContacCard({
    required String imagePath,
    required String profileImage,
    required String title,
    required String email,
    required String phoneNumber,
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
                      // Title + profile
                      Row(
                        children: [
                          // รูปภาพพร้อมกรอบวงกลม
                          ClipOval(
                            child: Image.asset(
                              profileImage, // ใส่รูปภาพที่ต้องการ
                              width: 40, // ขนาดของวงกลม
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 20), // เว้นระยะห่างระหว่าง Icon และ Title
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),


                      // email + Icon
                      if (email.trim().isNotEmpty)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.email_rounded , color: Colors.black),
                          const SizedBox(width: 10), // เว้นระยะห่างระหว่าง Icon และ Text
                          Expanded(
                            child: Text(
                              email,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      //phoneNumber + icon
                      if (phoneNumber.trim().isNotEmpty)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.phone_forwarded_rounded , color: Colors.black),
                          const SizedBox(width: 10), // เว้นระยะห่างระหว่าง Icon และ Text
                          Expanded(
                            child: Text(
                              phoneNumber,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
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
                  Icon(Icons.double_arrow_rounded, color: Colors.black),
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