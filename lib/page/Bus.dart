import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:up_transit/page/Basepage.dart';

class Bus extends StatefulWidget {
  @override
  _BusPageState createState() => _BusPageState();
}

class _BusPageState extends State<Bus> {
  GoogleMapController? mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  bool _showRoute1 = true;
  bool _showRoute2 = true;
  bool _showRoute3 = true;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
            top: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: _showRoute1 ? const Color.fromARGB(200, 33, 149, 243) : const Color.fromARGB(50, 177, 177, 177),
                    foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                  ),
                  onPressed: () => _toggleRoute('route1'),
                  child: Text('สาย 1'),
                ),
                SizedBox(width: 8),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: _showRoute2 ? const Color.fromARGB(200, 244, 67, 54) : const Color.fromARGB(50, 177, 177, 177),
                    foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                  ),
                  onPressed: () => _toggleRoute('route2'),
                  child: Text('สาย 2'),
                ),
                SizedBox(width: 8),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: _showRoute3 ? const Color.fromARGB(200, 76, 175, 79) : const Color.fromARGB(50, 177, 177, 177),
                    foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                  ),
                  onPressed: () => _toggleRoute('route3'),
                  child: Text('สาย 3'),
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