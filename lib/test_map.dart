import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TestMapWidget extends StatefulWidget {
  const TestMapWidget({Key? key}) : super(key: key);

  @override
  _TestMapWidgetState createState() => _TestMapWidgetState();
}

class _TestMapWidgetState extends State<TestMapWidget> {
  GoogleMapController? mapController;
  String _status = "Đang khởi tạo...";
  String _apiStatus = "Chưa test API";
  MapType _currentMapType = MapType.normal;
  int _debugCounter = 0;
  
  // Tọa độ TP.HCM làm test
  static const LatLng _center = LatLng(10.8231, 106.6297);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      _status = "Google Maps đã được khởi tạo thành công! Controller: ${controller.toString()}";
      _debugCounter++;
    });
    print("Google Maps đã được khởi tạo thành công!");
  }

  Future<void> _testApiKey() async {
    try {
      final url = 'https://maps.googleapis.com/maps/api/geocode/json?address=Ho+Chi+Minh+City&key=$ggApiKey';
      final response = await http.get(Uri.parse(url));
      
      print("API Response status: ${response.statusCode}");
      print("API Response body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          setState(() {
            _apiStatus = "API Key hoạt động tốt!";
          });
        } else {
          setState(() {
            _apiStatus = "API Error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}";
          });
        }
      } else {
        setState(() {
          _apiStatus = "HTTP Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _apiStatus = "Exception: $e";
      });
      print("API test error: $e");
    }
  }

  void _changeMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal 
          ? MapType.satellite 
          : _currentMapType == MapType.satellite 
              ? MapType.terrain 
              : MapType.normal;
      _debugCounter++;
    });
    print("Changed map type to: $_currentMapType");
  }

  @override
  void initState() {
    super.initState();
    // Test API key khi widget khởi tạo
    _testApiKey();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Google Maps'),
        backgroundColor: mainColor,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('API Key: ${ggApiKey.isNotEmpty ? "Đã load" : "Chưa load"}'),
                const SizedBox(height: 4),
                Text('API Status: $_apiStatus'),
                const SizedBox(height: 4),
                Text('Maps Status: $_status'),
                const SizedBox(height: 4),
                Text('Map Type: $_currentMapType | Debug: $_debugCounter'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (mapController != null) {
                          print("Attempting camera move...");
                          mapController!.animateCamera(
                            CameraUpdate.newLatLngZoom(_center, 15.0),
                          );
                          setState(() {
                            _debugCounter++;
                          });
                        } else {
                          print("MapController is null!");
                        }
                      },
                      child: const Text('Test Camera'),
                    ),
                    ElevatedButton(
                      onPressed: _testApiKey,
                      child: const Text('Test API'),
                    ),
                    ElevatedButton(
                      onPressed: _changeMapType,
                      child: const Text('Change Type'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 3),
              ),
              child: Stack(
                children: [
                  // Fallback background
                  Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Text(
                        'Google Maps Loading Area\n(If you see this, Maps is not rendering)',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  // Google Maps
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    mapType: _currentMapType,
                    initialCameraPosition: const CameraPosition(
                      target: _center,
                      zoom: 11.0,
                    ),
                    // Tắt location để tránh permission issues
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    // Tắt controls để đơn giản hóa
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: true,
                    rotateGesturesEnabled: true,
                    scrollGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                    tiltGesturesEnabled: false,
                    markers: {
                      const Marker(
                        markerId: MarkerId('test'),
                        position: _center,
                        infoWindow: InfoWindow(
                          title: 'Test Marker',
                          snippet: 'TP.HCM',
                        ),
                      ),
                    },
                    onCameraMove: (CameraPosition position) {
                      print("Camera di chuyển tới: ${position.target}");
                    },
                    onCameraIdle: () {
                      print("Camera đã dừng di chuyển");
                      setState(() {
                        _debugCounter++;
                      });
                    },
                    onTap: (LatLng position) {
                      print("Đã tap vào: $position");
                      setState(() {
                        _status = "Tap: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
                        _debugCounter++;
                      });
                    },
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