import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:up_transit/frontend/page/configip/config.dart';
import 'package:up_transit/frontend/page/providers/user_provider.dart';
import 'package:up_transit/frontend/page/updateFunction/updateDesMap.dart';

import 'BasePage.dart';

var ip = Config.ip;

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  List<dynamic> routeData = [];

  @override
  void initState() {
    super.initState();
    _fetchRoutes();
  }

  Future<void> _fetchRoutes() async {
    try {
      final response = await http.get(Uri.parse('http://$ip:8080/description_map'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          routeData = data.map((route) {
            return {
              "id": route["id"] ?? "",
              "route_name": route["route_name"] ?? "",
              "image_path": route["image_path"] ?? "",
              "description": route["description"] ?? "",
              "station_list": route["station_list"] ?? "",
              "note": route["note"] ?? "",
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load routes');
      }
    } catch (e) {
      debugPrint('Error fetching routes: $e');
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

  @override
  Widget build(BuildContext context) {
    String userRole = Provider.of<UserProvider>(context).role;

    return BasePage(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(routeData.length, (index) {
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
                        routeData[index]['route_name'],
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
              children: routeData.map((route) {
                return GestureDetector(
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
                        Stack(
                          children: [
                        FractionallySizedBox(
                          widthFactor: 0.9,
                          child: Image.asset('${route['image_path']}'),
                        ),
                        if (userRole == 'admin')
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  showUpdateDescriptionDialog(context, route['id'], {
                                    "route_name": route['route_name'],
                                    "image_path": route['image_path'],
                                    "description": route['description'],
                                    "station_list": route['station_list'],
                                    "note": route['note'],
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
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