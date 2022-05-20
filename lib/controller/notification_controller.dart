import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  //어디서든 controller를 호출할 수 있도록 함
  static NotificationController get to => Get.find();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  //messaging initialized

  @override
  void onInit() {
    _initNotification();
    _getToken();
    super.onInit();
  }

  // Android용 새 Notification Channel
  AndroidNotificationChannel androidNotificationChannel =
      const AndroidNotificationChannel(
    'high_importance_channel', // 임의의 id
    'High Importance Notifications', // 설정에 보일 채널명
    importance: Importance.high,
  );

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

//token을 못받을수도 있기 때문에 try-catch문 사용
  Future<String> _getToken() async {
    try {
      String? token = await _messaging.getToken();
    } catch (e) {
      return e.toString();
    }
    return 'success';
  }

//permission과 configure 세팅
//permission의 경우 IOS만 해당
  void _initNotification() {
    //앱이 켜진 상태
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      try {
        final data = message.data;
        log(message.notification.toString());
        log('message title: ${message.notification!.title}');
      } catch (e) {
        log(e.toString());
      }
    });

    //앱이 꺼지진 않았지만 background에서 돌아가는 상태
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      try {
        log('onResume: $message');
        final data = message.data;
        log(message.notification.toString());
      } catch (e) {
        log(e.toString());
      }
    });
  }
}
