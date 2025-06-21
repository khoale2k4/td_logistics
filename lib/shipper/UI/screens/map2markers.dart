import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/shipper/UI/widgets/search_bar.dart';

class Map2Markers extends StatefulWidget {
  final String endAddress;

  const Map2Markers({
    Key? key,
    required this.endAddress,
  }) : super(key: key);

  @override
  _Map2MarkersState createState() => _Map2MarkersState();
}

class _Map2MarkersState extends State<Map2Markers> {
  late MapController mapController;
  latlong.LatLng? _startLatLng;
  latlong.LatLng? _endLatLng;
  List<latlong.LatLng> _routePoints = [];
  double _currentZoom = 12.0;
  final String _apiKey = ggApiKey;
  final Location _location = Location();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _initializeRoute();
  }

  Future<void> _initializeRoute() async {
    setState(() => _isLoading = true);
    try {
      // Lấy vị trí hiện tại của người dùng
      final currentLocation = await _location.getLocation();
      _startLatLng =
          latlong.LatLng(currentLocation.latitude!, currentLocation.longitude!);

      // Lấy tọa độ điểm đến từ địa chỉ
      _endLatLng = await _getLatLngFromAddress(widget.endAddress);

      // Kiểm tra và lấy route nếu cả 2 tọa độ có sẵn
      if (_startLatLng != null && _endLatLng != null) {
        await _calculateRoute(_startLatLng!, _endLatLng!);
      }
    } catch (e) {
      debugPrint("Error initializing route: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<latlong.LatLng?> _getLatLngFromAddress(String address) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$_apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        return latlong.LatLng(location['lat'], location['lng']);
      }
    }
    return null;
  }

  Future<void> _calculateRoute(latlong.LatLng start, latlong.LatLng end) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$_apiKey',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'].isNotEmpty) {
          final points = PolylinePoints()
              .decodePolyline(data['routes'][0]['overview_polyline']['points']);

          setState(() {
            _routePoints = points
                .map((point) => latlong.LatLng(point.latitude, point.longitude))
                .toList();
          });

          // Di chuyển camera để hiển thị toàn bộ route
          _moveToBounds();
        }
      }
    } catch (e) {
      debugPrint("Error calculating route: $e");
    }
  }

  void _moveToBounds() {
    if (_startLatLng != null && _endLatLng != null) {
      final bounds = LatLngBounds(
        _startLatLng!,
        _endLatLng!,
      );
      mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(100),
        ),
      );
    }
  }

  Future<void> _goToMyLocation() async {
    try {
      var currentLocation = await _location.getLocation();
      mapController.move(
        latlong.LatLng(currentLocation.latitude!, currentLocation.longitude!),
        15.0,
      );
    } catch (e) {
      debugPrint("Error getting current location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter:
                  _startLatLng ?? const latlong.LatLng(10.8231, 106.6297),
              initialZoom: _currentZoom,
              interactionOptions: const InteractionOptions(
                flags: ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.tdlogistics.app',
              ),
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: Colors.blue,
                      strokeWidth: 5,
                    ),
                  ],
                ),
              if (_startLatLng != null && _endLatLng != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _startLatLng!,
                      width: 40,
                      height: 40,
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
                    ),
                    Marker(
                      point: _endLatLng!,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _goToMyLocation,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.keyboard_return,
                    size: 30, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
