import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:up_transit/frontend/page/News.dart';

List<Map<String, String>> newsData = [];

void showAddNewsDialog(BuildContext context) {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _imagePathController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add News'),
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
                final newNews = {
                  "imagePath" : _imagePathController.text,
                  "title"     : _titleController.text,
                  "content"   : _contentController.text,
                  "url"       : _urlController.text,
                };

                newsData.add(newNews);

                final response = await http.post(
                  Uri.parse('http://$ip:8080/news'),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode(newNews),
                );

                if (response.statusCode == 201) {
                  Navigator.of(context).pop();

                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => News()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add news'),
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