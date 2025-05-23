import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class FlutterMapWidget extends StatefulWidget {
  final LatLng? initialCenter;
  final double initialZoom;
  final List<Marker> markers;
  final List<Polyline> polylines;
  final Function(LatLng)? onTap;
  final Function(LatLng)? onLongPress;
  final Function(MapPosition, bool)? onPositionChanged;
  final bool showMyLocation;
  final bool showZoomControls;

  const FlutterMapWidget({
    Key? key,
    this.initialCenter,
    this.initialZoom = 13.0,
    this.markers = const [],
    this.polylines = const [],
    this.onTap,
    this.onLongPress,
    this.onPositionChanged,
    this.showMyLocation = false,
    this.showZoomControls = true,
  }) : super(key: key);

  @override
  _FlutterMapWidgetState createState() => _FlutterMapWidgetState();
}

class _FlutterMapWidgetState extends State<FlutterMapWidget> {
  final MapController _mapController = MapController();
  LatLng _currentCenter = const LatLng(10.8231, 106.6297); // TP.HCM default
  LatLng? _userLocation;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialCenter != null) {
      _currentCenter = widget.initialCenter!;
    }
    if (widget.showMyLocation) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    if (_isLoadingLocation) return;
    
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });

      // Di chuyển map đến vị trí hiện tại
      _mapController.move(_userLocation!, widget.initialZoom);
    } catch (e) {
      print('Error getting location: $e');
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1);
  }

  @override
  Widget build(BuildContext context) {
    // Tạo danh sách markers bao gồm cả user location
    List<Marker> allMarkers = List.from(widget.markers);
    
    if (_userLocation != null && widget.showMyLocation) {
      allMarkers.add(
        Marker(
          point: _userLocation!,
          width: 60,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: const Icon(
              Icons.my_location,
              color: Colors.blue,
              size: 20,
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentCenter,
            initialZoom: widget.initialZoom,
            onTap: (tapPosition, point) {
              widget.onTap?.call(point);
            },
            onLongPress: (tapPosition, point) {
              widget.onLongPress?.call(point);
            },
            onMapEvent: (MapEvent mapEvent) {
              if (mapEvent is MapEventMoveEnd) {
                widget.onPositionChanged?.call(
                  MapPosition(
                    center: mapEvent.camera.center,
                    zoom: mapEvent.camera.zoom,
                  ),
                  false,
                );
              }
            },
          ),
          children: [
            // Tile layer - OpenStreetMap
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.tdlogistics.app',
              maxZoom: 19,
            ),
            
            // Polylines layer
            if (widget.polylines.isNotEmpty)
              PolylineLayer(
                polylines: widget.polylines,
              ),
            
            // Markers layer
            if (allMarkers.isNotEmpty)
              MarkerLayer(
                markers: allMarkers,
              ),
          ],
        ),
        
        // Custom zoom controls
        if (widget.showZoomControls)
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  onPressed: _zoomIn,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.add, color: Colors.black),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: _zoomOut,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.remove, color: Colors.black),
                ),
              ],
            ),
          ),
        
        // My location button
        if (widget.showMyLocation)
          Positioned(
            right: 16,
            bottom: 180,
            child: FloatingActionButton(
              mini: true,
              onPressed: _isLoadingLocation ? null : _getCurrentLocation,
              backgroundColor: Colors.white,
              child: _isLoadingLocation 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location, color: Colors.black),
            ),
          ),
      ],
    );
  }
}

class MapPosition {
  final LatLng center;
  final double zoom;

  MapPosition({required this.center, required this.zoom});
} 