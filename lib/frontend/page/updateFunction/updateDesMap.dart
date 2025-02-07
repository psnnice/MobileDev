import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:up_transit/frontend/page/Map.dart';
import 'package:up_transit/frontend/page/configip/config.dart'; // Add this import
import 'package:up_transit/frontend/page/providers/user_provider.dart';
import 'package:up_transit/frontend/page/token.dart';

var ip = Config.ip;

class RouteDescriptionData {
  final int id;
  final String routeName;
  final String description;
  final String stationList;
  final String note;
  final String? imagePath;
  final int? createdBy;
  final String? createdAt;

  RouteDescriptionData({
    required this.id,
    required this.routeName,
    required this.description,
    required this.stationList,
    required this.note,
    this.imagePath,
    this.createdBy,
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'route_name': routeName,
        'description': description,
        'station_list': stationList,
        'note': note,
        'image_path': imagePath,
        'created_by': createdBy,
        'created_at': DateTime.now().toString(),
      };
}

void showUpdateDescriptionDialog(BuildContext context, int id, Map<String, dynamic> currentData) {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _routeName = TextEditingController(text: currentData["route_name"]);
  final TextEditingController _descriptionController = TextEditingController(text: currentData["description"]);
  final TextEditingController _stationListController = TextEditingController(text: currentData["station_list"]);
  final TextEditingController _noteController = TextEditingController(text: currentData["note"] ?? "");

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
      final int? createBy = userProvider.id;
      return AlertDialog(
        title: Text('Update Route Description'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _routeName,
                      decoration: const InputDecoration(
                        labelText: 'Route Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter route name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
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
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                bottom: 30,
                                left: 30,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.cancel_outlined,
                                    color: Colors.red,
                                    size: 30,
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
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 150, // กำหนดความสูงของกล่อง
                      child: TextFormField(
                        controller: _stationListController,
                        decoration: const InputDecoration(
                          labelText: 'Station List',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: null,
                        expands: true,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note',
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

                final updatedData = RouteDescriptionData(
                  id: id,
                  routeName: _routeName.text,
                  description: _descriptionController.text,
                  stationList: _stationListController.text,
                  note: _noteController.text,
                  imagePath: _imageFile != null ? base64Encode(_imageFile!.readAsBytesSync()) : currentData["image"] ?? '',
                  createdBy: createBy,
                  createdAt: DateTime.now().toString(),
                ).toJson();

                final response = await http.put(
                  Uri.parse('http://$ip:8080/description_map/$id'),
                  headers: {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer $token",
                  },
                  body: jsonEncode(updatedData),
                );

                if (response.statusCode == 200) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => map()),);
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