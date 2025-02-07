import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:up_transit/frontend/page/News.dart';
import 'package:up_transit/frontend/page/configip/config.dart';
import 'package:up_transit/frontend/page/providers/user_provider.dart';
import 'package:up_transit/frontend/page/token.dart';

var ip = Config.ip;

void showUpdateNewsDialog(BuildContext context, int id, Map<String, dynamic> currentNews) {
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
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final int? userId = userProvider.id;

      return AlertDialog(
        title: const Text('Update News'),
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
                          icon: const Icon(Icons.add_photo_alternate_rounded),
                          onPressed: () => _pickImage(setState),
                        ),
                        const SizedBox(width: 8),
                        Text(_imageFile != null ? 'Image Selected' : 'No Image Selected'),
                        
                        SizedBox(width: 10),
                        if (_imageFile != null)
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                child: Image.file(
                                  _imageFile!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                bottom: 35,
                                left: 35,
                                child: IconButton(
                                  icon: Icon(Icons.cancel_outlined,   
                                  color: Colors.red,              
                                  size: 25
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
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: 'Content',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter content';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        labelText: 'URL',
                        border: OutlineInputBorder(),
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final secureStorage = SecureStorage();
                final token = await secureStorage.getToken();

                if (token == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error: Missing token'), backgroundColor: Colors.red),
                  );
                  return;
                }
                print(userId);
                final updatedNews = {
                  "id": id,
                  "title": _titleController.text,
                  "content": _contentController.text,
                  "url": _urlController.text,
                  "imagePath": _imageFile != null ? base64Encode(_imageFile!.readAsBytesSync()) : currentNews["imagePath"],
                  "created_by": userId,
                  "created_at": currentNews["created_at"] ?? DateTime.now().toString(),
                };

                final response = await http.put(
                  Uri.parse('http://$ip:8080/news/$id'),
                  headers: {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer $token",
                  },
                  body: jsonEncode(updatedNews),
                );

                if (response.statusCode == 200) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const News()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update news'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      );
    },
  );
}
