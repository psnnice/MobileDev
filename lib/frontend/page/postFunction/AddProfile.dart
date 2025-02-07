import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:up_transit/frontend/page/configip/config.dart';
import 'package:up_transit/frontend/page/providers/user_provider.dart';
import 'package:up_transit/frontend/page/token.dart';

var ip = Config.ip;

void showAddProfileDialog(BuildContext context) {
  File? _imageFile;

  Future<void> _pickImage(StateSetter setState) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Edit Profile Picture'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.add_photo_alternate_rounded),
                  onPressed: () => _pickImage(setState),
                ),
                SizedBox(height: 8),
                Text(_imageFile != null ? 'Image Selected' : 'No Image Selected'),
                if (_imageFile != null)
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Image.file(
                        _imageFile!,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: -10,
                        right: -10,
                        child: IconButton(
                          icon: Icon(
                            Icons.cancel_outlined,
                            color: const Color.fromARGB(255, 0, 0, 0),
                            size: 40,
                          ),
                          onPressed: () {
                            setState(() {
                              _imageFile = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_imageFile != null) {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                final int? userId = userProvider.id;
                final profileData = {
                  "user_id": userId,
                  "profile_image_path": _imageFile!.path,
                };

                final secureStorage = SecureStorage();
                final token = await secureStorage.getToken();
                final response = await http.post(
                  Uri.parse('http://$ip:8080/user_profile/'),
                  headers: {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer $token",
                  },
                  body: jsonEncode(profileData),
                );

                if (response.statusCode == 201 || response.statusCode == 200) {
                  // อัปเดตโปรไฟล์ใน Provider
                  userProvider.setProfileImagePath(_imageFile!.path);

                  Navigator.of(context).pop(); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Profile picture uploaded successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${response.statusCode}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please select an image first!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: Text('Upload'),
          ),
        ],
      );
    },
  );
}