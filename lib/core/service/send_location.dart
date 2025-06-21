import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:tdlogistic_v2/core/constant.dart';

class LocationTrackerService {
  List<String> taskIds = [];
  bool calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    double distanceInMeters = Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );

    return distanceInMeters > 2;
  }

  Future<void> startStatusUpdating(String token) async {
    print("start sending location");
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Define location settings with a distance filter of 10 meters
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter:
          10, // Minimum distance (in meters) before getting a new update
    );

    double curLat = 0;
    double curLng = 0;
    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        // Send the current position to the API every 10 seconds
        curLat = position.latitude;
        // curLat = 10.3490625;
        // curLng = 107.0762525;
        curLng = position.longitude;
        Timer.periodic(const Duration(seconds: 10), (Timer timer) async {
          await _updateStatus(curLat, curLng, token);
        });
        Timer.periodic(const Duration(minutes: 5), (Timer timer) async {});
      },
    );
  }

  Future<void> startLocationTracking(String token) async {
    print("start sending location");
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Define location settings with a distance filter of 10 meters
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter:
          10, // Minimum distance (in meters) before getting a new update
    );

    double curLat = 0;
    double curLng = 0;
    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        // Send the current position to the API every 10 seconds
        Timer.periodic(const Duration(seconds: 10), (Timer timer) async {
          if (calculateDistance(
              curLat, curLng, position.latitude, position.longitude)) {
            curLat = position.latitude;
            // curLat = 10.5417397;
            // curLng = 107.2429976;
            curLng = position.longitude;
            try {
              for (String taskIs in taskIds) {
                await _sendLocationToAPI(curLat, curLng, taskIs, token);
                // await sendLatLng(curLat, curLng, token);
              }
            } catch (error) {
              print("Lỗi khi gửi toạ độ: $error");
            }
          }
          await _updateStatus(curLat, curLng, token);
        });
        Timer.periodic(const Duration(minutes: 5), (Timer timer) async {});
      },
    );
  }

  void addTask(String taskId) {
    taskIds.add(taskId);
  }

  void changeToThisList(List<String> newTaskId) {
    taskIds.clear();
    taskIds.addAll(newTaskId);
  }

  void removeTask(String taskId) {
    if (taskIds.contains(taskId)) {
      taskIds.remove(taskId);
    }
  }

  Future<void> _sendLocationToAPI(
      double latitude, double longitude, String taskId, String token) async {
    // print("Sending $taskId's location: lat: $latitude, long: $longitude");
    // return;
    try {
      final response = await http.post(
        Uri.parse('$baseUrll/task/shipper/journey/add/$taskId'),
        headers: {
          'Content-Type': 'application/json',
          "authorization": "Bearer $token"
        },
        body: jsonEncode({
          'lat': latitude,
          'lng': longitude,
        }),
      );
      // print(response.body);

      if (response.statusCode == 201) {
        // print('Location sent successfully sendLocation to task');
      } else {
        // print('Failed to send location sendLocation to task');
      }
    } catch (error) {
      print("Lỗi khi gửi toạ độ: $error");
    }
  }

  Future<void> _updateStatus(
      double latitude, double longitude, String token) async {
    // print("Sending my location: lat: $latitude, long: $longitude");
    // return;
    try {
      final response = await http.post(
        Uri.parse('$baseUrll/staff/status/update'),
        headers: {
          'Content-Type': 'application/json',
          "authorization": "Bearer $token"
        },
        body: jsonEncode({
          'currentLat': latitude,
          'currentLong': longitude,
        }),
      );
      // print(response.body);

      if (response.statusCode == 201) {
        // print('Location sent successfully update status');
      } else {
        // print('Failed to send location update status');
      }
    } catch (error) {
      print("Lỗi khi gửi toạ độ: $error");
    }
  }
}
