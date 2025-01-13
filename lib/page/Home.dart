import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'BasePage.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the height of the screen
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    void _showImageDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: screenWidth,
                  height: screenHeight * 0.75, // Set height to 75% of screen height
                  child: InteractiveViewer(
                    child: Image.asset('assets/upmap.jpg'),
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

    return BasePage(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20,), // Add some space at the top
            Text(
              'Welcome to UP Transit',
              style: GoogleFonts.sourceCodePro(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
            const SizedBox(height: 10), // Add some space between text and image
            GestureDetector(
              onTap: () {
                _showImageDialog(context);
              },
              child: Image(
                image: const AssetImage('assets/upmap.jpg'),
                width: screenWidth * 0.90, // Set width to 75% of screen width
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
      index: 2,
    );
  }
}