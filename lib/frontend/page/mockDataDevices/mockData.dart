import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:up_transit/frontend/page/configip/config.dart';
import 'package:up_transit/frontend/page/providers/user_provider.dart';

var ip = Config.ip;

Future<List<Map<String, dynamic>>> loadRouteData() async {
  final contents = await rootBundle.loadString('assets/jsonFile/route1.json');
  final List<dynamic> jsonData = json.decode(contents);
  return jsonData.cast<Map<String, dynamic>>();
}

Future<void> InsertDeviceData(List<DeviceData> deviceDataList) async {
  final url = Uri.parse('http://$ip:8080/DataBus');
  final body = json.encode(deviceDataList.map((data) => data.toJson()).toList());
  print('Sending data: $body');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: body,
  );

  if (response.statusCode == 200) {
    print('Data inserted successfully');
  } else {
    print('Failed to insert data: ${response.body}');
  }
}

Future<void> processAndInsertData(BuildContext context) async {
  
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final int? userId = userProvider.id; // ดึง userId จาก Provider

  final routes = await loadRouteData();
  final random = Random();

  for (int i = 0; i < routes.length; i += 10) {
    final deviceDataList = <DeviceData>[];

    for (int j = i; j < i + 10 && j < routes.length; j++) {
      final route = routes[j];
      final latitude = route['lat'] != null ? route['lat'].toDouble() : 0.0;
      final longitude = route['lng'] != null ? route['lng'].toDouble() : 0.0;
      final deviceId = (random.nextInt(11) + 10).toString();

      final deviceData = DeviceData(
        id: 0,
        deviceId: deviceId,
        latitude: latitude,
        longitude: longitude,
        deviceCount: random.nextInt(30) + 1,
        timestamp: DateTime.now().toUtc(),
        userId: userId, // ใช้ userId ที่ดึงมา
      );

      developer.log('Inserting device data: ${deviceData.toJson()}');
      deviceDataList.add(deviceData);
    }

    await InsertDeviceData(deviceDataList);
    await Future.delayed(Duration(seconds: 10));
  }
}

class DeviceData {
  final int id;
  final String deviceId;
  final double latitude;
  final double longitude;
  final int deviceCount;
  final DateTime timestamp;
  final int? userId;

  DeviceData({
    required this.id,
    required this.deviceId,
    required this.latitude,
    required this.longitude,
    required this.deviceCount,
    required this.timestamp,
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'device_id': deviceId,
        'latitude': latitude,
        'longitude': longitude,
        'device_count': deviceCount,
        'timestamp': timestamp.toIso8601String(),
        'user_id': userId,
      };
}
