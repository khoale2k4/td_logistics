import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:http/http.dart' as http;
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/core/helpers/map_helpers.dart';

class MapScreen extends StatefulWidget {
  final gmaps.LatLng startLocation;
  final gmaps.LatLng endLocation;

  const MapScreen(
      {Key? key, required this.startLocation, required this.endLocation})
      : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapController? _mapController;
  List<Polyline> _polylines = [];
  List<Marker> _markers = [];
  String _distance = "";
  String _duration = "";

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    try {
      final String url =
          "https://maps.googleapis.com/maps/api/directions/json?origin=${widget.startLocation.latitude},${widget.startLocation.longitude}&destination=${widget.endLocation.latitude},${widget.endLocation.longitude}&key=${ggApiKey}";
      print(url);
      final response = await http.get(Uri.parse(url));
      print(response);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);

        if (data["routes"].isNotEmpty) {
          final route = data["routes"][0];
          final legs = route["legs"][0];

          // Lấy khoảng cách và thời gian
          setState(() {
            _distance = legs["distance"]["text"];
            _duration = legs["duration"]["text"];
          });

          // Vẽ polyline
          final points = route["overview_polyline"]["points"];
          print(points);
          _setPolyline(points);

          // Thêm marker
          _setMarkers();

          // Cập nhật camera để bao phủ cả hai điểm
          _updateCameraBounds();
        }
      } else {
        print("Failed to fetch directions.");
      }
    } catch (error) {
      print("Error fetching route: ${error.toString()}");
    }
  }

  void _setPolyline(String encoded) {
    try {
      final List<gmaps.LatLng> points = _decodePolyline(encoded);
      final List<latlong.LatLng> flutterMapPoints = MapHelpers.convertLatLngList(points);
      
      setState(() {
        _polylines.add(Polyline(
          points: flutterMapPoints,
          color: Colors.blue,
          strokeWidth: 5.0,
        ));
      });
    } catch (error) {
      print("Polylines: ${error.toString()}");
    }
  }

  void _setMarkers() {
    try {
      setState(() {
        // Start marker
        _markers.add(Marker(
          point: MapHelpers.gmapsToFlutterMap(widget.startLocation),
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

        // End marker
        _markers.add(Marker(
          point: MapHelpers.gmapsToFlutterMap(widget.endLocation),
          width: 80,
          height: 80,
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
        ));
      });
    } catch (error) {
      print("Lỗi set markers: ${error.toString()}");
    }
  }

  void _updateCameraBounds() {
    try {
      final double southLat =
          widget.startLocation.latitude < widget.endLocation.latitude
              ? widget.startLocation.latitude
              : widget.endLocation.latitude;
      final double northLat =
          widget.startLocation.latitude > widget.endLocation.latitude
              ? widget.startLocation.latitude
              : widget.endLocation.latitude;

      final double westLng =
          widget.startLocation.longitude < widget.endLocation.longitude
              ? widget.startLocation.longitude
              : widget.endLocation.longitude;
      final double eastLng =
          widget.startLocation.longitude > widget.endLocation.longitude
              ? widget.startLocation.longitude
              : widget.endLocation.longitude;

      LatLngBounds bounds = LatLngBounds(
        latlong.LatLng(southLat, westLng),
        latlong.LatLng(northLat, eastLng),
      );

      if (_mapController != null) {
        _mapController!.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)));
      }
    } catch (error) {
      print("Lỗi camera: ${error.toString()}");
    }
  }

  List<gmaps.LatLng> _decodePolyline(String encoded) {
    try {
      List<gmaps.LatLng> poly = [];
      int index = 0, len = encoded.length;
      int lat = 0, lng = 0;

      while (index < len) {
        int b, shift = 0, result = 0;
        do {
          b = encoded.codeUnitAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20);
        int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lat += dlat;

        shift = 0;
        result = 0;
        do {
          b = encoded.codeUnitAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20);
        int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lng += dlng;

        poly.add(gmaps.LatLng(lat / 1E5, lng / 1E5));
      }

      return poly;
    } catch (error) {
      print("Lỗi decode route: ${error.toString()}");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 300,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: MapHelpers.gmapsToFlutterMap(widget.startLocation),
              initialZoom: 12.0,
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
        ),
        if (_distance.isNotEmpty && _duration.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("$_distance - $_duration"),
          ),
      ],
    );
  }
}
