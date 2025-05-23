// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationService {
//   static final NotificationService instance = NotificationService._internal();

//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   NotificationService._internal();

//   Future<void> init() async {
//     const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//     final iosSettings = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//       onDidReceiveLocalNotification: (id, title, body, payload) async {
//         // xử lý nếu cần
//       },
//     );
//     final settings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );

//     await _flutterLocalNotificationsPlugin.initialize(settings);
//   }

//   Future<void> showNotification({
//     required int id,
//     required String title,
//     required String body,
//   }) async {
//     const androidDetails = AndroidNotificationDetails(
//       'tdLogistics',
//       'Thông báo',
//       channelDescription: 'Kênh mặc định',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//     const notificationDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: DarwinNotificationDetails(),
//     );

//     await _flutterLocalNotificationsPlugin.show(
//         id, title, body, notificationDetails);
//   }
// }
