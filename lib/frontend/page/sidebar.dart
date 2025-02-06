import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:up_transit/frontend/page/providers/user_provider.dart';
  final _storage = FlutterSecureStorage();
  void _logout(BuildContext context) async {
    // Handle logout logic here
      await _storage.delete(key: 'token');
    Navigator.pushReplacementNamed(context, '/login');
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
    final username = userProvider.username; // Assuming username is a property in UserProvider

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            accountEmail: Text("johndoe@example.com"),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(
                  "https://i.pravatar.cc/300"), // รูปโปรไฟล์สุ่ม
            ),
          ),

          // ✅ รายการเมนู
          Spacer(), // ดัน Logout ไปด้านล่าง

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

  // ฟังก์ชันสร้างเมนู Drawer
  Widget _buildDrawerItem(IconData icon, String title, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title, style: TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.pop(context);
        print("$title clicked");
      },
    );
  }
}