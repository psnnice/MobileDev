import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:up_transit/frontend/page/Basepage.dart';
import 'package:up_transit/frontend/page/configip/config.dart';
import 'package:up_transit/frontend/page/mockDataDevices/mockData.dart' as mockData; // นำเข้าไฟล์ mockData.dart

var ip = Config.ip;

class Bus extends StatefulWidget {
  @override
  _BusPageState createState() => _BusPageState();
}

class _BusPageState extends State<Bus> {
  GoogleMapController? mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  Timer? _timer;

  bool _showRoute1 = true;
  bool _showRoute2 = true;
  bool _showRoute3 = true;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
    _fetchData();
    _startFetchingData();
    mockData.main();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startFetchingData() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _fetchData();
    });
  }

Future<void> _fetchData() async {
    final deviceMarkers = await _fetchDeviceData();
    final busStopMarkers = await _loadBusStops();
    setState(() {
      _markers.clear();
      _markers.addAll(deviceMarkers);
      _markers.addAll(busStopMarkers);
    });
  }


  
  Future<Set<Marker>> _fetchDeviceData() async {
    print('Fetching device data...');
    final url = Uri.parse('http://$ip:8080/DataBus');
    final response = await http.get(url);

    final Set<Marker> deviceMarkers = {};
    
    if (response.statusCode == 200) {
      print('Data fetched successfully');
      final List<dynamic> data = json.decode(response.body);
      
      for (var item in data) {
        final latitude = item['latitude'] is int ? (item['latitude'] as int).toDouble() : item['latitude'];
        final longitude = item['longitude'] is int ? (item['longitude'] as int).toDouble() : item['longitude'];
        deviceMarkers.add(Marker(
          markerId: MarkerId(item['device_id']),
          position: LatLng(latitude,longitude),
          infoWindow: InfoWindow(
            title: 'Device ID: ${item['device_id']}',
            snippet: 'Device Count: ${item['device_count']}',
          ),
          icon: AssetMapBitmap( 'assets/images/Logos/bus.png', width: 24, height: 24),
        ));
      }
    } else {
      print('Failed to load device data: ${response.statusCode}');
    }

    return deviceMarkers;
  }

  Future<void> _loadRoutes() async {
    final route1 = await _loadRoute('assets/jsonFile/route1.json');
    final route2 = await _loadRoute('assets/jsonFile/route2.json');
    final route3 = await _loadRoute('assets/jsonFile/route3.json');

    setState(() {
      _polylines.add(Polyline(
        polylineId: PolylineId('route1'),
        points: route1,
        color: Colors.blue,
        width: 5,
        visible: _showRoute1,
      ));
      _polylines.add(Polyline(
        polylineId: PolylineId('route2'),
        points: route2,
        color: Colors.red,
        width: 5,
        visible: _showRoute2,
      ));
      _polylines.add(Polyline(
        polylineId: PolylineId('route3'),
        points: route3,
        color: Colors.green,
        width: 5,
        visible: _showRoute3,
      ));
    });
  }

  Future<List<LatLng>> _loadRoute(String path) async {
    final data = await rootBundle.loadString(path);
    final jsonResult = json.decode(data) as List;
    return jsonResult.map((point) => LatLng(point['lat'], point['lng'])).toList();
  }

    Future<Set<Marker>> _loadBusStops() async {
    final busStopIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)), // ปรับขนาดของไอคอนที่นี่
      'assets/images/Logos/stop.png',
    );

    final busStops = [
      {'name': 'สถานีทางขึ้นรถหน้า ม.', 'lat': 19.030551, 'lng': 99.922942},
      {'name': 'สถานีลงรถหน้า ม.','lat': 19.030878, 'lng': 99.922976},
      {'name': 'สถานีหน้าโรงพยาบาล มพ. (ขาเข้า)','lat': 19.030488, 'lng': 99.920837 },
      {'name': 'สถานีหน้าโรงพยาบาล มพ. (ขาออก)', 'lat': 19.030726, 'lng': 99.920976},
      {'name': 'สถานีหน้าคณะทันตเเพทยศาสตร์ (ขาเข้า)', 'lat': 19.029911, 'lng': 99.915225},
      {'name': 'สถานีหน้าคณะทันตเเพทยศาสตร์ (ขาออก)', 'lat': 19.030149, 'lng': 99.915284},
      {'name': 'สถานีเรือนเอื้องคำ (ขาเข้า)', 'lat': 19.028564, 'lng': 99.906768},
      {'name': 'สถานีเรือนเอื้องคำ (ขาออก)', 'lat': 19.028801, 'lng': 99.906795},
      {'name': 'สถานีคณะวิศวกรรมศาสตร์ (ขาเข้า).','lat': 19.030526, 'lng': 99.901227},
      {'name': 'สถานีคณะวิศวกรรมศาสตร์ (ขาออก)','lat': 19.030810, 'lng':  99.901198},
      {'name': 'สถานีหน้าคณะ ICT (ทางเข้าชั้น 3).','lat': 19.028470, 'lng': 99.899836},
      {'name': 'สถานีคณะ ICT (ทางเข้าโรงอาหาร)','lat': 19.027074, 'lng': 99.899526},
      {'name': 'สถานีคณะ ICT (ทางเข้าโรงอาหาร)','lat': 19.026846, 'lng': 99.899623},
      {'name': 'สถานีขึ้น - ลงรถ ประตู 3','lat': 19.022673, 'lng': 99.895429},
      {'name': 'สถานีหอประชุมพญางำเมือง','lat': 19.029995, 'lng': 99.897714},
      {'name': 'สถานีอาคารอธิการ','lat': 19.029027, 'lng': 99.896088},
      {'name': 'สถานีตึกคณะศิลปศาสตร์','lat': 19.029717, 'lng': 99.895682},
      {'name': 'สถานีตึกคณะวิทยาศาสตร์','lat': 19.030665, 'lng': 99.897614},
      {'name': 'สถานีอาคารเรียนรวม','lat': 19.025723, 'lng': 99.894892},
      {'name': 'สถานีตึก 99 ปี อาคารอุบาลี (ขาเข้า)','lat': 19.031813, 'lng': 99.893344},
      {'name': 'สถานีตึก 99 ปี อาคารอุบาลี (ขาออก)','lat': 19.031993, 'lng': 99.893491},
      {'name': 'สถานีเวียงพะเยา - หอใน (ขาเข้า)','lat': 19.033013, 'lng': 99.890882},
      {'name': 'สถานีเวียงพะเยา - หอใน (ขาออก)','lat': 19.033203, 'lng': 99.890911},
      {'name': 'สถานีอาคารสงวนเสริมศรี (ขาเข้า)','lat': 19.034110, 'lng': 99.886149},
      {'name': 'สถานีอาคารสงวนเสริมศรี (ขาออก)','lat': 19.034244, 'lng': 99.886324},
      {'name': 'สถานีโรงเรียนสาธิตมหาวิทยาลัยพะเยา','lat': 19.034375, 'lng': 99.884256},
      // เพิ่มป้ายสถานีรถเมล์อื่นๆ ที่นี่
    ];

    final Set<Marker> busStopMarkers = {};

    for (var stop in busStops) {
      busStopMarkers.add(Marker(
        markerId: MarkerId(stop['name'] as String),
        position: LatLng(stop['lat'] as double, stop['lng'] as double),
        icon: busStopIcon,
        infoWindow: InfoWindow(
          title: stop['name'] as String,
        ),
      ));
    }

    return busStopMarkers;
  }

  void _toggleRoute(String route) {
    setState(() {
      if (route == 'route1') {
        _showRoute1 = !_showRoute1;
        _updatePolylineVisibility('route1', _showRoute1);
      } else if (route == 'route2') {
        _showRoute2 = !_showRoute2;
        _updatePolylineVisibility('route2', _showRoute2);
      } else if (route == 'route3') {
        _showRoute3 = !_showRoute3;
        _updatePolylineVisibility('route3', _showRoute3);
      }
    });
  }

  void _updatePolylineVisibility(String routeId, bool visible) {
    setState(() {
      _polylines = _polylines.map((polyline) {
        if (polyline.polylineId.value == routeId) {
          return polyline.copyWith(visibleParam: visible);
        }
        return polyline;
      }).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(19.0295882, 99.9035753),
              zoom: 14.0,
            ),
            mapType: MapType.normal,
            onMapCreated: (controller) {
              mapController = controller;
            },
            polylines: _polylines,
            markers: _markers,
          ),
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: _showRoute1 ? Colors.blue : Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => _toggleRoute('route1'),
                  child: Text(' สาย 1 '),
                ),
                SizedBox(width: 10),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: _showRoute2 ? const Color.fromARGB(255, 244, 67, 54) : const Color.fromARGB(255, 255, 255, 255),
                    foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                  ),
                  onPressed: () => _toggleRoute('route2'),
                  child: Text(' สาย 2 '),
                ),
                SizedBox(width: 10),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: _showRoute3 ? const Color.fromARGB(255, 76, 175, 79) : const Color.fromARGB(255, 255, 255, 255),
                    foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                  ),
                  onPressed: () => _toggleRoute('route3'),
                  child: Text(' สาย 3 '),
                ),
              ],
            ),
          ),
        ],
      ),
      index: 1,
    );
  }
}