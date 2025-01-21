import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:up_transit/frontend/page/configip/config.dart';
import 'package:up_transit/frontend/page/providers/user_provider.dart';
import 'package:url_launcher/url_launcher.dart'; // ใช้สำหรับเปิดลิงก์
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Basepage.dart';
import 'postFunction/AddNews.dart';
import 'updateFunction/updateNews.dart';
import 'deleteFunction/DeleteNews.dart';

var ip = Config.ip;//อย่าลืมเปลี่ยน ip

class News extends StatefulWidget {
  const News({super.key});

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<News> {
  List<dynamic> newsData = []; // เก็บข้อมูลข่าวจากฐานข้อมูล

  @override
  void initState() {
    super.initState();
    _fetchNews(); // ดึงข้อมูลจากฐานข้อมูลเมื่อเริ่มต้นแอป
  }

  // ฟังก์ชันสำหรับดึงข้อมูลจาก API
  Future<void> _fetchNews() async {
    try {
      final response = await http.get(Uri.parse('http://$ip:8080/news'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          newsData = data; // เก็บข้อมูลไว้ใน state
        });
      } else {
        throw Exception('Failed to load news');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching news: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String userRole = Provider.of<UserProvider>(context).role;
    return BasePage(
      body: Stack(
        children: [
          newsData.isEmpty
              ? const Center(child: CircularProgressIndicator()) // แสดง loading ขณะโหลด
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: newsData.length,
                  itemBuilder: (context, index) {
                    final news = newsData[index];
                    return _buildNewsCard(
                      id: news['id'],
                      imagePath: news['imagePath'],
                      title: news['title'],
                      content: news['content'],
                      url: news['url'],
                      userRole: userRole,
                    );
                  },
                ),
          if (userRole == 'admin') // แสดงเฉพาะ admin
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  showAddNewsDialog(context);
                },
                child: const Icon(Icons.add),
              ),
            ),
        ],
      ),
      index: 0,
    );
  }

  // ฟังก์ชันสร้างการ์ดข่าว
  Widget _buildNewsCard({
    required int id,
    required String imagePath,
    required String title,
    required String content,
    required String url,
    required String userRole,
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
                  child: Image.network(
                    imagePath,
                    fit: BoxFit.fill,
                    width: double.infinity,
                    height: 150,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey,
                        height: 150,
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 50),
                        ),
                      );
                    },
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
                  Icon(Icons.double_arrow_rounded, color: Colors.black),
                  SizedBox(width: 8),
                ],
              ),
            ),
            if (userRole == 'admin')
              Positioned(
                top: 8,
                right: 8,
                child: Column(
                  children: [
                    Container(
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
                                content: Text('Are you sure you want to delete this news?'),
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
                            deleteNews(context, id);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => News()),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color.fromARGB(171, 255, 255, 255)),
                        color: const Color.fromARGB(226, 255, 255, 255),
                      ),
                      child: IconButton(
                        color: Colors.blue,
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showUpdateNewsDialog(context, id, {
                            "imagePath": imagePath,
                            "title": title,
                            "content": content,
                            "url": url,
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}