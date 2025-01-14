import 'package:flutter/material.dart';
import 'BasePage.dart';

class Bus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return BasePage(
      body: Center(
        child: Image.asset(
          'assets/images/Routes/googlemap.jpg',
          width: screenWidth*1, // Set width to full screen width
          height: screenHeight * 0.9, // Set height to full screen height
          fit: BoxFit.fill,
           // Cover the entire area
        ),
      ),
      index: 1,
    );
  }
}