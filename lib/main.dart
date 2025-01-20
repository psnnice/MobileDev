// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:up_transit/frontend/page/Bus.dart';
import 'package:up_transit/frontend/page/Calls.dart';
import 'package:up_transit/frontend/page/Home.dart';
import 'package:up_transit/frontend/page/Loginpage.dart';
import 'package:up_transit/frontend/page/Map.dart';
import 'package:up_transit/frontend/page/News.dart';


void main() {
  // เรียกใช้ฟังก์ชัน main ของ mockData.dart


  // เรียกใช้ฟังก์ชัน runApp สำหรับ Flutter
  runApp(const LinkPage());

}


class LinkPage extends StatelessWidget {  
  const LinkPage({super.key});



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login'  : (context) =>  LoginPage(),
        '/News'   : (context) =>  News(),
        '/Bus'    : (context) =>  Bus(),
        '/'       : (context) =>  Home(),
        '/Map'    : (context) =>  Map(),
        '/Contact': (context) =>  Contact(),
        
      },
    );
  }
}