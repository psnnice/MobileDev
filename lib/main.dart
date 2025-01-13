import 'package:flutter/material.dart';
import 'package:up_transit/page/Bus.dart';
import 'package:up_transit/page/Calls.dart';
import 'package:up_transit/page/Home.dart';
import 'package:up_transit/page/Map.dart';
import 'package:up_transit/page/News.dart';
import 'package:up_transit/page/Loginpage.dart';


void main() => runApp(const LinkPage());


class LinkPage extends StatelessWidget {
  const LinkPage({super.key});



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/News': (context) => News(),
        '/Bus': (context)  => Bus(),
        '/': (context) => Home(),
        '/Map': (context) => Map(),
        '/Contact': (context) => Contact(),
        
      },
    );
  }
}