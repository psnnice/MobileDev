import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:restart_app/restart_app.dart';
import 'package:up_transit/frontend/page/postFunction/AddProfile.dart';
import 'package:up_transit/frontend/page/token.dart';

Future<String?> fetchProfileImage(int userId) async {
  final token = await SecureStorage().getToken(); // ดึง token จาก SecureStorage

  if (token == null) {
    print('No token found.');
    return null;
  }

  final url = Uri.parse('http://$ip:8080/user_profile/$userId');
  final response = await http.get(
    url,
    headers: {
      "Authorization": "Bearer $token", // เพิ่ม token เข้าไปใน header
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['profile_image_path']; // base64 string
  } else if (response.statusCode == 401) {
    print('Unauthorized: Invalid or expired token');
    return null;
  } else {
    print('Failed to load profile image: ${response.statusCode}');
    return null;
  }
}


final _storage = FlutterSecureStorage();

Future<void> _logout(BuildContext context) async {
  final secureStorage = SecureStorage();
  await secureStorage.deleteToken();
  await secureStorage.deleteUsername();
  await secureStorage.deleteUserId();
  Restart.restartApp();
}

class SidebarButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu),
      color: Colors.black,
      onPressed: () {
        Scaffold.of(context).openEndDrawer();
      },
    );
  }
}

class EndDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          FutureBuilder<String?>(
            future: SecureStorage().getUsername(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final username = snapshot.data ?? 'Guest';
                return FutureBuilder<String?>(
                  future: SecureStorage().getUserId().then((userId) {
                    if (userId != null) {
                      int parsedUserId = userId.toInt();
                      return fetchProfileImage(parsedUserId);
                    }
                    return Future.value(null);
                  }),
                  builder: (context, profileSnapshot) {
                    if (profileSnapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (profileSnapshot.hasError) {
                      return Text('Error: ${profileSnapshot.error}');
                    } else {
                      final profileImageBase64 = profileSnapshot.data;
                      return UserAccountsDrawerHeader(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.purple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        accountName: Text(
                          username,
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold ,fontFamily: 'YourFontFamily' ),
                        ),
                        currentAccountPicture: GestureDetector(
                          onTap: () {
                            if (profileImageBase64 != null) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.memory(base64Decode(profileImageBase64)),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Close'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }
                          },
                          child: CircleAvatar(
                            backgroundImage: profileImageBase64 != null
                                ? MemoryImage(base64Decode(profileImageBase64))
                                : null,
                            child: profileImageBase64 == null
                                ? Icon(Icons.person, size: 40, color: Colors.grey)
                                : null,
                          ),
                        ),
                        accountEmail: null,
                      );
                    }
                  },
                );
              }
            },
          ),
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
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirm Delete'),
                      content: Text(
                        'Are you sure you want to delete your profile picture?',
                        textAlign: TextAlign.center,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // ปิด AlertDialog
                          },
                          child: Text('Cancel', style: TextStyle(color: Colors.black)),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop(); // ปิด AlertDialog

                            final userId = await SecureStorage().getUserId();
                            if (userId != null) {
                              final token = await SecureStorage().getToken();
                              final response = await http.delete(
                                Uri.parse('http://$ip:8080/user_profile/$userId'),
                                headers: {
                                  "Authorization": "Bearer $token",
                                },
                              );

                              if (response.statusCode == 200) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Profile picture deleted successfully')),
                                );
                                Navigator.of(context).pop(); // ปิด Drawer
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to delete profile picture')),
                                );
                              }
                            }
                          },
                          child: Text('Yes, Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text(
                'Delete Profile Picture',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),

          Spacer(),
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