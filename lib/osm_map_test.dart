import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class OSMMapTest extends StatefulWidget {
  const OSMMapTest({Key? key}) : super(key: key);

  @override
  _OSMMapTestState createState() => _OSMMapTestState();
}

class _OSMMapTestState extends State<OSMMapTest> {
  final MapController _mapController = MapController();
  String _status = "OpenStreetMap initialized";
  
  // Tọa độ TP.HCM
  static const LatLng _center = LatLng(10.8231, 106.6297);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenStreetMap Test'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Status: $_status'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _mapController.move(_center, 15.0);
                        setState(() {
                          _status = "Moved to TP.HCM center";
                        });
                      },
                      child: const Text('Go to TP.HCM'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        _mapController.move(_center, 18.0);
                        setState(() {
                          _status = "Zoomed to level 18";
                        });
                      },
                      child: const Text('Zoom In'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 3),
              ),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _center,
                  initialZoom: 13.0,
                  onTap: (tapPosition, point) {
                    setState(() {
                      _status = "Tapped: ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}";
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.tdlogistics.app',
                    maxZoom: 19,
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _center,
                        width: 80,
                        height: 80,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 