import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:up_transit/frontend/page/postFunction/AddProfile.dart';
import 'package:up_transit/frontend/page/providers/user_provider.dart';
import 'dart:io';

final _storage = FlutterSecureStorage();

void _logout(BuildContext context) async {
  // ลบ Token ออกจาก Secure Storage
  await _storage.delete(key: 'token');

  // ปิดแอป
  SystemNavigator.pop();
}

class SidebarButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu),
      color: Colors.black,
      onPressed: () {
        Scaffold.of(context).openEndDrawer(); // เปิด Sidebar ทางขวา
      },
    );
  }
}

class EndDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final username = userProvider.username; // สมมติว่ามี username ใน Provider
    final profileImagePath = userProvider.profileImagePath; // ดึง path ของรูปโปรไฟล์จาก Provider

    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(
              username,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: profileImagePath != null
                  ? FileImage(File(profileImagePath))
                  : NetworkImage("https://i.pravatar.cc/300"), // รูปโปรไฟล์สุ่ม
            ),
            accountEmail: null,
          ),

          // ✅ ปุ่มโพสรูปโปรไฟล์
          ListTile(
            leading: Icon(Icons.add_a_photo, color: Colors.blue),
            title: ElevatedButton(
              onPressed: () {
                showAddProfileDialog(context);
              },
              child: Text(
                'Edit Profile Picture',
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ),
          ),

          Spacer(), // ดันปุ่ม Logout ไปด้านล่าง

          // ✅ ปุ่ม Logout
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text("Logout",
                style: TextStyle(fontSize: 16, color: Colors.red)),
            onTap: () {
              _logout(context);
            },
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}