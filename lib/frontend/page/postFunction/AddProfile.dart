import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:up_transit/frontend/page/configip/config.dart';
import 'package:up_transit/frontend/page/token.dart';
var ip = Config.ip;

void showAddProfileDialog(BuildContext context) {
  // final _formKey = GlobalKey<FormState>();
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
        title: Text('Add Profile Picture'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.add_photo_alternate_rounded),
                      onPressed: () => _pickImage(setState),
                    ),
                    SizedBox(width: 8),
                    Text(_imageFile != null ? 'Image Selected' : 'No Image Selected'),
                    if (_imageFile != null)
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Image.file(
                            _imageFile!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            bottom: 35,
                            left: 35,
                            child: IconButton(
                              icon: Icon(
                                Icons.cancel_outlined,
                                color: Colors.red,
                                size: 25,
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
                int? userId = await SecureStorage().getUserId() as int?;
                final profileData = {
                  "profile_image_path": base64Encode(_imageFile!.readAsBytesSync()),
                  "user_id": userId,
                };
                final token = await SecureStorage().getToken();
                print('Uploading to: http://$ip:8080/user_profile/$userId');
                final response = await http.post(
                  Uri.parse('http://$ip:8080/user_profile/$userId'),
                  headers: {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer $token",
                  },
                  body: jsonEncode(profileData),
                );
                if (response.statusCode == 200) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                     // ปิด Dialog
                    SnackBar(
                      content: Text('${response.body}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
              else {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(
                        
                        'Please select an image',
                        textAlign: TextAlign.center, // ทำให้ข้อความอยู่ตรงกลาง
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              }
              Navigator.of(context).pop();
            },
            child: Text('Upload'),
            
          ),
        ],
      );
    },
  );
}