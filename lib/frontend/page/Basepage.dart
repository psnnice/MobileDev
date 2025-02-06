import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:up_transit/frontend/page/sidebar.dart';

class BasePage extends StatefulWidget {
  final Widget body;
  final int index;

  const BasePage({super.key, required this.body, required this.index});

  @override
  State createState() {
    return BasePageState();
  }
}

class BasePageState extends State<BasePage> {
  final _storage = FlutterSecureStorage();
  final List<String> routes = ['/News', '/Bus', '/', '/Map', '/Contact'];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.index;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      Navigator.pushNamed(context, routes[index]);
    });
  }

  void _logout() async {
    // Handle logout logic here
      await _storage.delete(key: 'token');
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8D38C9), Color(0xFF0092E7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: Row(
              children: [
                SizedBox(
                  height: 35, // Set height to match AppBar height
                  width: 35, // Set width to match AppBar height
                  child: Image.asset('assets/images/Logos/bus.png'),
                ),
                const SizedBox(width: 10), // Add some space
                const Expanded(
                  child: Text(
                    'UP Transit',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      fontFamily: 'YourFontFamily', // Replace with your font family
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
              ],
            ),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent, // Make background transparent to show gradient
            elevation: 0, // Remove shadow
            actions: [
              SidebarButton(),
            ],
          ),
        ),
      ),
      body: widget.body,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8D38C9), Color(0xFF0092E7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
          unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.article),
              label: 'News',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_bus),
              label: 'Bus',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Route',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.contact_mail),
              label: 'Contact',
            ),
          ],
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,  // Make background transparent to show gradient
        ),
      ),
      endDrawer: EndDrawer(),
    );
  }
}