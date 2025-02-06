import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:up_transit/frontend/page/Calls.dart';
import 'package:up_transit/frontend/page/token.dart';
import 'package:up_transit/frontend/page/providers/user_provider.dart';

List<Map<String, dynamic>> contactData = [];

void showAddContactDialog(BuildContext context) {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _imagePathController = TextEditingController();
  final TextEditingController _profileImageController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add Contact'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _imagePathController,
                  decoration: InputDecoration(labelText: 'Image link'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter image path';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _profileImageController,
                  decoration: InputDecoration(labelText: 'Profile Image link'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter profile image';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Contact Name'),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _urlController,
                  decoration: InputDecoration(labelText: 'Contact URL'),
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
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                final int? userId = userProvider.id; // ดึง user_id จาก Provider
                final secureStorage = SecureStorage();
                final token = await secureStorage.getToken();

                final newContact = {
                  "image_path": _imagePathController.text,
                  "profile_image": _profileImageController.text,
                  "title": _titleController.text,
                  "email": _emailController.text,
                  "phone_number": _phoneNumberController.text,
                  "url": _urlController.text,
                  "user_id": userId, // เพิ่ม user_id ลงไป
                };

                // ส่งข้อมูลไปยัง API
                final response = await http.post(
                  Uri.parse('http://$ip:8080/contacts'),
                  headers: {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer $token"
                  },
                  body: jsonEncode(newContact),
                );

                if (response.statusCode == 201) {
                  contactData.add(newContact);
                  Navigator.of(context).pop(); // ปิดป๊อปอัป
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => Contact()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add contact: ${response.body}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text('Add'),
          ),
        ],
      );
    },
  );
}