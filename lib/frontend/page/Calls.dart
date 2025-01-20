import 'dart:convert'; // ใช้สำหรับแปลง JSON

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // ใช้สำหรับดึงข้อมูลจาก API
import 'package:provider/provider.dart';
import 'package:up_transit/frontend/page/configip/config.dart';
import 'package:up_transit/frontend/page/deleteFunction/DeleteContact.dart';
import 'package:up_transit/frontend/page/postFunction/AddContact.dart';
import 'package:up_transit/frontend/page/providers/user_provider.dart';
import 'package:url_launcher/url_launcher.dart'; // ใช้สำหรับเปิดลิงก์

import 'Basepage.dart';

var ip = Config.ip; // อย่าลืมเปลี่ยน IP

class Contact extends StatefulWidget {
  const Contact({super.key});

  @override
  _ContacPageState createState() => _ContacPageState();
}

class _ContacPageState extends State<Contact> {
  List<dynamic> contactData = []; // เก็บข้อมูลข่าวจาก API

  @override
  void initState() {
    super.initState();
    _fetchContact(); // ดึงข้อมูลเมื่อเริ่มต้นแอป
  }

  // ฟังก์ชันดึงข้อมูลจาก API
  Future<void> _fetchContact() async {
    try {
      final response = await http.get(Uri.parse('http://$ip:8080/contacts')); // URL ของ API
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          // แปลง null เป็นช่องว่าง
          contactData = data.map((contact) {
            return {
              "id"            : contact["id"]           ?? "",
              "imagePath"     : contact["imagePath"]    ?? "",
              "profileImage"  : contact["profileImage"] ?? "",
              "title"         : contact["title"]        ?? "",
              "email"         : contact["email"]        ?? "",
              "phoneNumber"   : contact["phoneNumber"]  ?? "",
              "url"           : contact["url"]          ?? "",
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load contacts');
      }
    } catch (e) {
      debugPrint('Error fetching contacts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String userRole = Provider.of<UserProvider>(context).role;
    

    return BasePage(
      body: Stack(
        children: [
          contactData.isEmpty
              ? const Center(child: CircularProgressIndicator()) // แสดง loading ขณะโหลด
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: contactData.length,
                  itemBuilder: (context, index) {
                    final contact = contactData[index];
                    return _buildContactCard(
                      id: contact['id'],
                      imagePath: contact['imagePath'],
                      profileImage: contact['profileImage'],
                      title: contact['title'],
                      email: contact['email'],
                      phoneNumber: contact['phoneNumber'],
                      url: contact['url'],
                    );
                  },
                ),
          if (userRole == 'admin')
            Positioned(
              bottom: 16.0,
              right: 16.0,
              child: FloatingActionButton(
                onPressed: () {
                  showAddContactDialog(context);
                },
                child: Icon(Icons.add),
              ),
            ),
        ],
      ),
      index: 4,
    );
  }

  // ฟังก์ชันสร้างการ์ด
  Widget _buildContactCard({
    required int id,
    required String imagePath,
    required String profileImage,
    required String title,
    required String email,
    required String phoneNumber,
    required String url,
  }) 

  
  {
    String userRole = Provider.of<UserProvider>(context).role; // เก็บข้อมูลข่าวจาก API
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
                  child: Image.network(
                    imagePath,
                    fit: BoxFit.fill,
                    width: double.infinity,
                    height: 150,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 150),
                  ),
                ),
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
                            child: Image.network(
                              profileImage,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 40),
                            ),
                          ),
                          const SizedBox(width: 20),
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
                      if (email.trim().isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.email_rounded, color: Colors.black),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                email,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 10),
                      if (phoneNumber.trim().isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.phone_forwarded_rounded, color: Colors.black),
                            const SizedBox(width: 10),
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
            if (userRole == 'admin')
  Positioned(
    top: 8,
    right: 8,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color.fromARGB(171, 255, 255, 255)),
        color: const Color.fromARGB(226, 255, 255, 255),
      ),
      child: IconButton(
        color: Colors.red,
        icon: const Icon(Icons.delete),
        onPressed: () async {
          bool confirm = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Confirm Deletion'),
                content: Text('Are you sure you want to delete this contact?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Text('Delete'),
                  ),
                ],
              );
            },
          );
          if (confirm) {
            deleteContact(context, id);
          }
        },
      ),
    ),
  ),
            const Positioned(
              bottom: 8,
              right: 8,
              child: Row(
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
