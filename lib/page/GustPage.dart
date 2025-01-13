import 'package:flutter/material.dart';
import 'LoginPage.dart';

class GustPage extends StatelessWidget {
  const GustPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gust Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to the Gust Page!',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),

            //กลับไปหน้า Login
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Go back Login'),
            ),
          ],
        ),
      ),
    );
  }
}
