import 'package:latlong2/latlong.dart' as latlong;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MapHelpers {
  // Convert Google Maps LatLng to FlutterMap LatLng
  static latlong.LatLng gmapsToFlutterMap(gmaps.LatLng point) {
    return latlong.LatLng(point.latitude, point.longitude);
  }

  // Convert FlutterMap LatLng to Google Maps LatLng
  static gmaps.LatLng flutterMapToGmaps(latlong.LatLng point) {
    return gmaps.LatLng(point.latitude, point.longitude);
  }

  // Convert list of Google Maps LatLng to FlutterMap LatLng
  static List<latlong.LatLng> convertLatLngList(List<gmaps.LatLng> gmapsPoints) {
    return gmapsPoints.map((point) => gmapsToFlutterMap(point)).toList();
  }

  // Convert list of FlutterMap LatLng to Google Maps LatLng
  static List<gmaps.LatLng> convertToGmapsList(List<latlong.LatLng> flutterMapPoints) {
    return flutterMapPoints.map((point) => flutterMapToGmaps(point)).toList();
  }
}

class KeyboardHelper {
  // Ensure keyboard is shown
  static void showKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  // Hide keyboard
  static void hideKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  // Force keyboard to appear for a specific focus node
  static void focusAndShowKeyboard(BuildContext context, FocusNode focusNode) {
    Future.delayed(const Duration(milliseconds: 100), () {
      FocusScope.of(context).requestFocus(focusNode);
      showKeyboard();
    });
  }
} 