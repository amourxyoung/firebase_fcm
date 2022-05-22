import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:fcm_exercise/second_view.dart';

class NotificationController extends GetxController {
  //어디서든 controller를 호출할 수 있도록 함
  static NotificationController get to => Get.find();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  //messaging initialized
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel', //channel id
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  @override
  void onInit() {
    authCheck();
    _getToken();
    super.onInit();
  }

  void authCheck() async {
    //권한 요청
    NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true);
    log('User granted permission::: ${settings.authorizationStatus}');

    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
        await initiatedAndroid();
        updateChannel();

//Terminated상태에서 클릭한 푸시 알림 메세지 핸들링
        FirebaseMessaging.instance
            .getInitialMessage()
            .then((RemoteMessage? message) async {
          if (message != null) {
            log('메세지 가져옴');
          }
// 앱이 background상태에서 푸시 알림 클릭 하여 열릴 경우 메세지 스트림을 통해 처리
          FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
            log('background에서 알림 클릭');
            Get.to(() => SecondView());
          });
        });

        ///foreground에서 noti 출력
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          RemoteNotification? notification = message.notification;
          AndroidNotification? android = message.notification?.android;
          if (notification != null && android != null) {
            flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  importance: Importance.max,
                  priority: Priority.max,
                  channelDescription: channel.description,
                  icon: android.smallIcon,
                ),
              ),
            );
            log("onForegroundMessage: ${message.data}");
            log('Handling a foreground message ${message.messageId}');
          }
        });
        break;

      case AuthorizationStatus.denied:
        log('User granted permission is denied');
        break;

      default:
        log('User declined or has not accepted permission');
    }
  }

  Future<dynamic> initiatedAndroid() async {
    const initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
    );
    flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: (payload) {
      if (payload != null) {
        Get.to(() => SecondView(), arguments: payload);
      }
    });
  }

  Future<void> updateChannel() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

//token을 못받을수도 있기 때문에 try-catch문 사용
  Future<String> _getToken() async {
    try {
      String? token = await _messaging.getToken();
      log(token ?? 'null');
    } catch (e) {
      return e.toString();
    }
    return 'success';
  }
}
