import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:up_transit/frontend/page/Calls.dart';

import 'BasePage.dart';
import 'token.dart';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  List<dynamic> _routes = [];

  @override
  void initState() {
    super.initState();
    print("Fetching routes...");
    _fetchRoutes();
  }

  Future<void> _fetchRoutes() async {
    final secureStorage = SecureStorage();
    final token = await secureStorage.getToken();
    final response = await http.get(
      Uri.parse('http://$ip:8080/description_map'), // ปรับ API ให้ตรงกับ table ใหม่
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _routes = json.decode(utf8.decode(response.bodyBytes));;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch routes'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onButtonPressed(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,

          child: Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 1,
                height: MediaQuery.of(context).size.height * 0.75,
                child: InteractiveViewer(
                  child: Image.asset(imagePath),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_routes.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: SizedBox(
                    width: 100,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () => _onButtonPressed(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedIndex == index ? Colors.blue : Colors.white,
                        elevation: _selectedIndex == index ? 10 : 0,
                      ),
                      child: Text(
                        _routes[index]['route_name'],
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: _routes.map((route) {
                return GestureDetector(
                  onTap: () => _showImageDialog(context,'${route['image_path']}'),
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        FractionallySizedBox(
                          widthFactor: 0.9,
                          child: Image.asset('${route['image_path']}'),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          route['description'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          route['station_list'],
                          textAlign: TextAlign.left,
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        if (route['note'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              '${route['note']}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      index: 3,
    );
  }
}
