import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:up_transit/frontend/page/Bus.dart';
import 'package:up_transit/frontend/page/Calls.dart';
import 'package:up_transit/frontend/page/Home.dart';
import 'package:up_transit/frontend/page/Loginpage.dart';
import 'package:up_transit/frontend/page/Map.dart';
import 'package:up_transit/frontend/page/News.dart';
import 'package:up_transit/frontend/page/providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestPermissions();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: LinkPage(),
    ),
  );
}

Future<void> requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.storage,
    Permission.location,
  ].request();

  if (statuses.values.any((status) => status.isDenied || status.isPermanentlyDenied)) {
    // If any permission is denied, exit the app
    Future.delayed(Duration.zero, () {
      SystemNavigator.pop();
    });
  }
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
        '/Map'    : (context) =>  map(),
        '/Contact': (context) =>  Contact(),
      },
    );
  }
}