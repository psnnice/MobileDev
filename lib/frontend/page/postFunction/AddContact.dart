import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:up_transit/frontend/page/Calls.dart';
import 'package:up_transit/frontend/page/providers/user_provider.dart';
import 'package:up_transit/frontend/page/token.dart';

List<Map<String, dynamic>> contactData = [];

void showAddContactDialog(BuildContext context) {
  final _formKey = GlobalKey<FormState>();
  // final TextEditingController _imagePathController = TextEditingController();
  // final TextEditingController _profileImageController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  File? _imageFile;
  File? _profileImageFile;

  Future<void> _pickImage(StateSetter setState, bool isProfileImage) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isProfileImage) {
          _profileImageFile = File(pickedFile.path);
        } else {
          _imageFile = File(pickedFile.path);
        }
      });
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add Contact'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.add_photo_alternate_rounded),
                          onPressed: () => _pickImage(setState, false),
                        ),
                        SizedBox(width: 8),
                        Text(_imageFile != null ? 'Image Selected' : 'No Image Selected'),
                        SizedBox(width: 10),
                        if (_imageFile != null)
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                child: Image.file(
                                  _imageFile!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                bottom: 15,
                                left: 15,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.cancel_outlined,
                                    color: Colors.red,
                                    size: 15,
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
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.add_photo_alternate_rounded),
                          onPressed: () => _pickImage(setState, true),
                        ),
                        SizedBox(width: 8),
                        Text(_profileImageFile != null ? 'Profile Image Selected' : 'No Profile Image Selected'),
                        SizedBox(width: 10),
                        if (_profileImageFile != null)
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                child: Image.file(
                                  _profileImageFile!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                bottom: 15,
                                left: 15,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.cancel_outlined,
                                    color: Colors.red,
                                    size: 15,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _profileImageFile = null;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Contact Name',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter title';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Email',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter email';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: TextFormField(
                            controller: _phoneNumberController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Phone Number',
                            ),
                            keyboardType: TextInputType.phone,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter phone number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: TextFormField(
                            controller: _urlController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Contact URL',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter URL';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
              if (_formKey.currentState!.validate()) {
                final newContact = {
                  "imagePath": _imageFile != null ? base64Encode(_imageFile!.readAsBytesSync()) : '',
                  "profileImage": _profileImageFile != null ? base64Encode(_profileImageFile!.readAsBytesSync()) : '',
                  "title": _titleController.text,
                  "email": _emailController.text,
                  "phoneNumber": _phoneNumberController.text,
                  "url": _urlController.text,
                  "user_id": Provider.of<UserProvider>(context, listen: false).id,
                };

                contactData.add(newContact);
                final secureStorage = SecureStorage();
                final token = await secureStorage.getToken();
                final response = await http.post(
                  Uri.parse('http://$ip:8080/contacts'),
                  headers: {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer $token",
                  },
                  body: jsonEncode(newContact),
                );

                if (response.statusCode == 201) {
                  Navigator.of(context).pop();

                  // รีเฟรชหน้า
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