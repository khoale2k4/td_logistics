import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/core/helpers/map_helpers.dart';
import 'package:tdlogistic_v2/shipper/UI/widgets/search_bar.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  MapController? mapController;
  final TextEditingController _startSearchController = TextEditingController();
  final TextEditingController _endSearchController = TextEditingController();
  final Location _location = Location();
  final latlong.LatLng _currentPosition =
      const latlong.LatLng(10.8231, 106.6297); // Tọa độ khởi tạo
  latlong.LatLng? _startLocation;
  latlong.LatLng? _endLocation;
  final List<Marker> _markers = []; // Lưu trữ các marker
  List<Polyline> _polylines = []; // Lưu trữ đường đi
  final String _apiKey = ggApiKey; // Thay bằng API Key của bạn

  // Route information
  String? _distance;
  String? _duration;
  bool _isSelectingStart = false;
  bool _isSelectingEnd = false;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  // Helper functions to convert between Google Maps and flutter_map LatLng
  latlong.LatLng _gmapsToFlutterMap(gmaps.LatLng point) {
    return latlong.LatLng(point.latitude, point.longitude);
  }

  gmaps.LatLng _flutterMapToGmaps(latlong.LatLng point) {
    return gmaps.LatLng(point.latitude, point.longitude);
  }

  // Handle map tap to select locations
  void _onMapTap(TapPosition tapPosition, latlong.LatLng point) {
    if (_isSelectingStart) {
      setState(() {
        _startLocation = point;
        _isSelectingStart = false;
        
        // Remove old start marker if exists
        _markers.removeWhere((marker) => marker.key == const Key('start'));
        _markers.add(Marker(
          key: const Key('start'),
          point: point,
          width: 80,
          height: 80,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(
              Icons.location_pin,
              color: Colors.white,
              size: 30,
            ),
          ),
        ));
        
        _startSearchController.text = "Vị trí đã chọn (${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)})";
      });
      
      if (_endLocation != null) {
        _calculateRoute();
      }
    } else if (_isSelectingEnd) {
      setState(() {
        _endLocation = point;
        _isSelectingEnd = false;
        
        // Remove old end marker if exists
        _markers.removeWhere((marker) => marker.key == const Key('end'));
        _markers.add(Marker(
          key: const Key('end'),
          point: point,
          width: 80,
          height: 80,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(
              Icons.location_pin,
              color: Colors.white,
              size: 30,
            ),
          ),
        ));
        
        _endSearchController.text = "Vị trí đã chọn (${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)})";
      });
      
      if (_startLocation != null) {
        _calculateRoute();
      }
    }
  }

  Future<void> _moveToLocation(String address, bool isStart) async {
    if (address.isEmpty) return;
    
    print("🔍 Searching for address: '$address'");
    
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$_apiKey');
    print("🌐 API URL: $url");
    
    final response = await http.get(url);
    print("📡 Response status: ${response.statusCode}");
    print("📡 Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("📊 API Status: ${data['status']}");
      print("📊 Results count: ${data['results']?.length ?? 0}");
      
      if (data['status'] != 'OK') {
        _showSnackBar("API Error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}");
        return;
      }
      
      if (data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        final latLng = latlong.LatLng(location['lat'], location['lng']);
        final formattedAddress = data['results'][0]['formatted_address'];
        
        print("✅ Found location: $formattedAddress at $latLng");

        if (mapController != null) {
          mapController!.move(latLng, 14.0);
        }

        setState(() {
          if (isStart) {
            _startLocation = latLng;
            // Remove old start marker if exists
            _markers.removeWhere((marker) => marker.key == const Key('start'));
            _markers.add(Marker(
              key: const Key('start'),
              point: latLng,
              width: 80,
              height: 80,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ));
            // Update text field with formatted address
            _startSearchController.text = formattedAddress;
          } else {
            _endLocation = latLng;
            // Remove old end marker if exists
            _markers.removeWhere((marker) => marker.key == const Key('end'));
            _markers.add(Marker(
              key: const Key('end'),
              point: latLng,
              width: 80,
              height: 80,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ));
            // Update text field with formatted address
            _endSearchController.text = formattedAddress;
          }
        });

        // Nếu cả hai điểm đã được chọn, tính toán và vẽ đường đi
        if (_startLocation != null && _endLocation != null) {
          _calculateRoute();
        }
      } else {
        _showSnackBar("Không tìm thấy vị trí cho địa chỉ: '$address'");
      }
    } else {
      _showSnackBar("Lỗi khi gọi API: ${response.statusCode}");
    }
  }

  bool _isLoading = false; 
  String? _error;

  Future<void> _calculateRoute() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _distance = null;
      _duration = null;
    });

    try {
      if (_startLocation == null || _endLocation == null) return;

      // Xóa polyline cũ trước khi vẽ mới
      _polylines.clear();

      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/directions/json?origin=${_startLocation!.latitude},${_startLocation!.longitude}&destination=${_endLocation!.latitude},${_endLocation!.longitude}&key=$_apiKey');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final List<latlong.LatLng> polylineCoordinates = [];
          
          // Get route information
          final route = data['routes'][0];
          final leg = route['legs'][0];
          
          setState(() {
            _distance = leg['distance']['text'];
            _duration = leg['duration']['text'];
          });

          // Lấy tất cả points từ route
          final points = PolylinePoints()
              .decodePolyline(route['overview_polyline']['points']);

          // Chuyển đổi points thành LatLng
          for (var point in points) {
            polylineCoordinates.add(latlong.LatLng(point.latitude, point.longitude));
          }

          setState(() {
            _polylines.add(Polyline(
              points: polylineCoordinates,
              color: mainColor,
              strokeWidth: 5.0,
            ));

            // Di chuyển camera để hiển thị toàn bộ route
            LatLngBounds bounds = LatLngBounds(
              _startLocation!,
              _endLocation!,
            );
            
            if (mapController != null) {
              mapController!.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(100)));
            }
          });
        } else {
          setState(() => _error = 'Không thể tìm được đường đi: ${data['status']}');
        }
      }
    } catch (e) {
      setState(() => _error = 'Đã xảy ra lỗi: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearRoute() {
    setState(() {
      _startLocation = null;
      _endLocation = null;
      _markers.clear();
      _polylines.clear();
      _distance = null;
      _duration = null;
      _error = null;
      _startSearchController.clear();
      _endSearchController.clear();
    });
  }

  Future<void> _goToMyLocation() async {
    try {
    var currentLocation = await _location.getLocation();
      if (mapController != null) {
        mapController!.move(
          latlong.LatLng(currentLocation.latitude!, currentLocation.longitude!),
          15.0,
        );
      }
    } catch (e) {
      _showSnackBar("Không thể lấy vị trí hiện tại: $e");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 12.0,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.tdlogistics.app',
                maxZoom: 19,
              ),
              if (_polylines.isNotEmpty)
                PolylineLayer(
            polylines: _polylines,
          ),
              if (_markers.isNotEmpty)
                MarkerLayer(
                  markers: _markers,
                ),
            ],
          ),
          
          // Search bars và controls
          Positioned(
            top: 50,
            left: 15,
            right: 15,
            child: Column(
              children: [
                // Start location search
                Row(
                  children: [
                    Expanded(
                      child: MySearchBar(
                        controller: _startSearchController,
                        labelText: 'Điểm bắt đầu',
                        icon: const Icon(Icons.location_on, color: Colors.green),
                        onTap: () => _moveToLocation(_startSearchController.text, true),
                        onChanged: () {},
                        onDelete: () => setState(() {
                          _startLocation = null;
                          _markers.removeWhere((marker) => marker.key == const Key('start'));
                          _polylines.clear();
                          _distance = null;
                          _duration = null;
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: _isSelectingStart ? mainColor : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _isSelectingStart ? mainColor : Colors.grey),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.touch_app,
                          color: _isSelectingStart ? Colors.white : Colors.grey[600],
                        ),
                        onPressed: () => setState(() {
                          _isSelectingStart = !_isSelectingStart;
                          _isSelectingEnd = false;
                        }),
                        tooltip: 'Chọn trên bản đồ',
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 10),
                
                // End location search
                Row(
                  children: [
                    Expanded(
                      child: MySearchBar(
                        controller: _endSearchController,
                        labelText: 'Điểm đến',
                        icon: const Icon(Icons.location_on, color: Colors.blue),
                        onTap: () => _moveToLocation(_endSearchController.text, false),
                        onChanged: () {},
                        onDelete: () => setState(() {
                          _endLocation = null;
                          _markers.removeWhere((marker) => marker.key == const Key('end'));
                          _polylines.clear();
                          _distance = null;
                          _duration = null;
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: _isSelectingEnd ? mainColor : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _isSelectingEnd ? mainColor : Colors.grey),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.touch_app,
                          color: _isSelectingEnd ? Colors.white : Colors.grey[600],
                        ),
                        onPressed: () => setState(() {
                          _isSelectingEnd = !_isSelectingEnd;
                          _isSelectingStart = false;
                        }),
                        tooltip: 'Chọn trên bản đồ',
                      ),
                    ),
                  ],
                ),
                
                // Route actions
                if (_startLocation != null || _endLocation != null)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _clearRoute,
                            icon: const Icon(Icons.clear),
                            label: const Text('Xóa route'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade400,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Selection instruction
                if (_isSelectingStart || _isSelectingEnd)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: mainColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: mainColor, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: mainColor),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _isSelectingStart 
                              ? 'Tap trên bản đồ để chọn điểm bắt đầu'
                              : 'Tap trên bản đồ để chọn điểm đến',
                            style: TextStyle(color: mainColor, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Loading indicator
                if (_isLoading)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 15),
                        Text('Đang tính toán đường đi...'),
                      ],
                    ),
                  ),
                
                // Route information
                if (_distance != null && _duration != null)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.directions, color: Colors.green.shade700),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Khoảng cách: $_distance',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Thời gian: $_duration',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Error display
                if (_error != null)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red.shade700),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // My location button
          Positioned(
            bottom: 150,
            right: 20,
            child: FloatingActionButton(
              onPressed: _goToMyLocation,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
