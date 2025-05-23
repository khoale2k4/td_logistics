import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/core/helpers/map_helpers.dart';
import 'package:tdlogistic_v2/customer/bloc/order_bloc.dart';
import 'package:tdlogistic_v2/customer/bloc/order_event.dart';
import 'package:tdlogistic_v2/customer/bloc/order_state.dart';

class TaskRouteWidget extends StatefulWidget {
  final String orderId;

  const TaskRouteWidget({Key? key, required this.orderId}) : super(key: key);

  @override
  _TaskRouteWidgetState createState() => _TaskRouteWidgetState();
}

class _TaskRouteWidgetState extends State<TaskRouteWidget> {
  MapController? mapController;
  final List<Polyline> _polylines = [];
  final List<Marker> _markers = [];
  List<latlong.LatLng> _routePoints = [];
  double _currentZoom = 12.0;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    context.read<GetPositionsBloc>().add(GetPositions(widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text(
          'Chi tiết lộ trình',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          BlocBuilder<GetPositionsBloc, OrderState>(
            builder: (context, state) {
              if (state is GettingPositions) {
                return _buildLoadingIndicator();
              } else if (state is GotPositions) {
                _routePoints = MapHelpers.convertLatLngList(state.pos);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _updateMapData();
                });
                return _buildMap();
              }
              return const Center(child: Text('Không có dữ liệu'));
            },
          ),
          _buildZoomControls(),
          _buildInfoPanel(),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(secondColor),
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: _routePoints.isNotEmpty
            ? _routePoints.first
            : const latlong.LatLng(10.8231, 106.6297),
        initialZoom: _currentZoom,
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
    );
  }

  Positioned _buildZoomControls() {
    return Positioned(
      right: 16,
      bottom: 100,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: "zoom_in",
            mini: true,
            backgroundColor: secondColor,
            tooltip: 'Phóng to',
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              _currentZoom = min(_currentZoom + 1, 20);
              if (mapController != null) {
                mapController!.move(
                  mapController!.camera.center, 
                  _currentZoom,
                );
              }
            },
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "zoom_out",
            mini: true,
            backgroundColor: secondColor,
            tooltip: 'Thu nhỏ',
            child: const Icon(Icons.remove, color: Colors.white),
            onPressed: () {
              _currentZoom = max(_currentZoom - 1, 1);
              if (mapController != null) {
                mapController!.move(
                  mapController!.camera.center, 
                  _currentZoom,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Positioned _buildInfoPanel() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 200,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Khoảng cách: ${_calculateDistance()} km',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Text(
                'Đã di chuyển: ${_calculateETA()} phút',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _calculateDistance() {
    return '1.3'; // Giá trị ví dụ
  }

  String _calculateETA() {
    return '18'; // Giá trị ví dụ
  }

  void _updateMapData() async {
    if (_routePoints.isEmpty) return;

    // Cập nhật polyline
    _polylines.clear();
    _polylines.add(
      Polyline(
        points: _routePoints,
        color: mainColor,
        strokeWidth: 5.0,
      ),
    );

    // Cập nhật marker
    _markers.clear();
    if (_routePoints.isNotEmpty) {
      final lastPoint = _routePoints.last;

      _markers.add(
        Marker(
          point: lastPoint,
          width: 80,
          height: 80,
          child: Container(
            decoration: BoxDecoration(
              color: mainColor,
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
      );
    }

    // Cập nhật vị trí camera để hiển thị toàn bộ tuyến đường
    if (mapController != null && _routePoints.length > 1) {
      final bounds = _getBounds(_routePoints);
      mapController!.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)));
    }

    setState(() {});
  }

  LatLngBounds _getBounds(List<latlong.LatLng> points) {
    double? minLat, maxLat, minLng, maxLng;

    for (latlong.LatLng point in points) {
      minLat = minLat == null ? point.latitude : min(minLat, point.latitude);
      maxLat = maxLat == null ? point.latitude : max(maxLat, point.latitude);
      minLng = minLng == null ? point.longitude : min(minLng, point.longitude);
      maxLng = maxLng == null ? point.longitude : max(maxLng, point.longitude);
    }

    return LatLngBounds(
      latlong.LatLng(minLat!, minLng!),
      latlong.LatLng(maxLat!, maxLng!),
    );
  }
}
