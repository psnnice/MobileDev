import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:up_transit/frontend/page/News.dart';
import 'package:up_transit/frontend/page/token.dart';

void showUpdateNewsDialog(BuildContext context, int id, Map<String, String> currentNews) {

  final TextEditingController _imagePathController = TextEditingController(text: currentNews["imagePath"]);
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController(text: currentNews["title"]);
  final TextEditingController _contentController = TextEditingController(text: currentNews["content"]);
  final TextEditingController _urlController = TextEditingController(text: currentNews["url"]);
  

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Update News'),
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
                  controller: _contentController,
                  decoration: InputDecoration(labelText: 'Content'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter content';
                    }
                    return null;
                  },
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
                final updatedNews = {
                  "imagePath": _imagePathController.text,
                  "title": _titleController.text,
                  "content": _contentController.text,
                  "url": _urlController.text,
                };

                final secureStorage = SecureStorage();
                final token = await secureStorage.getToken();

                final response = await http.put(
                  Uri.parse('http://$ip:8080/news/$id'),
                  headers: {"Content-Type": "application/json",
                  'Authorization': 'Bearer $token',
                  },
                  body: jsonEncode(updatedNews),
                );

                if (response.statusCode == 200) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => News()),
                  );
                }else if (response.statusCode == 400){
                  print(token);
                } 
                else {
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