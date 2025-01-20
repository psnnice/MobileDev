// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:up_transit/frontend/page/Bus.dart';
import 'package:up_transit/frontend/page/Calls.dart';
import 'package:up_transit/frontend/page/Home.dart';
import 'package:up_transit/frontend/page/Loginpage.dart';
import 'package:up_transit/frontend/page/Map.dart';
import 'package:up_transit/frontend/page/News.dart';
import 'package:up_transit/frontend/page/providers/user_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: LinkPage(),
    ),
  );
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