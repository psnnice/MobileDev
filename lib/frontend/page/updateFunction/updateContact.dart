import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:up_transit/frontend/page/Calls.dart';
import 'package:up_transit/frontend/page/token.dart';
import 'package:up_transit/frontend/page/configip/config.dart';
import 'package:up_transit/frontend/page/providers/user_provider.dart';

var ip = Config.ip;

void showUpdateContactDialog(BuildContext context, int id, Map<String, String> currentContact) {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _imagePathController = TextEditingController(text: currentContact["image_path"]);
  final TextEditingController _profileImageController = TextEditingController(text: currentContact["profile_image"]);
  final TextEditingController _titleController = TextEditingController(text: currentContact["title"]);
  final TextEditingController _emailController = TextEditingController(text: currentContact["email"]);
  final TextEditingController _phoneNumberController = TextEditingController(text: currentContact["phone_number"]);
  final TextEditingController _urlController = TextEditingController(text: currentContact["url"]);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Update Contact'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _imagePathController,
                  decoration: InputDecoration(labelText: 'Image Path'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter image path';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _profileImageController,
                  decoration: InputDecoration(labelText: 'Profile Image'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter profile image';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                ),
                TextFormField(
                  controller: _urlController,
                  decoration: InputDecoration(labelText: 'URL'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter URL';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
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
              if (_formKey.currentState!.validate()) {
                final secureStorage = SecureStorage();
                final token = await secureStorage.getToken();

                if (token == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: Missing token'), backgroundColor: Colors.red),
                  );
                  return;
                }

                // ✅ ดึง user_id จาก Provider
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                final int? userId = userProvider.id;

                final updatedContact = {
                  "image_path": _imagePathController.text,
                  "profile_image": _profileImageController.text,
                  "title": _titleController.text,
                  "email": _emailController.text.isNotEmpty ? _emailController.text : null,
                  "phone_number": _phoneNumberController.text.isNotEmpty ? _phoneNumberController.text : null,
                  "url": _urlController.text,
                  if (userId != null) "user_id": userId, // ส่ง user_id ถ้ามีค่า
                };

                final response = await http.put(
                  Uri.parse('http://$ip:8080/contacts/$id'),
                  headers: {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer $token",
                  },
                  body: jsonEncode(updatedContact),
                );

                if (response.statusCode == 200) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => Contact()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update contact'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: Text('Update'),
          ),
        ],
      );
    },
  );
}
