// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, duplicate_ignore

import 'package:flutter/material.dart';

import 'BasePage.dart';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

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
          insetPadding: EdgeInsets.zero,
          clipBehavior: Clip.none,
          
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100, // Set the width of the button
                  height: 40, // Set the height of the button
                  child: ElevatedButton(
                    onPressed: () => _onButtonPressed(0),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedIndex == 0 ? Colors.blue : Colors.white,
                      elevation: _selectedIndex == 0 ? 10 : 0,
                    ),
                    child: const Text(
                            'สาย 1',
                            style: TextStyle(
                                  color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 100, // Set the width of the button
                  height: 40, // Set the height of the button
                  child: ElevatedButton(
                    onPressed: () => _onButtonPressed(1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedIndex == 1 ? Colors.blue : Colors.white,
                      elevation: _selectedIndex == 1 ? 10 : 0,
                    ),
                    child: const Text(
                          'สาย 2',
                          style: TextStyle(
                                color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 100, // Set the width of the button
                  height: 40, // Set the height of the button
                  child: ElevatedButton(
                    onPressed: () => _onButtonPressed(2),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedIndex == 2 ? Colors.blue : Colors.white,
                      elevation: _selectedIndex == 2 ? 10 : 0,
                    ),
                    child: const Text(
                          'สาย 3',
                          style: TextStyle(
                                color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: [
              GestureDetector(
                onTap: () {
                  _showImageDialog(context, 'assets/images/Routes/route1.jpg');
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white, // พื้นที่ภายในเป็นสีขาว
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3), // เปลี่ยนตำแหน่งของเงา
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      FractionallySizedBox(
                        widthFactor: 0.9,
                        child: Image.asset('assets/images/Routes/route1.jpg'),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Route 1 Description',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _showImageDialog(context, 'assets/images/Routes/route2.jpg');
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white, // พื้นที่ภายในเป็นสีขาว
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3), // เปลี่ยนตำแหน่งของเงา
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      FractionallySizedBox(
                        widthFactor: 0.9,
                        child: Image.asset('assets/images/Routes/route2.jpg'),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Route 2 Description',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _showImageDialog(context, 'assets/images/Routes/route3.jpg');
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white, // พื้นที่ภายในเป็นสีขาว
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3), // เปลี่ยนตำแหน่งของเงา
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      FractionallySizedBox(
                        widthFactor: 0.9,
                        child: Image.asset('assets/images/Routes/route3.jpg'),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Route 3 Description',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        ],
      ),
      index: 3,
    );
  }
}