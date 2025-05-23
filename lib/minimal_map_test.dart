import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MinimalMapTest extends StatelessWidget {
  const MinimalMapTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minimal Map Test'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Container(
            height: 100,
            color: Colors.green,
            child: const Center(
              child: Text(
                'Green Area - If map works, this should be covered',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.red,
              child: const GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(10.8231, 106.6297), // TP.HCM
                  zoom: 11.0,
                ),
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
                rotateGesturesEnabled: false,
                scrollGesturesEnabled: false,
                zoomGesturesEnabled: false,
                tiltGesturesEnabled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 