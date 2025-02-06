import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:up_transit/frontend/page/News.dart';
import 'package:up_transit/frontend/page/token.dart';

void showUpdateNewsDialog(BuildContext context, int id, Map<String, String> currentNews) {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController(text: currentNews["title"]);
  final TextEditingController _contentController = TextEditingController(text: currentNews["content"]);
  final TextEditingController _urlController = TextEditingController(text: currentNews["url"]);
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
        title: Text('Update News'),
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
                          onPressed: () => _pickImage(setState),
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
                              hintText: 'Title',
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
                            controller: _contentController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Content',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter content';
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
                              hintText: 'URL',
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
                final updatedNews = {
                  "imagePath": _imageFile != null ? base64Encode(_imageFile!.readAsBytesSync()) : currentNews["imagePath"] ?? '',
                  "title": _titleController.text,
                  "content": _contentController.text,
                  "url": _urlController.text,
                };

                final secureStorage = SecureStorage();
                final token = await secureStorage.getToken();

                final response = await http.put(
                  Uri.parse('http://$ip:8080/news/$id'),
                  headers: {
                    "Content-Type": "application/json",
                    'Authorization': 'Bearer $token',
                  },
                  body: jsonEncode(updatedNews),
                );

                if (response.statusCode == 200) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => News()),
                  );
                } else if (response.statusCode == 400) {
                  print(token);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update news'),
                      backgroundColor: Colors.red,
                    ),
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